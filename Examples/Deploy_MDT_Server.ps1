$Modules    = @(

    @{
       Name    = "xSmbShare"
       Version = "1.1.0.0"
    },
    
    @{
       Name    = "PowerShellAccessControl"
       Version = "3.0.135.20150413"
    }

)

Configuration DeployMDTServerContract
{
    Param(
        [PSCredential]
        $Credentials
    )

    #NOTE: Every Module must be constant, DSC Bug?!
    Import-Module -Name PSDesiredStateConfiguration, xSmbShare, PowerShellAccessControl, cMDTBuildLab
    Import-DscResource –ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xSmbShare
    Import-DscResource -ModuleName PowerShellAccessControl
    Import-DscResource -ModuleName cMDTBuildLab

    node $AllNodes.Where{$_.Role -match "MDT Server"}.NodeName
    {

        $SecurePassword = ConvertTo-SecureString $Node.MDTLocalPassword -AsPlainText -Force
        $UserName       = $Node.MDTLocalAccount
        $Credentials    = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName, $SecurePassword

        [string]$separator = ""
        [bool]$weblink = $false
        If ($Node.SourcePath -like "*/*") { $weblink = $true }

        LocalConfigurationManager  
        {
            RebootNodeIfNeeded = $AllNodes.RebootNodeIfNeeded
            ConfigurationMode  = $AllNodes.ConfigurationMode   
        }

        cMDTBuildPreReqs MDTPreReqs {
            Ensure       = "Present"            
            DownloadPath = $Node.SourcePath
        }

        User MDTAccessAccount {
            Ensure                 = "Present"
            UserName               = $Node.MDTLocalAccount
            FullName               = $Node.MDTLocalAccount
            Password               = $Credentials
            PasswordChangeRequired = $false
            PasswordNeverExpires   = $true
            Description            = "Managed Client Administrator Account"
            Disabled               = $false
        }

        WindowsFeature NET35 {
            Ensure = "Present"
            Name   = "Net-Framework-Core"
        }

        Package ADK {
            Ensure     = "Present"
            Name       = "Windows Assessment and Deployment Kit - Windows 10"
            Path       = "$($Node.SourcePath)\Windows Assessment and Deployment Kit\adksetup.exe"
            ProductId  = "82daddb6-d4e0-42cb-988d-1e7f5739e155"
            Arguments  = "/quiet /features OptionId.DeploymentTools OptionId.WindowsPreinstallationEnvironment"
            ReturnCode = 0
        }

        Package MDT {
            Ensure     = "Present"
            Name       = "Microsoft Deployment Toolkit 2013 Update 2 (6.3.8330.1000)"
            Path       = "$($Node.SourcePath)\Microsoft Deployment Toolkit\MicrosoftDeploymentToolkit2013_x64.msi"
            ProductId  = "F172B6C7-45DD-4C22-A5BF-1B2C084CADEF"
            ReturnCode = 0
        }

        cMDTBuildDirectory TempFolder
        {
            Ensure    = "Present"
            Name      = $Node.TempLocation.Replace("$($Node.TempLocation.Substring(0,2))\","")
            Path      = $Node.TempLocation.Substring(0,2)
        }

        cMDTBuildDirectory DeploymentFolder
        {
            Ensure    = "Present"
            Name      = $Node.PSDrivePath.Replace("$($Node.PSDrivePath.Substring(0,2))\","")
            Path      = $Node.PSDrivePath.Substring(0,2)
            DependsOn = "[Package]MDT"
        }

        xSmbShare FolderDeploymentShare
        {
            Ensure                = "Present"
            Name                  = $Node.PSDriveShareName
            Path                  = $Node.PSDrivePath
            FullAccess            = "$env:COMPUTERNAME\$($Node.MDTLocalAccount)"
            FolderEnumerationMode = "AccessBased"
            DependsOn             = "[cMDTBuildDirectory]DeploymentFolder"
        }

        cAccessControlEntry AssignPermissions
        {
            Path       = $Node.PSDrivePath
            ObjectType = "Directory"
            AceType    = "AccessAllowed"
            Principal  = "$env:COMPUTERNAME\$($Node.MDTLocalAccount)"
            AccessMask = [System.Security.AccessControl.FileSystemRights]::FullControl
            DependsOn  = "[cMDTBuildDirectory]DeploymentFolder"
        }

        cMDTBuildPersistentDrive DeploymentPSDrive
        {
            Ensure      = "Present"
            Name        = $Node.PSDriveName
            Path        = $Node.PSDrivePath
            Description = $Node.PSDrivePath.Replace("$($Node.PSDrivePath.Substring(0,2))\","")
            NetworkPath = "\\$($env:COMPUTERNAME)\$($Node.PSDriveShareName)"
            DependsOn   = "[cMDTBuildDirectory]DeploymentFolder"
        }

        ForEach ($OSDirectory in $Node.OSDirectories)   
        {

            [string]$Ensure    = ""
            [string]$OSVersion = ""
            $OSDirectory.GetEnumerator() | % {
                If ($_.key -eq "Ensure")          { $Ensure    = $_.value }
                If ($_.key -eq "OperatingSystem") { $OSVersion = $_.value }
            }

            cMDTBuildDirectory $OSVersion.Replace(' ','')
            {
                Ensure      = $Ensure
                Name        = $OSVersion
                Path        = "$($Node.PSDriveName):\Operating Systems"
                PSDriveName = $Node.PSDriveName
                PSDrivePath = $Node.PSDrivePath
                DependsOn   = "[cMDTBuildDirectory]DeploymentFolder"
            }

            cMDTBuildDirectory "TS$($OSVersion.Replace(' ',''))"
            {
                Ensure      = $Ensure
                Name        = $OSVersion
                Path        = "$($Node.PSDriveName):\Task Sequences"
                PSDriveName = $Node.PSDriveName
                PSDrivePath = $Node.PSDrivePath
                DependsOn   = "[cMDTBuildDirectory]DeploymentFolder"
            }
        }

        ForEach ($CurrentApplicationFolder in $Node.ApplicationFolderStructure)
        {

            [string]$EnsureApplicationFolder = ""
            [string]$ApplicationFolder       = ""
            $CurrentApplicationFolder.GetEnumerator() | % {
                If ($_.key -eq "Ensure") { $EnsureApplicationFolder = $_.value }
                If ($_.key -eq "Folder") { $ApplicationFolder       = $_.value }
            }

            If ($Ensure -eq "Absent")    { $EnsureApplicationFolder = "Absent" }

            cMDTBuildDirectory "AF$($ApplicationFolder.Replace(' ',''))"
            {
                Ensure      = $EnsureApplicationFolder
                Name        = $ApplicationFolder
                Path        = "$($Node.PSDriveName):\Applications"
                PSDriveName = $Node.PSDriveName
                PSDrivePath = $Node.PSDrivePath
                DependsOn   = "[cMDTBuildDirectory]DeploymentFolder"
            }

            ForEach ($CurrentApplicationSubFolder in $CurrentApplicationFolder.SubFolders)
            {

                [string]$EnsureApplicationSubFolder = ""
                [string]$ApplicationSubFolder       = ""
                $CurrentApplicationSubFolder.GetEnumerator() | % {
                    If ($_.key -eq "Ensure") {    $EnsureApplicationSubFolder = $_.value }
                    If ($_.key -eq "SubFolder") { $ApplicationSubFolder       = $_.value }
                }

                If ($Ensure -eq "Absent")    { $EnsureApplicationSubFolder = "Absent" }

                cMDTBuildDirectory "ASF$($ApplicationSubFolder.Replace(' ',''))"
                {
                    Ensure      = $EnsureApplicationSubFolder
                    Name        = $ApplicationSubFolder
                    Path        = "$($Node.PSDriveName):\Applications\$ApplicationFolder"
                    PSDriveName = $Node.PSDriveName
                    PSDrivePath = $Node.PSDrivePath
                    DependsOn   = "[cMDTBuildDirectory]DeploymentFolder"
                }

            }

        }

        ForEach ($OperatingSystem in $Node.OperatingSystems)   
        {

            [string]$Ensure     = ""
            [string]$Name       = ""
            [string]$Path       = ""
            [string]$SourcePath = ""

            $OperatingSystem.GetEnumerator() | % {
                If ($_.key -eq "Ensure")     { $Ensure     = $_.value }
                If ($_.key -eq "Name")       { $Name       = $_.value }
                If ($_.key -eq "Path")       { $Path       = "$($Node.PSDriveName):\Operating Systems\$($_.value)" }
                If ($_.key -eq "SourcePath") { $SourcePath = "$($Node.SourcePath)$($_.value)" }
            }

            cMDTBuildOperatingSystem $Name.Replace(' ','')
            {
                Ensure      = $Ensure
                Name        = $Name
                Path        = $Path
                SourcePath  = $SourcePath
                PSDriveName = $Node.PSDriveName
                PSDrivePath = $Node.PSDrivePath
                DependsOn   = "[cMDTBuildDirectory]DeploymentFolder"
            }
        }

        ForEach ($Application in $Node.Applications)
        {

            [string]$Ensure                = ""
            [string]$Name                  = ""
            [string]$Version               = ""
            [string]$Path                  = ""
            [string]$ShortName             = ""
            [string]$CommandLine           = ""
            [string]$WorkingDirectory      = ""
            [string]$ApplicationSourcePath = ""
            [string]$DestinationFolder     = ""

            $Application.GetEnumerator() | % {
                If ($_.key -eq "Ensure")                { $Ensure                = $_.value }
                If ($_.key -eq "Name")                  { $Name                  = $_.value }
                If ($_.key -eq "Version")               { $Version               = $_.value }
                If ($_.key -eq "Path")                  { $Path                  = "$($Node.PSDriveName):$($_.value)" }
                If ($_.key -eq "ShortName")             { $ShortName             = $_.value }
                If ($_.key -eq "CommandLine")           { $CommandLine           = $_.value }
                If ($_.key -eq "WorkingDirectory")      { $WorkingDirectory      = $_.value }
                If ($_.key -eq "ApplicationSourcePath")
                {
                    If (($_.value -like "*:*") -or ($_.value -like "*\\*"))
                                                        { $ApplicationSourcePath = $_.value }
                    Else
                    {
                        If ($weblink)                   { $ApplicationSourcePath = "$($Node.SourcePath)$($_.value.Replace("\","/"))" }
                        Else                            { $ApplicationSourcePath = "$($Node.SourcePath)$($_.value.Replace("/","\"))" }
                    }
                }
                If ($_.key -eq "DestinationFolder")     { $DestinationFolder     = $_.value }
            }

            cMDTBuildApplication $Name.Replace(' ','')
            {
                Ensure                = $Ensure
                Name                  = $Name
                Version               = $Version
                Path                  = $Path
                ShortName             = $ShortName
                CommandLine           = $CommandLine
                WorkingDirectory      = $WorkingDirectory
                ApplicationSourcePath = $ApplicationSourcePath
                DestinationFolder     = $DestinationFolder
                Enabled               = "True"
                PSDriveName           = $Node.PSDriveName
                PSDrivePath           = $Node.PSDrivePath
                DependsOn             = "[cMDTBuildDirectory]DeploymentFolder"
            }
        }

        ForEach ($TaskSequence in $Node.TaskSequences)   
        {
            [string]$Ensure   = ""
            [string]$Name     = ""
            [string]$Path     = ""
            [string]$OSName   = ""
			[string]$Template = ""
            [string]$ID       = ""
            [string]$OrgName  = ""

            $TaskSequence.GetEnumerator() | % {
                If ($_.key -eq "Ensure")   { $Ensure   = $_.value }
                If ($_.key -eq "Name")     { $Name     = $_.value }
                If ($_.key -eq "Path")     { $Path     = "$($Node.PSDriveName):\Task Sequences\$($_.value)" }
                If ($_.key -eq "OSName")   { $OSName   = "$($Node.PSDriveName):\Operating Systems\$($_.value)" }
                If ($_.key -eq "Template") { $Template = $_.value }
                If ($_.key -eq "ID")       { $ID       = $_.value }
                If ($_.key -eq "OrgName")  { $OrgName  = $_.value }
            }

            cMDTBuildTaskSequence $Name.Replace(' ','')
            {
                Ensure      = $Ensure
                Name        = $Name
                Path        = $Path
				OSName      = $OSName
                Template    = $Template
                ID          = $ID
				OrgName     = $OrgName
                PSDriveName = $Node.PSDriveName
                PSDrivePath = $Node.PSDrivePath
                DependsOn   = "[cMDTBuildDirectory]DeploymentFolder"
            }
        }

        ForEach ($CustomSetting in $Node.CustomSettings)   
        {

            [string]$Ensure     = ""
            [string]$Name       = ""
            [string]$Version    = ""
            [bool]$Protected    = $False
            [string]$SourcePath = ""

            $CustomSetting.GetEnumerator() | % {
                If ($_.key -eq "Ensure")     { $Ensure     = $_.value }
                If ($_.key -eq "Name")       { $Name       = $_.value }
                If ($_.key -eq "Version")    { $Version    = $_.value }
                If ($_.key -eq "Protected")  {
                    If ($_.value)            { $Protected  = $_.value }
                }
                If ($_.key -eq "SourcePath")
                {
                    If (($_.value -like "*:*") -or ($_.value -like "*\\*"))
                                             { $SourcePath = $_.value }
                    Else
                    {
                        If ($weblink)        { $SourcePath = "$($Node.SourcePath)$($_.value.Replace("\","/"))" }
                        Else                 { $SourcePath = "$($Node.SourcePath)$($_.value.Replace("/","\"))" }
                    }
                }
            }

            If ($Node.SourcePath -like "*/*") { $weblink = $true }

            cMDTBuildCustomize $Name.Replace(' ','')
            {
                Ensure       = $Ensure
                Name         = $Name
                Version      = $Version
                SourcePath   = $SourcePath
                Path         = $Node.PSDrivePath
                TempLocation = $Node.TempLocation
                #Protected    = $Protected
                DependsOn    = "[cMDTBuildDirectory]DeploymentFolder"
            }
        }

        ForEach ($IniFile in $Node.CustomizeIniFiles)   
        {

            [string]$Ensure               = ""
            [string]$Name                 = ""
            [string]$Path                 = ""
            [string]$HomePage             = ""
            [string]$SkipAdminPassword    = ""
            [string]$SkipApplications     = ""
            [string]$SkipBitLocker        = ""
            [string]$SkipCapture          = ""
            [string]$SkipComputerBackup   = ""
            [string]$SkipComputerName     = ""
            [string]$SkipDomainMembership = ""
            [string]$SkipFinalSummary     = ""
            [string]$SkipLocaleSelection  = ""
            [string]$SkipPackageDisplay   = ""
            [string]$SkipProductKey       = ""
            [string]$SkipRoles            = ""
            [string]$SkipSummary          = ""
            [string]$SkipTimeZone         = ""
            [string]$SkipUserData         = ""
            [string]$SkipTaskSequence     = ""
            [string]$JoinDomain           = ""
            [string]$DomainAdmin          = ""
            [string]$DomainAdminDomain    = ""
            [string]$DomainAdminPassword  = ""
            [string]$MachineObjectOU      = ""
            [string]$TimeZoneName         = ""
            [string]$WSUSServer           = ""
            [string]$UserLocale           = ""
            [string]$KeyboardLocale       = ""
            [string]$UILanguage           = ""
            [string]$DeployRoot           = ""
            [string]$KeyboardLocalePE     = ""

            $IniFile.GetEnumerator() | % {
                If ($_.key -eq "Ensure")               { $Ensure               = $_.value }
                If ($_.key -eq "Name")                 { $Name                 = $_.value }
                If ($_.key -eq "Path")                 { $Path                 = "$($Node.PSDrivePath)$($_.value)" }                                                
                If ($_.key -eq "HomePage")             { $HomePage             = $_.value }
                If ($_.key -eq "SkipAdminPassword")    { $SkipAdminPassword    = $_.value }
                If ($_.key -eq "SkipApplications")     { $SkipApplications     = $_.value }
                If ($_.key -eq "SkipBitLocker")        { $SkipBitLocker        = $_.value }
                If ($_.key -eq "SkipCapture")          { $SkipCapture          = $_.value }
                If ($_.key -eq "SkipComputerBackup")   { $SkipComputerBackup   = $_.value }
                If ($_.key -eq "SkipComputerName")     { $SkipComputerName     = $_.value }
                If ($_.key -eq "SkipDomainMembership") { $SkipDomainMembership = $_.value }
                If ($_.key -eq "SkipFinalSummary")     { $SkipFinalSummary     = $_.value }
                If ($_.key -eq "SkipLocaleSelection")  { $SkipLocaleSelection  = $_.value }
                If ($_.key -eq "SkipPackageDisplay")   { $SkipPackageDisplay   = $_.value }
                If ($_.key -eq "SkipProductKey")       { $SkipProductKey       = $_.value }
                If ($_.key -eq "SkipRoles")            { $SkipRoles            = $_.value }
                If ($_.key -eq "SkipSummary")          { $SkipSummary          = $_.value }
                If ($_.key -eq "SkipTimeZone")         { $SkipTimeZone         = $_.value }
                If ($_.key -eq "SkipUserData")         { $SkipUserData         = $_.value }
                If ($_.key -eq "SkipTaskSequence")     { $SkipTaskSequence     = $_.value }                                                      
                If ($_.key -eq "JoinDomain")           { $JoinDomain           = $_.value }
                If ($_.key -eq "DomainAdmin")          { $DomainAdmin          = $_.value }
                If ($_.key -eq "DomainAdminDomain")    { $DomainAdminDomain    = $_.value }
                If ($_.key -eq "DomainAdminPassword")  { $DomainAdminPassword  = $_.value }
                If ($_.key -eq "MachineObjectOU")      { $MachineObjectOU      = $_.value }
                If ($_.key -eq "TimeZoneName")         { $TimeZoneName         = $_.value }
                If ($_.key -eq "WSUSServer")           { $WSUSServer           = $_.value }
                If ($_.key -eq "UserLocale")           { $UserLocale           = $_.value }
                If ($_.key -eq "KeyboardLocale")       { $KeyboardLocale       = $_.value }
                If ($_.key -eq "UILanguage")           { $UILanguage           = $_.value }
                If ($_.key -eq "DeployRoot")           { $DeployRoot           = "$($Node.SourcePath)$($_.value)" }
                If ($_.key -eq "KeyboardLocalePE")     { $KeyboardLocalePE     = $_.value }
            }

            If ($HomePage)             { $HomePage             = "Home_Page=$($HomePage)" }                        Else { $HomePage             = ";Home_Page=" }
            If ($SkipAdminPassword)    { $SkipAdminPassword    = "SkipAdminPassword=$($SkipAdminPassword)" }       Else { $SkipAdminPassword    = ";SkipAdminPassword=" }
            If ($SkipApplications)     { $SkipApplications     = "SkipApplications=$($SkipApplications)" }         Else { $SkipApplications     = ";SkipApplications=" }
            If ($SkipBitLocker)        { $SkipBitLocker        = "SkipBitLocker=$($SkipBitLocker)" }               Else { $SkipBitLocker        = ";SkipBitLocker=" }
            If ($SkipCapture)          { $SkipCapture          = "SkipCapture=$($SkipCapture)" }                   Else { $SkipCapture          = ";SkipCapture=" }
            If ($SkipComputerBackup)   { $SkipComputerBackup   = "SkipComputerBackup=$($SkipComputerBackup)" }     Else { $SkipComputerBackup   = ";SkipComputerBackup=" }
            If ($SkipComputerName)     { $SkipComputerName     = "SkipComputerName=$($SkipComputerName)" }         Else { $SkipComputerName     = ";SkipComputerName=" }
            If ($SkipDomainMembership) { $SkipDomainMembership = "SkipDomainMembership=$($SkipDomainMembership)" } Else { $SkipDomainMembership = ";SkipDomainMembership=" }
            If ($SkipFinalSummary)     { $SkipFinalSummary     = "SkipFinalSummary=$($SkipFinalSummary)" }         Else { $SkipFinalSummary     = ";SkipFinalSummary=" }
            If ($SkipLocaleSelection)  { $SkipLocaleSelection  = "SkipLocaleSelection=$($SkipLocaleSelection)" }   Else { $SkipLocaleSelection  = ";SkipLocaleSelection=" }
            If ($SkipPackageDisplay)   { $SkipPackageDisplay   = "SkipPackageDisplay=$($SkipPackageDisplay)" }     Else { $SkipPackageDisplay   = ";SkipPackageDisplay=" }
            If ($SkipProductKey)       { $SkipProductKey       = "SkipProductKey=$($SkipProductKey)" }             Else { $SkipProductKey       = ";SkipProductKey=" }
            If ($SkipRoles)            { $SkipRoles            = "SkipRoles=$($SkipRoles)" }                       Else { $SkipRoles            = ";SkipRoles=" }
            If ($SkipSummary)          { $SkipSummary          = "SkipSummary=$($SkipSummary)" }                   Else { $SkipSummary          = ";SkipSummary=" }
            If ($SkipTimeZone)         { $SkipTimeZone         = "SkipTimeZone=$($SkipTimeZone)" }                 Else { $SkipTimeZone         = ";SkipTimeZone=" }
            If ($SkipUserData)         { $SkipUserData         = "SkipUserData=$($SkipUserData)" }                 Else { $SkipUserData         = ";SkipUserData=" }
            If ($SkipTaskSequence)     { $SkipTaskSequence     = "SkipTaskSequence=$($SkipTaskSequence)" }         Else { $SkipTaskSequence     = ";SkipTaskSequence=" }
            If ($JoinDomain)           { $JoinDomain           = "JoinDomain=$($JoinDomain)" }                     Else { $JoinDomain           = ";JoinDomain=" }
            If ($DomainAdmin)          { $DomainAdmin          = "DomainAdmin=$($DomainAdmin)" }                   Else { $DomainAdmin          = ";DomainAdmin=" }
            If ($DomainAdminDomain)    { $DomainAdminDomain    = "DomainAdminDomain=$($DomainAdminDomain)" }       Else { $DomainAdminDomain    = ";DomainAdminDomain=" }
            If ($DomainAdminPassword)  { $DomainAdminPassword  = "DomainAdminPassword=$($DomainAdminPassword)" }   Else { $DomainAdminPassword  = ";DomainAdminPassword=" }
            If ($MachineObjectOU)      { $MachineObjectOU      = "MachineObjectOU=$($MachineObjectOU)" }           Else { $MachineObjectOU      = ";MachineObjectOU=" }
            If ($TimeZoneName)         { $TimeZoneName         = "TimeZoneName=$($TimeZoneName)" }                 Else { $TimeZoneName         = ";TimeZoneName=" }
            If ($WSUSServer)           { $WSUSServer           = "WSUSServer=$($WSUSServer)" }                     Else { $WSUSServer           = ";WSUSServer=" }
            If ($UserLocale)           { $UserLocale           = "UserLocale=$($UserLocale)" }                     Else { $UserLocale           = ";UserLocale=" }
            If ($KeyboardLocale)       { $KeyboardLocale       = "KeyboardLocale=$($KeyboardLocale)" }             Else { $KeyboardLocale       = ";KeyboardLocale=" }
            If ($UILanguage)           { $UILanguage           = "UILanguage=$($UILanguage)" }                     Else { $UILanguage           = ";UILanguage=" }
            If ($KeyboardLocalePE)     { $KeyboardLocalePE     = "KeyboardLocalePE=$($KeyboardLocalePE)" }         Else { $KeyboardLocalePE     = ";KeyboardLocalePE=" }

            If ($Name -eq "CustomSettingsIni")
            {
                cMDTBuildCustomSettingsIni ini {
                    Ensure    = $Ensure
                    Path      = $Path
                    DependsOn = "[cMDTBuildDirectory]DeploymentFolder"
                    Content   = @"
[Settings]
Priority=SetModelAlias, Init, ModelAlias, Default
Properties=ModelAlias, ComputerSerialNumber

[SetModelAlias]
UserExit=ModelAliasExit.vbs
ModelAlias=#SetModelAlias()#

[Init]
ComputerSerialNumber=#Mid(Replace(Replace(oEnvironment.Item("SerialNumber")," ",""),"-",""),1,11)#

[Default]
OSInstall=Y
_SMSTSORGNAME=Company
HideShell=YES
DisableTaskMgr=YES
ApplyGPOPack=NO
UserDataLocation=NONE
DoCapture=NO
OSDComputerName=CLI%ComputerSerialNumber%

;Local admin password
AdminPassword=$($Node.LocalAdminPassword)
SLShare=%DeployRoot%\Logs

OrgName=Company
$($HomePage)

;Enable or disable options:
$($SkipAdminPassword)
$($SkipApplications)
$($SkipBitLocker)
$($SkipCapture)
$($SkipComputerBackup)
$($SkipComputerName)
$($SkipDomainMembership)
$($SkipFinalSummary)
$($SkipLocaleSelection)
$($SkipPackageDisplay)
$($SkipProductKey)
$($SkipRoles)
$($SkipSummary)
$($SkipTimeZone)
$($SkipUserData)
$($SkipTaskSequence)

;DomainJoin
$($JoinDomain)
$($DomainAdmin)
$($DomainAdminDomain)
$($DomainAdminPassword)
$($MachineObjectOU)

;TimeZone settings
$($TimeZoneName)

$($WSUSServer)

;Example keyboard layout.
$($UserLocale)
$($KeyboardLocale)
$($UILanguage)

;Drivers
DriverSelectionProfile=Nothing

;DriverInjectionMode=ALL

FinishAction=RESTART
"@
                }
            }

            If ($Name -eq "BootstrapIni")
            {
                cMDTBuildBootstrapIni ini {
                    Ensure    = $Ensure
                    Path      = $Path
                    DependsOn = "[cMDTBuildDirectory]DeploymentFolder"
                    Content   = @"
[Settings]
Priority=Default

[Default]
DeployRoot=\\$($Node.NodeName)\$($Node.PSDriveShareName)
SkipBDDWelcome=YES

;MDT Connect Account
UserID=$($Node.MDTLocalAccount)
UserPassword=$($Node.MDTLocalPassword)
UserDomain=$($env:COMPUTERNAME)

;Keyboard Layout
$($KeyboardLocalePE)
"@
                }
            }

        }

        ForEach ($Image in $Node.BootImage)   
        {

            [string]$Ensure                   = ""
            [string]$Name                     = ""
            [string]$Version                  = ""
            [string]$Path                     = ""
            [string]$ImageName                = ""
            [string]$ExtraDirectory           = ""
            [string]$BackgroundFile           = ""
            [string]$LiteTouchWIMDescription  = ""

            $Image.GetEnumerator() | % {
                If ($_.key -eq "Ensure")                   { $Ensure                   = $_.value }
                If ($_.key -eq "Name")                     { $Name                     = $_.value }
                If ($_.key -eq "Version")                  { $Version                  = $_.value }
                If ($_.key -eq "Path")                     { $Path                     = "$($Node.PSDrivePath)$($_.value)" }
                If ($_.key -eq "ImageName")                { $ImageName                = $_.value }
                If ($_.key -eq "ExtraDirectory")           { $ExtraDirectory           = $_.value }
                If ($_.key -eq "BackgroundFile")           { $BackgroundFile           = $_.value }
                If ($_.key -eq "LiteTouchWIMDescription")  { $LiteTouchWIMDescription  = $_.value }
            }

            cMDTBuildUpdateBootImage updateBootImage {
                Version                 = $Version
                PSDeploymentShare       = $Node.PSDriveName
                Force                   = $true
                Compress                = $true
                DeploymentSharePath     = $Node.PSDrivePath
                ExtraDirectory          = $ExtraDirectory
                BackgroundFile          = $BackgroundFile
                LiteTouchWIMDescription = $LiteTouchWIMDescription
                DependsOn               = "[cMDTBuildDirectory]DeploymentFolder"
            }
        
        }

    }
}

#Get configuration data
$ConfigurationData = Invoke-Expression (Get-Content -Path "$PSScriptRoot\Deploy_MDT_Server_ConfigurationData.psd1" -Raw)

#Create DSC MOF job
DeployMDTServerContract -OutputPath "$PSScriptRoot\MDT-Deploy_MDT_Server" -ConfigurationData $ConfigurationData

#Set DSC LocalConfigurationManager
Set-DscLocalConfigurationManager -Path "$PSScriptRoot\MDT-Deploy_MDT_Server" -Verbose

#Start DSC MOF job
Start-DscConfiguration -Wait -Force -Verbose -ComputerName "$env:computername" -Path "$PSScriptRoot\MDT-Deploy_MDT_Server"

Write-Output ""
Write-Output "Deploy MDT Server Builder completed!"