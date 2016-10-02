$Modules    = @(
    @{
       Name    = "xSmbShare"
       Version = "2.0.0.0"
    },
    @{
       Name    = "cNtfsAccessControl"
       Version = "1.3.0"
    }
)

Configuration DeployMDTServerContract
{
    Param(
        [PSCredential]
        $Credentials
    )

    Import-Module -Name PSDesiredStateConfiguration, xSmbShare, cNtfsAccessControl, cMDTBuildLab
    Import-DscResource –ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xSmbShare
    Import-DscResource -ModuleName cNtfsAccessControl
    Import-DscResource -ModuleName cMDTBuildLab

    node $AllNodes.Where{$_.Role -match "MDT Server"}.NodeName
    {

        $SecurePassword = ConvertTo-SecureString $Node.MDTLocalPassword -AsPlainText -Force
        $UserName       = $Node.MDTLocalAccount
        $Credentials    = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName, $SecurePassword

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

		WindowsFeature  DataDeduplication {
			Ensure = "Present"
			Name   = "FS-Data-Deduplication"
		}

        Package ADK {
            Ensure     = "Present"
            Name       = "Windows Assessment and Deployment Kit - Windows 10"
            Path       = "$($Node.SourcePath)\Windows Assessment and Deployment Kit\adksetup.exe"
            ProductId  = "39ebb79f-797c-418f-b329-97cfdf92b7ab"
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
            #FullAccess            = "$($Node.NodeName)\$($Node.MDTLocalAccount)"
			FullAccess            = "Everyone"
            FolderEnumerationMode = "AccessBased"
            DependsOn             = "[cMDTBuildDirectory]DeploymentFolder"
        }

        cMDTBuildPersistentDrive DeploymentPSDrive
        {
            Ensure      = "Present"
            Name        = $Node.PSDriveName
            Path        = $Node.PSDrivePath
            Description = $Node.PSDrivePath.Replace("$($Node.PSDrivePath.Substring(0,2))\","")
            NetworkPath = "\\$($Node.NodeName)\$($Node.PSDriveShareName)"
            DependsOn   = "[cMDTBuildDirectory]DeploymentFolder"
        }

        cNtfsPermissionEntry AssignPermissionsMDT
        {
            Ensure = "Present"
            Path   = $Node.PSDrivePath
            Principal  = "$($Node.NodeName)\$($Node.MDTLocalAccount)"
            AccessControlInformation = @(
                cNtfsAccessControlInformation {
                    AccessControlType = "Allow"
                    FileSystemRights = "ReadAndExecute"
                    Inheritance = "ThisFolderSubfoldersAndFiles"
                    NoPropagateInherit = $false
                }
            )
            DependsOn  = "[cMDTBuildPersistentDrive]DeploymentPSDrive"
        }

        cNtfsPermissionEntry AssignPermissionsCaptures
        {
            Ensure = "Present"
            Path   = "$($Node.PSDrivePath)\Captures"
            Principal  = "$($Node.NodeName)\$($Node.MDTLocalAccount)"
            AccessControlInformation = @(
                cNtfsAccessControlInformation {
                    AccessControlType = "Allow"
                    FileSystemRights = "Modify"
                    Inheritance = "ThisFolderSubfoldersAndFiles"
                    NoPropagateInherit = $false
                }
            )
            DependsOn  = "[cMDTBuildPersistentDrive]DeploymentPSDrive"
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

		# Task Sequence folder for autobuild
        cMDTBuildDirectory "TSREF"
        {
            Ensure      = "Present"
            Name        = "REF"
            Path        = "$($Node.PSDriveName):\Task Sequences"
            PSDriveName = $Node.PSDriveName
            PSDrivePath = $Node.PSDrivePath
            DependsOn   = "[cMDTBuildDirectory]DeploymentFolder"
        }

		$PkgDepend = "[cMDTBuildDirectory]DeploymentFolder"
		foreach ($PkgFolder in $Node.PackagesFolderStructure)
		{
            [string]$Ensure = ""
            [string]$Folder = ""
            $PkgFolder.GetEnumerator() | % {
                If ($_.key -eq "Ensure") { $Ensure = $_.value }
                If ($_.key -eq "Folder") { $Folder = $_.value }
            }

            cMDTBuildDirectory "PKG$($Folder.Replace(' ',''))"
            {
                Ensure      = $Ensure
                Name        = $Folder
                Path        = "$($Node.PSDriveName):\Packages"
                PSDriveName = $Node.PSDriveName
                PSDrivePath = $Node.PSDrivePath
                DependsOn   = $PkgDepend
            }
	
			# Workaround for import packages with Powershell DSC 5.0 and MDT 2013 Update 2
			$PkgDepend = "[cMDTBuildDirectory]PKG$($Folder.Replace(' ',''))"
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

        ForEach ($SelectionProfile in $Node.SelectionProfiles)
        {
            [string]$Ensure = ""
            [string]$Name = ""
            $SelectionProfile.GetEnumerator() | % {
                If ($_.key -eq "Ensure")      { $Ensure = $_.value }
                If ($_.key -eq "Name")        { $Name = $_.value }
				If ($_.key -eq "IncludePath") { $IncludePath = $_.value }
            }

            cMDTBuildSelectionProfile {
                Ensure      = $Present
                Name        = $Name
				IncludePath = $IncludePath
                PSDriveName = $Node.PSDriveName
                PSDrivePath = $Node.PSDrivePath
                DependsOn   = "[cMDTBuildDirectory]DeploymentFolder"
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
            [string]$Path                  = ""
            [string]$CommandLine           = ""
            [string]$ApplicationSourcePath = ""

            $Application.GetEnumerator() | % {
                If ($_.key -eq "Ensure")                { $Ensure                = $_.value }
                If ($_.key -eq "Name")                  { $Name                  = $_.value }
                If ($_.key -eq "Path")                  { $Path                  = "$($Node.PSDriveName):$($_.value)" }
                If ($_.key -eq "CommandLine")           { $CommandLine           = $_.value }
                If ($_.key -eq "ApplicationSourcePath") { $ApplicationSourcePath = "$($Node.SourcePath)\$($_.value)" }
            }

            cMDTBuildApplication $Name.Replace(' ','')
            {
                Ensure                = $Ensure
                Name                  = $Name
                Path                  = $Path
                CommandLine           = $CommandLine
                ApplicationSourcePath = $ApplicationSourcePath
                Enabled               = "True"
                PSDriveName           = $Node.PSDriveName
                PSDrivePath           = $Node.PSDrivePath
                DependsOn             = "[cMDTBuildDirectory]DeploymentFolder"
            }
        }

        ForEach ($Package in $Node.Packages)
        {
            [string]$Ensure            = ""
			[string]$Name              = ""
            [string]$Path              = ""
            [string]$PackageSourcePath = ""

            $Package.GetEnumerator() | % {
                If ($_.key -eq "Ensure")            { $Ensure            = $_.value }
                If ($_.key -eq "Name")              { $Name              = $_.value }
                If ($_.key -eq "Path")              { $Path              = "$($Node.PSDriveName):$($_.value)" }
                If ($_.key -eq "PackageSourcePath") { $PackageSourcePath = "$($Node.SourcePath)\$($_.value)" }
            }

            cMDTBuildPackage $Name.Replace(' ','')
            {
                Ensure            = $Ensure
                Name              = $Name
				Path              = $Path
                PackageSourcePath = $PackageSourcePath
                PSDriveName       = $Node.PSDriveName
                PSDrivePath       = $Node.PSDrivePath
                DependsOn         = "[cMDTBuildDirectory]DeploymentFolder"
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

			# Create Task Sequence for one OS image
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

			# Customize Task Sequence for one OS image
            ForEach ($TSCustomize in $TaskSequence.Customize)
            {
				[string]$Name       = ""
				[string]$NewName    = ""
				[string]$Type       = ""
				[string]$GroupName  = ""
				[string]$SubGroup   = ""
				[string]$Disable    = ""
				[string]$AddAfter   = ""
				[string]$OSName     = ""    # for OS features only
				[string]$OSFeatures = ""
				[string]$Command    = ""    # for Run Command line only

				$TSCustomize.GetEnumerator() | % {
	                If ($_.key -eq "Name")       { $Name       = $_.value }
					If ($_.key -eq "NewName")    { $NewName    = $_.value }
					If ($_.key -eq "Type")       { $Type       = $_.value }
					If ($_.key -eq "GroupName")  { $GroupName  = $_.value }
					If ($_.key -eq "SubGroup")   { $SubGroup   = $_.value }
					If ($_.key -eq "Disable")    { $Disable    = $_.value }
					If ($_.key -eq "AddAfter")   { $AddAfter   = $_.value }
					If ($_.key -eq "OSName")     { $OSName     = $_.value }
					If ($_.key -eq "OSFeatures") { $OSFeatures = $_.value }
					If ($_.key -eq "Command")    { $Command    = $_.value }
				}

				# Current TS XML file name
				$TSFile = "$($Node.PSDrivePath)\Control\$($ID)\ts.xml"

                $CustomResource = $ID + '-' + $Name.Replace(' ','')
	            cMDTBuildTaskSequenceCustomize $CustomResource
				{
					TSFile      = $TSFile
					Name        = $Name
					NewName     = $NewName
					Type        = $Type
					GroupName   = $GroupName
					SubGroup    = $SubGroup
					Disable     = $Disable
					AddAfter    = $AddAfter
					OSName      = $OSName
					OSFeatures  = $OSFeatures
					Command     = $Command
	                PSDriveName = $Node.PSDriveName
		            PSDrivePath = $Node.PSDrivePath
				}
			}
        }

        ForEach ($CustomSetting in $Node.CustomSettings)   
        {
            [string]$Ensure      = ""
            [string]$Name        = ""
            [string]$SourcePath  = ""
			[string[]]$TestFiles = ""

            $CustomSetting.GetEnumerator() | % {
                If ($_.key -eq "Ensure")     { $Ensure     = $_.value }
                If ($_.key -eq "Name")       { $Name       = $_.value }
                If ($_.key -eq "SourcePath") { $SourcePath = "$($Node.SourcePath)\$($_.value)" }
				If ($_.key -eq "TestFiles")  { $TestFiles  = $_.value }
            }

            cMDTBuildCustomize $Name.Replace(' ','')
            {
                Ensure       = $Ensure
                Name         = $Name
                SourcePath   = $SourcePath
                Path         = $Node.PSDrivePath
				TestFiles    = $TestFiles
                DependsOn    = "[cMDTBuildDirectory]DeploymentFolder"
            }
        }

        ForEach ($IniFile in $Node.CustomizeIniFiles)   
        {
            [string]$Ensure               = ""
            [string]$Name                 = ""
            [string]$Path                 = ""
            [string]$Company              = ""
			[string]$TimeZomeName         = ""
            [string]$WSUSServer           = ""
            [string]$UserLocale           = ""
            [string]$KeyboardLocale       = ""

            $IniFile.GetEnumerator() | % {
                If ($_.key -eq "Ensure")               { $Ensure               = $_.value }
                If ($_.key -eq "Name")                 { $Name                 = $_.value }
                If ($_.key -eq "Path")                 { $Path                 = "$($Node.PSDrivePath)$($_.value)" }                                                
                If ($_.key -eq "Company")              { $Company              = $_.value }
                If ($_.key -eq "TimeZoneName")         { $TimeZoneName         = $_.value }
                If ($_.key -eq "WSUSServer")           { $WSUSServer           = $_.value }
                If ($_.key -eq "UserLocale")           { $UserLocale           = $_.value }
                If ($_.key -eq "KeyboardLocale")       { $KeyboardLocale       = $_.value }
            }

            If ($Company)              { $Company              = "_SMSTSORGNAME=$($Company)" }                     Else { $Company              = ";_SMSTSORGNAME=" }
            If ($TimeZoneName)         { $TimeZoneName         = "TimeZoneName=$($TimeZoneName)" }                 Else { $TimeZoneName         = ";TimeZoneName=" }
            If ($WSUSServer)           { $WSUSServer           = "WSUSServer=$($WSUSServer)" }                     Else { $WSUSServer           = ";WSUSServer=" }
            If ($UserLocale)           { $UserLocale           = "UserLocale=$($UserLocale)" }                     Else { $UserLocale           = ";UserLocale=" }
            If ($KeyboardLocale)       { $KeyboardLocale       = "KeyboardLocale=$($KeyboardLocale)" }             Else { $KeyboardLocale       = ";KeyboardLocale=" }

            If ($Name -eq "CustomSettingsIni")
            {
                cMDTBuildCustomSettingsIni ini {
                    Ensure    = $Ensure
                    Path      = $Path
                    DependsOn = "[cMDTBuildDirectory]DeploymentFolder"
                    Content   = @"
[Settings]
Priority=Init,Default
Properties=VMNameAlias

[Init]
UserExit=ReadKVPData.vbs
VMNameAlias=#SetVMNameAlias()#

[Default]
$($Company)
OSInstall=Y
HideShell=YES
ApplyGPOPack=NO
UserDataLocation=NONE
DoNotCreateExtraPartition=YES
JoinWorkgroup=WORKGROUP
$($TimeZoneName)
$($WSUSServer)
;SLShare=%DeployRoot%\Logs
TaskSequenceID=%VMNameAlias%
FinishAction=SHUTDOWN

;Set keyboard layout
$($UserLocale)
$($KeyboardLocale)

ComputerBackupLocation=NETWORK
BackupShare=\\$($Node.NodeName)\$($Node.PSDriveShareName)
BackupDir=Captures
BackupFile=#left("%TaskSequenceID%", len("%TaskSequenceID%")-3) & year(date) & right("0" & month(date), 2) & right("0" & day(date), 2)#.wim
DoCapture=YES

;Disable all wizard pages
SkipAdminPassword=YES
SkipApplications=YES
SkipBitLocker=YES
SkipCapture=YES
SkipComputerBackup=YES
SkipComputerName=YES
SkipDomainMembership=YES
SkipFinalSummary=YES
SkipLocaleSelection=YES
SkipPackageDisplay=YES
SkipProductKey=YES
SkipRoles=YES
SkipSummary=YES
SkipTimeZone=YES
SkipUserData=YES
SkipTaskSequence=YES
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
UserDomain=$($Node.NodeName)

SubSection=ISVM-%IsVM%

[ISVM-True]
UserExit=LoadKVPInWinPE.vbs
"@
                }
            }
        }

        ForEach ($Image in $Node.BootImage)   
        {

            [string]$Version                  = ""
            [string]$ExtraDirectory           = ""
            [string]$BackgroundFile           = ""
            [string]$LiteTouchWIMDescription  = ""

            $Image.GetEnumerator() | % {
                If ($_.key -eq "Version")                  { $Version                  = $_.value }
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

#Set data deduplication
Enable-DedupVolume -Volume "E:"
Set-DedupVolume -Volume "E:" -MinimumFileAgeDays 3

Write-Output ""
Write-Output "Deploy MDT Server Builder completed!"
