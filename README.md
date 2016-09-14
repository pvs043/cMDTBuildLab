# cMDTBuildLab

cMDTBuildLab is a Powershell Module to help automize deployment Windows Reference Images on MDT Server with Desired State Configuration.<p>
cMDTBuildLab is a fork from cMDT module (https://github.com/addlevel/cMDT) by info@addlevel.se (c)

### Version
0.3.0

### Tech

Prerequisites for infrastructure:
* Domain Controller: DC01 (Windows 2012 R2)
* Windows Update Server (WSUS): WU01 (Windows 2012 R2)
* Deployment server: MDT01 (Windows 2012 R2/Windows 8.1)<br>
    Disk C: - System<br>
    Disk E: - DATA<br>
    (Disk D: is used for Temp in Azure or Virtual DVD for on-premise deploy)
* Hyper-V Host: HV01 (Windows 2012 R2/Windows 8.1)

cMDTBuildLab uses a number of components and open resource kit modules. The following are prerequisites for the module and need to be installed to the inteded deployment server (MDT01):
* [.NET3.5] - .NET Framewework 3.5
* [WMF5] (http://aka.ms/wmf5latest) - Windows Management Framework 5.0
* [xSmbShare] (http://www.powershellgallery.com/packages/xSmbShare/) - DSC Module available from Powershell Gallery<br>
  ```powershell
  Install-Module -Name xSmbShare
  ```
* [PowerShellAccessControl] (https://gallery.technet.microsoft.com/scriptcenter/PowerShellAccessControl-d3be7b83#content) - DSC Module available from Technet Gallery.<br>
  Copy it to %ProgramFiles%\WindowsPowerShell\Modules\PowerShellAccessControl folder.

The following prerequisites automatically downloaded with the cMDTBuildLab Module:
* [MicrosoftDeploymentToolkit2013_x64] (https://www.microsoft.com/en-us/download/details.aspx?id=50407) - Microsoft Deployment Toolkit (MDT) 2013 Update 2 (6.3.8330.1000)
* [adksetup] (https://developer.microsoft.com/en-us/windows/hardware/windows-assessment-deployment-kit) - Windows Assessment and Deployment Kit 10, v.1607 (10.1.14393.0)
* [Visual C++ runtimes] (https://support.microsoft.com/en-us/kb/2977003) (2005,2008,2010,2012,2013,2015)
* [Microsoft Silverlight 5] (https://www.microsoft.com/getsilverlight/Get-Started/Install/Default.aspx)
* [Windows Management Framewework 3.0] (https://www.microsoft.com/en-us/download/details.aspx?id=34595)
* [Windows Management Framewework 5.0] (http://aka.ms/wmf5latest)

This extra files included to module (\Sources\Extra.zip):
* devcon.exe: tool from [Windows Driver Kit] (https://msdn.microsoft.com/en-us/windows/hardware/hh852365)
* KVP (Key Value Pair Exchange) driver for WinPE. This extracted from VMGuest.iso image on Hyper-V host (\support\x86\Windows6.x-HyperVIntegrationServices-x86.cab).

### Installation

To install the cMDTBuildLab Module from the Powershell Gallery:

```powershell
Install-Module cMDTBuildLab
```

### Quick start
You can use this module with a pull server, an SMB share or a local file repository. The following quick start example use a local file repository. We recommend that you create a Checkpoint/Snapshot of the test deployment server after the initial prerequisites and sourcefiles have been installed/copied.

1. Make sure you have installed all prerequisites.
2. Install the cMDTBuildLab module on the test deployment server.
3. Create a source directory (E:\Source). If you use another driveletter and patch you need to edit the configuration file (Deploy_MDT_Server_ConfigurationData.psd1)
4. Create subfolders under E:\Source and copy content from official Windows ISO to it:
   * Windows7x86
   * Windows7x64
   * Windows81x86
   * Windows81x64
   * Windows10x86
   * Windows10x64
   * Windows2012R2
   * Windows2016TP5
5. Run Powershell ISE as Administrator and open the file:<br>
   C:\Program Files\WindowsPowerShell\Modules\cMDTBuldLab\1.0.0\Examples\Deploy_MDT_Server.ps1
6. Press F5 to run the script. It will take approximately 30 min (Depending on internet capacity and virtualization hardware). The server will reboot ones during this process.

### DscResources

The cMDTBuildLab Module contain the following DscResources:

* <b>cMDTBuildApplication</b>
* <b>cMDTBuildBootstrapIni</b>
* <b>cMDTBuildCustomize</b>
* <b>cMDTBuildCustomSettingsIni</b>
* <b>cMDTBuildDirectory</b>
* <b>cMDTBuildOperatingSystem</b>
* <b>cMDTBuildPersistentDrive</b>
* <b>cMDTBuildPreReqs</b>
* <b>cMDTBuildTaskSequence</b>
* <b>cMDTBuildTaskSequenceCustomize</b>
* <b>cMDTBuildUpdateBootImage</b>
 
#### cMDTBuildApplication
cMDTBuildApplication is a DscResource that enables import applications in MDT. Applications downloaded before with cMDTBuildPreReqs DscResource.

Available parameters:
* <b>[Ensure]</b> - Present/Absent
* <b>[Name]</b> - Application name
* <b>[Path]</b> - MDT path
* <b>[Enabled]</b> - True/False
* <b>[CommandLine]</b> - Install command line
* <b>[ApplicationSourcePath]</b> - Folder under $SourcePath
* <b>[PSDriveName]</b> - The PSDrive name for the MDT deployment share
* <b>[PSDrivePath]</b> - The physical path to the MDT deployment share

The DscResource will import applications according to the following principle:
* Verify status present or absent
* If present:
    * Verify if the application already exist in MDT
    * If the application does not exist the application will be imported
* If absent:
    * If application exist it will be removed

Desired State Configuration job example:
```sh
cMDTBuildApplication WMF5 {
    Ensure = "Present"
    Name = "Install - Windows Management Framework 5.0 - x64"
    Path = "\Applications\Core\Microsoft"
    CommandLine = "wusa.exe Win8.1AndW2K12R2-KB3134758-x64.msu /quiet /norestart"
    ApplicationSourcePath = "WMF50x64"
    Enabled = "True"
    PSDriveName = $PSDriveName
    PSDrivePath = $PSDrivePath
}
```

#### cMDTBuildBootstrapIni
cMDTBootstrapIni is a DscResource that enables configuration and lifecycle management of the BootStrap.ini in MDT.

Available parameters with example:
* <b>[Ensure]</b> - Present/Absent
* <b>[Path]</b> - MDT path
* <b>[Content]</b> - INI file content

The DscResource will manage the content of this file according to the following principle:
* Verify status present or absent
* If present:
    * Verify content of the local BootStrap.ini file with the configuration in the contract
    * Apply changes if necessary
* If absent:
    *  If absent BootStrap.ini will ve reverted to default state 

Desired State Configuration job example:
```sh
cMDTBuildBootstrapIni ini {
    Ensure = "Present"
    Path = "$($PSDrivePath)\Control\Bootstrap.ini"
    Content = @"
[Settings]
Priority=Default

[Default]
DeployRoot=\\$($ComputerName)\DeploymentShare$
SkipBDDWelcome=YES

;MDT Connect Account
UserID=$($UserName)
UserPassword=$($Password)
UserDomain=$($env:COMPUTERNAME)
"@
}
```

#### cMDTBuildCustomize
cMDTBuildCustomize is a DscResource that enables management of custom settings, additional folders and scripts with lifecycle management for MDT.

Available parameters with example:
* <b>[Ensure]</b> - Present/Absent
* <b>[Name]</b> - Name of zip archive
* <b>[Path]</b> - MDT path
* <b>[SourcePath]</b> - Folder under $SourcePath
* <b>[TestFiles]</b> - File names into zip archive

The DscResource will import custom settings files and directories according to the following principle:
* Verify status present or absent
* If present:
    * Extract files from zip archive to MDT folder
* If absent:
    * The folder will be removed

Desired State Configuration job example:
```sh
cMDTBuildCustomize PEExtraFiles {
    Ensure = "Present"
    Name = "PEExtraFiles"
    Path = $PSDrivePath
    SourcePath = "$($SourcePath)/PEExtraFiles"
	TestFiles = @("Script1.vbs", "Script2.vbs")
}
```

#### cMDTBuildCustomSettingsIni
cMDTBuildCustomSettingsIni is a DscResource that enables configuration and lifecycle management of the CustomSettings.ini in MDT.

Available parameters with example:
* <b>[Ensure]</b> - Present/Absent
* <b>[Path]</b> - MDT path
* <b>[Content]</b> - INI file content

The DscResource will manage the content of this file according to the following principle:
* Verify status present or absent
* If present:
    * Verify content of the local BootStrap.ini file with the configuration in the contract
    * Apply changes if necessary
* If absent:
    * If absent CustomSettings.ini will ve reverted to default state 

Desired State Configuration job example:
```sh
cMDTBuildCustomSettingsIni ini {
    Ensure = "Present"
    Path = "$($PSDrivePath)\Control\CustomSettings.ini"
    Content = @"
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
BackupShare=\\$($ComputerName)\DeploymentShare$
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
```

#### cMDTBuildDirectory
cMDTBuildDirectory is a DscResource that enables management of folder structures with lifecycle management for MDT. These folders can be managed from a pull server according to Desired State Configuration principles.

Available parameters:
* <b>[Ensure]</b> - Present/Absent
* <b>[Name]</b> - Name of folder
* <b>[Path]</b> - MDT path
* <b>[PSDriveName]</b> - The PSDrive name for the MDT deployment share
* <b>[PSDrivePath]</b> - The physical path to the MDT deployment share

The DscResource will manage MDT folders according to the following principle:
* Verify status present or absent
* If present:
    * Check if defined folder exists in MDT
    * If the folder does not exist the folder will be created
* If absent:
    * The folder will be removed

Desired State Configuration job example:
```sh
cMDTBuildDirectory Windows10 {
    Ensure = "Present"
    Name = "Windows 10"
    Path = "DS001:\Operating Systems"
    PSDriveName = $PSDriveName
    PSDrivePath = $PSDrivePath
}
```

#### cMDTBuildOperatingSystem
cMDTBuildOperatingSystem is a DscResource that import of Operating Systems source files in MDT.

Available parameters:
* <b>[Ensure]</b> - Present/Absent
* <b>[Name]</b> - Name
* <b>[Path]</b> - MDT path
* <b>[SourcePath]</b> - Source path to content of Windows ISO distribution
* <b>[PSDriveName]</b> - The PSDrive name for the MDT deployment share
* <b>[PSDrivePath]</b> - The physical path to the MDT deployment share

The DscResource will import Operating Systems according to the following principle:
* Verify status present or absent
* If present:
    * Verify if the Operating System already exist in MDT
	* If OS not exist, import from SourcePath
* If absent:
    * The operating system will be removed

Desired State Configuration job example:
```sh
cMDTBuildOperatingSystem Win10x64 {
    Ensure = "Present"
    Name = "Windows 10 x64"
    Path = "Windows 10"
    SourcePath = "$SourcePath\Windows10x64"
    PSDriveName = $PSDriveName
    PSDrivePath = $PSDrivePath
}
```

#### cMDTBuildPersistentDrive
cMDTBuildPersistentDrive is a DscResource that enables management of MDT persistent drives with lifecycle management for MDT. These folders can be managed from a pull server according to Desired State Configuration principles.

Available parameters:
* <b>[Ensure]</b> - Present/Absent
* <b>[Name]</b> - Name of drive
* <b>[Path]</b> - MDT path
* <b>[Description]</b> - A description of the drive
* <b>[NetworkPath]</b> - Network share name of the MDT persistent drive

The DscResource will manage MDT folders according to the following principle:
* Verify status present or absent
* If present:
    * Check if the defined persistent drive exist in MDT
    * If the persistent drive does not exist it will be created
* If absent:
    * The persistent drive will be removed

Desired State Configuration job example:
```sh
cMDTBuildPersistentDrive DeploymentPSDrive {
    Ensure = "Present"
    Name = $PSDriveName
    Path = $PSDrivePath
    Description = "MDT Build Share"
    NetworkPath = "\\$ComputerName\DeploymentShare$"
}
```

#### cMDTBuildPreReqs
cMDTBuildPreReqs is a DscResource that enables download of prerequisites for MDT server deployment. Prerequisites can be defined and managed from a pull server according to Desired State Configuration principles.

Available parameters:
* <b>[Ensure]</b> - Present/Absent
* <b>[DownloadPath]</b> - Download path for binaries

The DscResource will import applications according to the following principle:
* Check if prerequisites exist in the DownloadPath
* If they do not exist the prerequisites will be downloaded over the internet from Microsoft directly

Desired State Configuration job example:
```sh
cMDTBuildPreReqs MDTPreReqs {
    Ensure = "Present"            
    DownloadPath = "$SourcePath"
}
```

#### cMDTBuildTaskSequence
cMDTBuildTaskSequence is a DscResource that enables management of Task Sequences with lifecycle management for MDT.

Available parameters:
* <b>[Ensure]</b> - Present/Absent
* <b>[Name]</b> - Name of Task Sequence
* <b>[Path]</b> - MDT folder for Task Sequence
* <b>[OSName]</b> - MDT path and name for OS image, imported with cMDTBuildOperatingSystem resource
* <b>[Template]</b> - Client.xml / Server.xml
* <b>[ID]</b> - Task Sequence ID
* <b>[OrgName]</b> - Organization Name of Windows Reference Image
* <b>[PSDriveName]</b> - The PSDrive name for the MDT deployment share
* <b>[PSDrivePath]</b> - The physical path to the MDT deployment share

The DscResource will create Task Sequences according to the following principle:
* Verify status present or absent
* If present:
    * Check if Task Sequence exist in the MDT path
    * If it does not exist the Task Sequence will be created
* If absent:
    * The Task Sequence will be removed

Note: The Operating System must exist in the OSName path for the Task Sequence to be created correctly.

Desired State Configuration job example:
```sh
cMDTBuildTaskSequence Win10x64 {
    Ensure      = "Present"
    Name        = "Windows 10 x64"
    Path        = "Windows 10"
    OSName      = "Windows 10\Windows 10 Enterprise in Windows 10 x64 install.wim"
    OrgName     = "BuildLab"
	Template    = "Client.xml"
    ID          = "REFW10X64-001"
    PSDriveName = $PSDriveName
    PSDrivePath = $PSDrivePath
}
```

#### cMDTBuildTaskSequenceCustomize
cMDTBuildTaskSequenceCusomize is a DscResource that enables add custom steps for Task Sequences with lifecycle management for MDT.

Available parameters:
* <b>[TSFile]</b> - Task Sequence File Name
* <b>[Name]</b> - Step/Group Name
* <b>[NewName]</b> - New Step/Group Name
* <b>[Type]</b> - Step Type
* <b>[GroupName]</b> - Main Group for Step/Group
* <b>[SubGroup]</b> - Subgroup Group for Step/Group
* <b>[Disable]</b> - "true" / "false"
* <b>[AddAfter]</b> - Add this Step/Group after that Step
* <b>[OSName]</b> - "Windows 7" / "Windows 8.1" / "Windows 10" / "Windows 2012 R2"
* <b>[OSFeatures]</b> - OS Features
* <b>[Command]</b> - Command line for 'Run Command line' step
* <b>[PSDriveName]</b> - The PSDrive name for the MDT deployment share
* <b>[PSDrivePath]</b> - The physical path to the MDT deployment share

The DscResource add/change the group or step into existing Task Sequence.

Desired State Configuration job example:
```sh
$TSFile = "$($PSDrivePath)\Control\$($TSID)\ts.xml"

cMDTBuildTaskSequenceCustomize AddFeatures {
	TSFile      = $TSFile
	Name        = "Install - Microsoft NET Framework 3.5.1"
	Type        = "Install Roles and Features"
	GroupName   = "State Restore"
	SubGroup    = "Custom Tasks (Pre-Windows Update)"
	OSName      = "Windows 10"
	OSFeatures  = "NetFx3,TelnetClient"
    PSDriveName = $Node.PSDriveName
    PSDrivePath = $Node.PSDrivePath
				}
```
See more complex example in "/Examples" folder of this project.

#### cMDTBuildUpdateBootImage
cMDTBuildUpdateBootImage is a DscResource that enables creation and management of boot images with lifecycle management for MDT.

Available parameters:
* <b>[Version]</b> - Version number
* <b>[PSDeploymentShare]</b> - Name of MDT drive
* <b>[Force]</b> - true/false
* <b>[Compress]</b> - true/false
* <b>[DeploymentSharePath]</b> - MDT path
* <b>[ExtraDirectory]</b> - Extra Directory to add in WinPE
* <b>[BackgroundFile]</b> - WinPE Background picture
* <b>[LiteTouchWIMDescription]</b> - WinPE image description

The DscResource will import applications according to the following principle:
* Verify if the boot image exist in MDT, and if determine version
* If the boot image does not exist or version number do not match a boot image will be created

Desired State Configuration job example:
```sh
cMDTBuildUpdateBootImage updateBootImage {
    Version = "1.0"
    PSDeploymentShare = $PSDriveName
    Force = $true
    Compress = $true
    DeploymentSharePath = $PSDrivePath
    ExtraDirectory = "Extra"
    BackgroundFile = "%INSTALLDIR%\Samples\Background.bmp"
    LiteTouchWIMDescription = "MDT Build Lab"
}
```

### Development

Want to contribute? Great!

E-mail us with any changes, questions or suggestions: pvs043@outlook.com

License
----

**MIT**

### Respects

[Johan Arwidmark] (http://deploymentresearch.com/Research): Deployment Research<br>
[Mikael Nystrom] (https://anothermike2.wordpress.com): The Deployment Bunny<br>
[Jason Helmick] (https://twitter.com/theJasonHelmick), [Jeffrey Snover] (https://twitter.com/@jsnover):<br>
[1. Getting Started with PowerShell Desired State Configuration (DSC)] (https://mva.microsoft.com/en-US/training-courses/getting-started-with-powershell-desired-state-configuration-dsc--8672?l=ZwHuclG1_2504984382). ([Rus] (https://mva.microsoft.com/ru/training-courses/-powershell-dsc--8672?l=dlwgB3wFB_1704984382))<br>
[2. Advanced PowerShell Desired State Configuration (DSC) and Custom Resources] (https://mva.microsoft.com/en-US/training-courses/advanced-powershell-desired-state-configuration-dsc-and-custom-resources-8702?l=3DnsS2H1_1504984382)
 
### Reference

[Create a Windows 10 reference image] (https://technet.microsoft.com/itpro/windows/deploy/create-a-windows-10-reference-image)<br>
[Back to Basics - Building a Windows 7 SP1 Reference Image using MDT 2013 Update 2] (http://deploymentresearch.com/Research/Post/521/Back-to-Basics-Building-a-Windows-7-SP1-Reference-Image-using-MDT-2013-Update-2/)<br>
[Building reference images like a boss] (http://deploymentresearch.com/Research/Post/357/Building-reference-images-like-a-boss/)<br>
[PowerShell is King: Building a Reference Image Factory] (https://deploymentbunny.com/2014/01/06/powershell-is-king-building-a-reference-image-factory/)<br>
[The battle begins - Building the perfect reference image for ConfigMgr 2012] (http://deploymentresearch.com/Research/Post/431/The-battle-begins-Building-the-perfect-reference-image-for-ConfigMgr-2012)
