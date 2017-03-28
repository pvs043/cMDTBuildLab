<#
.Synopsis
    ImageFactory 3.2
.DESCRIPTION
    Run this script for build Windows Reference Images on remote Hyper-V host
.EXAMPLE
    Edit config ImageFactoryV3.xml with your settings:

    <Settings>
        <ReportFrom>AutoBuild@build.lab</ReportFrom>
        <ReportTo>AutoBuild@build.lab</ReportTo>
        <ReportSmtp>smtp.build.lab</ReportSmtp>
        <MDT>
            <DeploymentShare>E:\MDTBuildLab</DeploymentShare>
            <RefTaskSequenceFolderName>REF</RefTaskSequenceFolderName>
        </MDT>
        <HyperV>
            <StartUpRAM>4</StartUpRAM>
            <VLANID>0</VLANID>
            <Computername>HV01</Computername>
            <SwitchName>Network Switch</SwitchName>
            <VMLocation>E:\Build</VMLocation>
            <ISOLocation>E:\Build\ISO</ISOLocation>
            <VHDSize>60</VHDSize>
            <NoCPU>2</NoCPU>
        </HyperV>
    </Settings>

    Run ImageFactoryV3-Build.ps1 at MDT host
.NOTES
    Created:	 2016-11-24
    Version:	 3.1

    Updated:	 2017-02-23
    Version:	 3.2

    Author : Mikael Nystrom
    Twitter: @mikael_nystrom
    Blog   : http://deploymentbunny.com

    Disclaimer:
    This script is provided 'AS IS' with no warranties, confers no rights and 
    is not supported by the author.

    Modyfy : Pavel Andreev
    E-mail : pvs043@outlook.com
    Date   : 2017-02-27
    Project: cMDTBuildLab (https://github.com/pvs043/cMDTBuildLab/wiki)

    Changes:
      * Remove dependency for PsIni module
      * Remove cleaning of MDT Captures folder: each new captured WIM is builded with timestamp date at file name for history tracking,
        you can delete or move old images from external scripts
      * Run Reference VMs as Job at Hyper-V host: it's faster
      * Remove "ConcurrentRunningVMs" param from config: cMDTBuildLab build maximum to 8 concurrent VMs.
        Tune need count with count of reference Task Sequences in the REF folder
      * Remove cleaning of CustomSettings.ini after build: this is a job for DSC configuration.
        Configure DSCLocalConfigurationManager on MDT server with
            ConfigurationMode = "ApplyAndAutoCorrect"
            ConfigurationModeFrequencyMins = 60
      * Possibility of sending build results to E-mail

.LINK
    http://www.deploymentbunny.com
    https://github.com/pvs043/cMDTBuildLab/wiki
#>

[cmdletbinding(SupportsShouldProcess=$True)]

Param(
    [parameter(mandatory=$false)] 
    [ValidateSet($True,$False)] 
    $UpdateBootImage = $False
)

Function Get-VIARefTaskSequence
{
    Param(
        $RefTaskSequenceFolder
    )
    $RefTaskSequences = Get-ChildItem $RefTaskSequenceFolder

    Foreach ($RefTaskSequence in $RefTaskSequences) {
        New-Object PSObject -Property @{
            TaskSequenceID = $RefTaskSequence.ID
            Name = $RefTaskSequence.Name
            Comments = $RefTaskSequence.Comments
            Version = $RefTaskSequence.Version
            Enabled = $RefTaskSequence.enable
            LastModified = $RefTaskSequence.LastModifiedTime
        }
    }
}

Function Test-VIAHypervConnection
{
    Param(
        $Computername,
        $ISOFolder,
        $VMFolder,
        $VMSwitchName
    )

    #Verify SMB access
    $Result = Test-NetConnection -ComputerName $Computername -CommonTCPPort SMB
    If ($Result.TcpTestSucceeded -eq $true) {Write-Verbose "SMB Connection to $Computername is ok"} else {Write-Warning "SMB Connection to $Computername is NOT ok"; Return $False}

    #Verify WinRM access
    $Result = Test-NetConnection -ComputerName $Computername -CommonTCPPort WINRM
    If ($Result.TcpTestSucceeded -eq $true) {Write-Verbose "WINRM Connection to $Computername is ok"} else {Write-Warning "WINRM Connection to $Computername is NOT ok"; Return $False}

    #Verify that Microsoft-Hyper-V-Management-PowerShell is installed
    Invoke-Command -ComputerName $Computername -ScriptBlock {
        $Result = (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Management-PowerShell)
        Write-Verbose "$($Result.DisplayName) is $($Result.State)"
        If ($($Result.State) -ne "Enabled") {Write-Warning "$($Result.DisplayName) is not Enabled"; Return $False}
    }

    #Verify that Microsoft-Hyper-V-Management-PowerShell is installed
    Invoke-Command -ComputerName $Computername -ScriptBlock {
        $Result = (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V)
        If ($($Result.State) -ne "Enabled") {Write-Warning "$($Result.DisplayName) is not Enabled"; Return $False}
    }

    #Verify that Hyper-V is running
    Invoke-Command -ComputerName $Computername -ScriptBlock {
        $Result = (Get-Service -Name vmms)
        Write-Verbose "$($Result.DisplayName) is $($Result.Status)"
        If ($($Result.Status) -ne "Running") {Write-Warning "$($Result.DisplayName) is not Running"; Return $False}
    }

    #Verify that the ISO Folder is created
    Invoke-Command -ComputerName $Computername -ScriptBlock {
        Param(
            $ISOFolder
        )
        New-Item -Path $ISOFolder -ItemType Directory -Force
    } -ArgumentList $ISOFolder

    #Verify that the VM Folder is created
    Invoke-Command -ComputerName $Computername -ScriptBlock {
        Param(
            $VMFolder
        )
        New-Item -Path $VMFolder -ItemType Directory -Force
    } -ArgumentList $VMFolder

    #Verify that the VMSwitch exists
    Invoke-Command -ComputerName $Computername -ScriptBlock {
        Param(
            $VMSwitchName
        )
        if (((Get-VMSwitch | Where-Object -Property Name -EQ -Value $VMSwitchName).count) -eq "1") {Write-Verbose "Found $VMSwitchName"} else {Write-Warning "No swtch with the name $VMSwitchName found"; Return $False}
    } -ArgumentList $VMSwitchName
    Return $true
}

Function Update-Log
{
    [cmdletbinding(SupportsShouldProcess=$True)]

    Param(
    [Parameter(
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=0
    )]
    [string]$Data,

    [Parameter(
        Mandatory=$false, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=0
    )]
    [string]$Solution = $Solution,

    [Parameter(
        Mandatory=$false, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=1
    )]
    [validateset('Information','Warning','Error')]
    [string]$Class = "Information"

    )
    $LogString = "$Solution, $Data, $Class, $(Get-Date)"
    $HostString = "$Solution, $Data, $(Get-Date)"
    
    Add-Content -Path $Log -Value $LogString
    switch ($Class)
    {
        'Information'{
            Write-Output $HostString -ForegroundColor Gray
            }
        'Warning'{
            Write-Output $HostString -ForegroundColor Yellow
            }
        'Error'{
            Write-Output $HostString -ForegroundColor Red
            }
        Default {}
    }
}

#Inititial Settings
Clear-Host
$Log = "$($PSScriptRoot)\ImageFactoryV3ForHyper-V.log"
$XMLFile = "$($PSScriptRoot)\ImageFactoryV3.xml"
$Solution = "IMF32"
Update-Log -Data "Imagefactory 3.2 (Hyper-V)"
Update-Log -Data "Logfile is $Log"
Update-Log -Data "XMLfile is $XMLfile"

#Importing modules
Update-Log -Data "Importing modules"
Import-Module 'C:\Program Files\Microsoft Deployment Toolkit\Bin\MicrosoftDeploymentToolkit.psd1' -ErrorAction Stop -WarningAction Stop

#Read Settings from XML
Update-Log -Data "Reading from $XMLFile"
[xml]$Settings = Get-Content $XMLFile -ErrorAction Stop -WarningAction Stop

#Verify Connection to DeploymentRoot
Update-Log -Data "Verify Connection to DeploymentRoot"
$Result = Test-Path -Path $Settings.Settings.MDT.DeploymentShare
If ($Result -ne $true) {Update-Log -Data "Cannot access $($Settings.Settings.MDT.DeploymentShare), will break"; break}

#Connect to MDT
Update-Log -Data "Connect to MDT"
$Root = $Settings.Settings.MDT.DeploymentShare
if ( !(Get-PSDrive -Name 'MDTBuild' -ErrorAction SilentlyContinue) ) {
    $MDTPSDrive = New-PSDrive -Name MDTBuild -PSProvider MDTProvider -Root $Root -ErrorAction Stop
    Update-Log -Data "Connected to $($MDTPSDrive.Root)"
}

#Get MDT Settings
Update-Log -Data "Get MDT Settings"
$MDTSettings = Get-ItemProperty 'MDTBuild:'

#Check if we should update the boot image
Update-Log -Data "Check if we should update the boot image"
If($UpdateBootImage -eq $True){
    #Update boot image
    Update-Log -Data "Updating boot image, please wait"
    Update-MDTDeploymentShare -Path MDT: -ErrorAction Stop
}

#Verify access to boot image
Update-Log -Data "Verify access to boot image"
$MDTImage = $($Settings.Settings.MDT.DeploymentShare) + "\boot\" + $($MDTSettings.'Boot.x86.LiteTouchISOName')
if((Test-Path -Path $MDTImage) -eq $true) {Update-Log -Data "Access to $MDTImage is ok"} else {Write-Warning "Could not access $MDTImage"; BREAK}

#Get TaskSequences
Update-Log -Data "Get TaskSequences"
$RefTaskSequences = Get-VIARefTaskSequence -RefTaskSequenceFolder "MDTBuild:\Task Sequences\$($Settings.Settings.MDT.RefTaskSequenceFolderName)" | where-object Enabled -eq $true

#Get TaskSequencesIDs
$RefTaskSequenceIDs = $RefTaskSequences.TasksequenceID
Update-Log -Data "Found $($RefTaskSequenceIDs.count) TaskSequences to work on"

#check task sequence count
if ($RefTaskSequenceIDs.count -eq 0) {
    Update-Log -Data "Sorry, could not find any TaskSequences to work with"
    BREAK
}

#Get detailed info
Update-Log -Data "Get detailed info about the task sequences"
$Result = Get-VIARefTaskSequence -RefTaskSequenceFolder "MDTBuild:\Task Sequences\$($Settings.Settings.MDT.RefTaskSequenceFolderName)" | Where-Object Enabled -eq $true
foreach($obj in ($Result | Select-Object TaskSequenceID,Name,Version)){
    $data = "$($obj.TaskSequenceID) $($obj.Name) $($obj.Version)"
    Update-Log -Data $data
}

#Verify Connection to Hyper-V host
Update-Log -Data "Verify Connection to Hyper-V host"
$Result = Test-VIAHypervConnection -Computername $Settings.Settings.HyperV.Computername -ISOFolder $Settings.Settings.HyperV.ISOLocation -VMFolder $Settings.Settings.HyperV.VMLocation -VMSwitchName $Settings.Settings.HyperV.SwitchName
If ($Result -ne $true) {Update-Log -Data "$($Settings.Settings.HyperV.Computername) is not ready, will break"; break}

#Upload boot image to Hyper-V host
Update-Log -Data "Upload boot image to Hyper-V host"
$DestinationFolder = "\\" + $($Settings.Settings.HyperV.Computername) + "\" + $($Settings.Settings.HyperV.ISOLocation -replace ":","$")
Copy-Item -Path $MDTImage -Destination $DestinationFolder -Force

#Create the VM's on Host
Update-Log -Data "Create the VM's on Host"
Foreach ($Ref in $RefTaskSequenceIDs) {
    $VMName = $ref
    $VMMemory = [int]$($Settings.Settings.HyperV.StartUpRAM) * 1GB
    $VMPath = $($Settings.Settings.HyperV.VMLocation)
    $VMBootimage = $($Settings.Settings.HyperV.ISOLocation) + "\" +  $($MDTImage | Split-Path -Leaf)
    $VMVHDSize = [int]$($Settings.Settings.HyperV.VHDSize) * 1GB
    $VMVlanID = $($Settings.Settings.HyperV.VLANID)
    $VMVCPU = $($Settings.Settings.HyperV.NoCPU)
    $VMSwitch = $($Settings.Settings.HyperV.SwitchName)

    Invoke-Command -ComputerName $($Settings.Settings.HyperV.Computername) -ScriptBlock {
        Param(
            $VMName,
            $VMMemory,
            $VMPath,
            $VMBootimage,
            $VMVHDSize,
            $VMVlanID,
            $VMVCPU,
            $VMSwitch
        )        

        Write-Verbose "Hyper-V host is $env:COMPUTERNAME"
        Write-Verbose "Working on $VMName"
        #Check if VM exist
        if (!((Get-VM | Where-Object -Property Name -EQ -Value $VMName).count -eq 0)) {Write-Warning -Message "VM exist"; Break}

        #Create VM 
        $VM = New-VM -Name $VMName -MemoryStartupBytes $VMMemory -Path $VMPath -NoVHD -Generation 1
        Write-Verbose "$($VM.Name) is created"

        #Disable dynamic memory
        Set-VMMemory -VM $VM -DynamicMemoryEnabled $false
        Write-Verbose "Dynamic memory is disabled on $($VM.Name)"

        #Connect to VMSwitch
        Connect-VMNetworkAdapter -VMNetworkAdapter (Get-VMNetworkAdapter -VM $VM) -SwitchName $VMSwitch
        Write-Verbose "$($VM.Name) is connected to $VMSwitch"

        #Set vCPU
        if ($VMVCPU -ne "1") {
            $Result = Set-VMProcessor -Count $VMVCPU -VM $VM -Passthru
            Write-Verbose "$($VM.Name) has $($Result.count) vCPU"
        }
    
        #Set VLAN
        If ($VMVlanID -ne "0") {
            $Result = Set-VMNetworkAdapterVlan -VlanId $VMVlanID -Access -VM $VM -Passthru
            Write-Verbose "$($VM.Name) is configured for VLANid $($Result.NativeVlanId)"
        }

        #Create empty disk
        $VHD = $VMName + ".vhdx"
        $result = New-VHD -Path "$VMPath\$VMName\Virtual Hard Disks\$VHD" -SizeBytes $VMVHDSize -Dynamic -ErrorAction Stop
        Write-Verbose "$($result.Path) is created for $($VM.Name)"

        #Add VHDx
        $result = Add-VMHardDiskDrive -VMName $VMName -Path "$VMPath\$VMName\Virtual Hard Disks\$VHD" -Passthru
        Write-Verbose "$($result.Path) is attached to $VMName"
    
        #Connect ISO 
        $result = Set-VMDvdDrive -VMName $VMName -Path $VMBootimage -Passthru
        Write-Verbose "$($result.Path) is attached to $VMName"

        #Set Notes
        Set-VM -VMName $VMName -Notes "REFIMAGE"

    } -ArgumentList $VMName,$VMMemory,$VMPath,$VMBootimage,$VMVHDSize,$VMVlanID,$VMVCPU,$VMSwitch
}

#Get BIOS Serialnumber from each VM and update the customsettings.ini file
Update-Log -Data "Get BIOS Serialnumber from each VM and update the customsettings.ini file"
$IniFile = "$($Settings.settings.MDT.DeploymentShare)\Control\CustomSettings.ini"

Foreach($Ref in $RefTaskSequenceIDs) {
    #Get BIOS Serailnumber from the VM
    $BIOSSerialNumber = Invoke-Command -ComputerName $($Settings.Settings.HyperV.Computername) -ScriptBlock {
        Param(
            $VMName
        )
        $VMObject = Get-CimInstance -Namespace root\virtualization\v2 -ClassName Msvm_ComputerSystem | Where-Object {$_.ElementName -eq $VMName}
        (Get-CimAssociatedInstance $VMObject | Where-Object {$_.Caption -eq 'BIOS'}).SerialNumber
    } -ArgumentList $Ref
    
    #Update CustomSettings.ini
    $CustomSettings = Get-Content -Path $IniFile

    $CustomSettings += "
[$BIOSSerialNumber]
OSDComputerName=$Ref
TaskSequenceID=$Ref
BackupFile=#left(""$Ref"", len(""$Ref"")-3) & year(date) & right(""0"" & month(date), 2) & right(""0"" & day(date), 2)#.wim
DoCapture=YES
SkipTaskSequence=YES
SkipCapture=YES"
    Set-Content -Path $IniFile -Value $CustomSettings
}

#Test for CustomSettings.ini changes
#Read-Host -Prompt "Waiting"

#Start VM's on Host
Update-Log -Data "Start VM's on Host"
Foreach ($Ref in $RefTaskSequences) {
    $VMName     = $Ref.TasksequenceID
    $ImageName  = $Ref.Name
    $ReportFrom = $($Settings.Settings.ReportFrom)
    $ReportTo   = $($Settings.Settings.ReportTo)
    $ReportSmtp = $($Settings.Settings.ReportSmtp)

    Invoke-Command -ComputerName $($Settings.Settings.HyperV.Computername) -ScriptBlock {
        param(
            $VMName,
            $ImageName,
            $ReportFrom,
            $ReportTo,
            $ReportSmtp
        )

        Write-Output "Starting VM: $($VmName)"
        Start-VM -Name $VMName
        Start-Sleep 60
        $VM = Get-VM -Name $VMName
        $StartTime = Get-Date
        while ($VM.State -eq "Running") {
           Start-Sleep "90"
           $VM = Get-VM -Name $VMName
        }
        $EndTime = Get-Date
        $ElapsedTime = $EndTime - $StartTime
        $hours = [math]::floor($ElapsedTime.TotalHours)
        $mins = [int]$ElapsedTime.TotalMinutes - $hours*60
        $report = "Image [$ImageName] was builded at $hours h. $mins min."
        Write-Output $report

        # Send Report
            If ($ReportFrom -and $ReportTo -and $ReportSmtp) {
            $subject = "Image $ImageName"
            $encoding = [System.Text.Encoding]::UTF8
            Send-MailMessage -From $ReportFrom -To $ReportTo -Subject $subject -SmtpServer $ReportSmtp -Encoding $encoding -BodyAsHtml $report
        }

        # Remove reference VM
        Write-Output "Deleting $($VM.Name) on $($VM.Computername) at $($VM.ConfigurationLocation)"
        Remove-VM -VM $VM -Force
        Remove-Item -Path $VM.ConfigurationLocation -Recurse -Force

    } -ArgumentList $VMName,$ImageName,$ReportFrom,$ReportTo,$ReportSmtp -AsJob -JobName $VMName
}
