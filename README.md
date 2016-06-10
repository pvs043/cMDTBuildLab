# cMDTBuildLab

cMDTBuildLab is a Powershell Module to help automize deployment Windows Reference Images on MDT Server with Desired State Configuration.<p>
cMDTBuildLab is a fork from cMDT module (https://github.com/addlevel/cMDT) by info@addlevel.se (c)

### Version
0.0.5

### Tech

Prerequisites for infrastructure:
*	Domain Controller: DC01 (Windows 2012 R2)
*	Windows Update Server (WSUS): WU01 (Windows 2012 R2)
*	Deployment server: MDT01 (Windows 2012 R2/Windows 8.1)<br>
   Disk C: - System<br>
   Disk E: - DATA<br>
   (Disk D: is used for Temp in Azure or Virtual DVD for on-premise deploy)
*	Hyper-V Host: HV01 (Windows 2012 R2/Windows 8.1)

cMDTBuildLab uses a number of components and open resource kit modules. The following are prerequisites for the module and need to be installed to the inteded deployment server (MDT01):
* [.Net3.5] - .Net Framewework 3.5
* [WMF5] (http://aka.ms/wmf5latest) - Windows Management Framework 5.0
* [xSmbShare] (http://www.powershellgallery.com/packages/xSmbShare/) - DSC Module available from Powershell Gallery<br>
  ```powershell
  Install-Module -Name xSmbShare
  ```
* [PowerShellAccessControl] (https://gallery.technet.microsoft.com/scriptcenter/PowerShellAccessControl-d3be7b83#content) - DSC Module available from Technet Gallery.<br>
  Copy it to %ProgramFiles%\WindowsPowerShell\Modules\PowerShellAccessControl folder.

The following prerequisites can automatically be downloaded with the cMDTBuildLab Module:
* [MicrosoftDeploymentToolkit2013_x64] (https://download.microsoft.com/download/3/0/1/3012B93D-C445-44A9-8BFB-F28EB937B060/MicrosoftDeploymentToolkit2013_x64.msi) - Microsoft Deployment Toolkit (MDT) 2013 Update 2 (6.3.8330.1000)
* [adksetup] (http://download.microsoft.com/download/3/8/B/38BBCA6A-ADC9-4245-BCD8-DAA136F63C8B/adk/adksetup.exe) - Windows Assessment and Deployment Kit (10.1.10586.0)
* [Visual C++ runtimes] (https://support.microsoft.com/ru-ru/kb/2977003) (2005,2008,2010,2012,2013,2015)
* [Microsoft Silverlight 5] (https://www.microsoft.com/getsilverlight/Get-Started/Install/Default.aspx)
* [Windows Management Framewework 3.0] (https://www.microsoft.com/en-us/download/details.aspx?id=34595)

This tool included to module (Sources directory):
* devcon.exe: tool from [Windows Driver Kit] (https://msdn.microsoft.com/en-us/windows/hardware/hh852365)

### Installation

To install the cMDTBuildLab Module from the Powershell Gallery:

```powershell
Find-Module cMDTBuildLab | Install-Module
```

### Quick start
You can use this module with a pull server, an SMB share or a local file repository. The following quick start example use a local file repository. We recommend that you create a Checkpoint/Snapshot of the test deployment server after the initial prerequisites and sourcefiles have been installed/copied.

1. Make sure you have installed all prerequisites.
2. Install the cMDTBuildLab module on the test deployment server:

``` powershell
 Install-Module cMDTBuildLab
 ```
3. Create a source directory (E:\Source). If you use another driveletter and patch you need to edit the configuration file: (Deploy_MDT_Server_ConfigurationData.psd1)
4. Copy install.wim file from a Windows 10 media to C:\Sources and rename the file to install_1.0.0.0.wim
5. Copy the Zip-files PEExtraFiles_1.0.0.0.zip and Scripts_1.0.0.0.zip from the Powershell cMDT Module install directory (C:\Program Files\WindowsPowerShell\Modules\adl_MDT\1.0.0.0\Sources) to the C:\Sources directory. 
5. Run Powershell ISE as Administrator and open the file: C:\Program Files\WindowsPowerShell\Modules\cMDT\1.0.0.0\Examples\Deploy_MDT_Server.ps1
6. Press F5 to run the script. It will take approximately 30 min (Depending on internet capacity and virtualization hardware). The server will reboot ones during this process.

### DscResources

The cMDTBuildLab Module contain the following DscResources:

* cMDTBuildApplication
* cMDTBuildBootstrapIni
* cMDTBuildCustomize
* cMDTBuildCustomSettingsIni
* cMDTBuildDirectory
* cMDTBuildOperatingSystem
* cMDTBuildPersistentDrive
* cMDTBuildPreReqs
* cMDTBuildTaskSequence
* cMDTBuildUpdateBootImage
 
#### cMDTApplication
cMDTApplication is a DscResource that enables download, import of and lifecycle management of applications in MDT. Applications can be updated and retrieved from a pull server according to Desired State Configuration principles.

Available parameters with example:
* [Ensure] - Present/Absent
* [Version] - Version number
* [Name] - Name
* [Path] - MDT path
* [Enabled] - True/False
* [ShortName] - Shortname
* [Publisher] - Publisher information
* [Language] - Language
* [CommandLine] - Command Line file
* [WorkingDirectory] - Working directory
* [ApplicationSourcePath] - Web link, SMB or local path
* [DestinationFolder] - Destination folder in MDT
* [TempLocation] - Tenmporary download location
* [PSDriveName] - The PSDrive name for the MDT deployment share
* [PSDrivePath] - The physical path to the MDT deployment share

The DscResource will import applications according to the following principle:
* Verify status present or absent
* If present:
    * Append version number to the ApplicationSourcePath together with a .zip extension
    * Verify if the application already exist in MDT, and if determine version
    * If the application does not exist or version number not matched the application will be downloaded
    * The application will be extracted from the Zip archive and imported in to the MDT
* If absent:
    * If application exist it will be removed

Desired State Configuration job example:
```sh
cMDTApplication Teamviewer {
    Ensure = "Present"
    Version = "1.0.0.1"
    Name = "Teamviewer"
    Path = "DS001:\Applications\Core Applications"
    Enabled = "True"
    ShortName = "Teamviewer"
    Publisher = "Teamviewer"
    Language = "en-US"
    CommandLine = "install.cmd"
    WorkingDirectory = ".\"
    ApplicationSourcePath = "$($SourcePath)/TeamViewer_Setup_sv"
    DestinationFolder = "Teamviewer"
    TempLocation = $TempLocation
    PSDriveName = $PSDriveName
    PSDrivePath = $PSDrivePath
}
```

#### cMDTBootstrapIni
cMDTBootstrapIni is a DscResource that enables configuration and lifecycle management of the BootStrap.ini in MDT. This file can be updated and managed from a pull server according to Desired State Configuration principles.

Available parameters with example:
* [Ensure] - Present/Absent
* [Path] - MDT path
* [Content] - True/False

The DscResource will manage the content of this file according to the following principle:
* Verify status present or absent
* If present:
    * Verify content of the local BootStrap.ini file with the configuration in the contract
    * Apply changes if necessary
* If absent:
    *  If absent BootStrap.ini will ve reverted to default state 

Desired State Configuration job example:
```sh
cMDTBootstrapIni ini {
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

;Keyboard Layout
KeyboardLocalePE=041d:0000041d
"@
}
```

#### cMDTCustomize
cMDTCustomize is a DscResource that enables management of custom settings, additional folders and scripts with lifecycle management for MDT. The files can be updated and retrieved from a pull server according to Desired State Configuration principles.

Available parameters with example:
* [Ensure] - Present/Absent
* [Version] - Version number
* [Name] - Name
* [Path] - MDT path
* [SourcePath] - Web link, SMB or local path
* [TempLocation] - Temporary download location
* [Protected] - Protected mode ensures that if even if Ensure is set to Absent the existing folder will not be removed.

The DscResource will import custom settings files and directories according to the following principle:
* Verify status present or absent
* If present:
    * Append version number to the ApplicationSourcePath together with a .zip extension,
    * Verify if the defined folder already exist in MDT, and if determine version
    * If the folder does not exist or version number do not match the zip will be downloaded
    * The zip will be extracted from the archive in to the MDT
* If absent:
    * If the folder has not been defined as protected it will be removed

Desired State Configuration job example:
```sh
cMDTCustomize PEExtraFiles {
    Ensure = "Present"
    Version = "1.0.0.0"
    Name = "PEExtraFiles"
    Path = $PSDrivePath
    SourcePath = "$($SourcePath)/PEExtraFiles"
    TempLocation = $TempLocation
}
cMDTCustomize Scripts {
    Ensure = "Present"
    Version = "1.0.0.0"
    Name = "Scripts"
    Path = $PSDrivePath
    SourcePath = "$($SourcePath)/Scripts"
    TempLocation = $TempLocation
    Protected = $true
}
```

#### cMDTCustomSettingsIni
cMDTCustomSettingsIni is a DscResource that enables configuration and lifecycle management of the CustomSettings.ini in MDT. This file can be updated and managed from a pull server according to Desired State Configuration principles.

Available parameters with example:
* [Ensure] - Present/Absent
* [Path] - MDT path
* [Content] - True/False

The DscResource will manage the content of this file according to the following principle:
* Verify status present or absent
* If present:
    * Verify content of the local BootStrap.ini file with the configuration in the contract
    * Apply changes if necessary
* If absent:
    * If absent CustomSettings.ini will ve reverted to default state 

Desired State Configuration job example:
```sh
cMDTCustomSettingsIni ini {
    Ensure = "Present"
    Path = "$($PSDrivePath)\Control\CustomSettings.ini"
    Content = @"
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
AdminPassword=C@ang3Me!
SLShare=%DeployRoot%\Logs

OrgName=Company
Home_Page=http://companyURL

;Enable or disable options:
SkipAdminPassword=NO
SkipApplications=YES
SkipBitLocker=NO
SkipCapture=YES
SkipComputerBackup=YES
SkipComputerName=NO
SkipDomainMembership=NO
SkipFinalSummary=NO
SkipLocaleSelection=NO
SkipPackageDisplay=YES
SkipProductKey=YES
SkipRoles=YES
SkipSummary=NO
SkipTimeZone=NO
SkipUserData=YES
SkipTaskSequence=NO

;DomainJoin
JoinDomain=ad.company.net
DomainAdmin=DomainJoinAccount
DomainAdminDomain=ad.company.net
DomainAdminPassword=DomainJoinAccountPassword
MachineObjectOU=OU=Clients,OU=company,DC=ad,DC=company,DC=net

;TimeZone settings
TimeZoneName=W. Europe Standard Time

WSUSServer=http://fqdn:port

;Example keyboard layout.
UserLocale=en-US
KeyboardLocale=en-US
UILanguage=en-US

;Drivers
DriverSelectionProfile=Nothing

;DriverInjectionMode=ALL

FinishAction=RESTART
"@
}
```

#### cMDTBuildDirectory
cMDTDirectory is a DscResource that enables management of folder structures with lifecycle management for MDT. These folders can be managed from a pull server according to Desired State Configuration principles.

Available parameters with example:
* [Ensure] - Present/Absent
* [Name] - Name of folder
* [Path] - MDT path
* [PSDriveName] - The PSDrive name for the MDT deployment share
* [PSDrivePath] - The physical path to the MDT deployment share

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

#### cMDTOperatingSystem
cMDTOperatingSystem is a DscResource that enables download, import of and lifecycle management of Operating System WIM files in MDT. These files can be updated and retrieved from a pull server according to Desired State Configuration principles.

Available parameters with example:
* [Ensure] - Present/Absent
* [Version] - Version number (optional)
* [Name] - Name
* [Path] - MDT path
* [SourcePath] - Web link, SMB or local path
* [TempLocation] - Tenmporary download location
* [PSDriveName] - The PSDrive name for the MDT deployment share
* [PSDrivePath] - The physical path to the MDT deployment share

The DscResource will import Operating Systems according to the following principle:
* Verify status present or absent
* If present:
    * If version is defined, appends version number to the SourcePath together with a .wim extension
    * If version is not defined, download checksum version information from the pull server. The checksum file needs to be named as image file name and ".version"; ex: REFW10X64.version.
    * Verify if the Operating System already exist in MDT, and if determine version
    * If the Operating System does not exist or version number do not matched the Operating System WIM file will be downloaded
    * If the Operating System does not exist the WIM file will be imported in to the MDT, if the Operating System do exist and upgrade mode is determined the WIM file will be copied in to the appropriate MDT directory path
* If absent:
    * The operating system will be removed

Desired State Configuration job example:
```sh
cMDTOperatingSystem Win10x64 {
    Ensure = "Present"
    Version = "1.0.0.0"
    Name = "Windows 10 Enterprise x64"
    Path = "DS001:\Operating Systems\Windows 10"
    SourcePath = "$($SourcePath)/REFW10X64"
    TempLocation = $TempLocation
    PSDriveName = $PSDriveName
    PSDrivePath = $PSDrivePath
}
```

#### cMDTPersistentDrive
cMDTPersistentDrive is a DscResource that enables management of MDT persistent drives with lifecycle management for MDT. These folders can be managed from a pull server according to Desired State Configuration principles.

Available parameters with example:
* [Ensure] - Present/Absent
* [Name] - Name of drive
* [Path] - MDT path
* [Description] - A description of the drive
* [NetworkPath] - Network share name of the MDT persistent drive

The DscResource will manage MDT folders according to the following principle:
* Verify status present or absent
* If present:
    * Check if the defined persistent drive exist in MDT
    * If the persistent drive does not exist it will be created
* If absent:
    * The persistent drive will be removed

Desired State Configuration job example:
```sh
cMDTPersistentDrive DeploymentPSDrive {
    Ensure = "Present"
    Name = $PSDriveName
    Path = $PSDrivePath
    Description = "Deployment Share"
    NetworkPath = "\\$ComputerName\DeploymentShare$"
}
```

#### cMDTBuildPreReqs
cMDTBuildPreReqs is a DscResource that enables download of prerequisites for MDT server deployment. Prerequisites can be defined and managed from a pull server according to Desired State Configuration principles.

Available parameters with example:
* [Ensure] - Present/Absent
* [DownloadPath] - Download path for binaries

The DscResource will import applications according to the following principle:
* Check if prerequisites exist in the DownloadPath
* If they do not exist the prerequisites will be downloaded over the internet from Microsoft directly

Desired State Configuration job example:
```sh
cMDTPreReqs MDTPreReqs {
    Ensure = "Present"            
    DownloadPath = "$(SourcePath)"
}
```

#### cMDTTaskSequence
cMDTTaskSequence is a DscResource that enables management of Task Sequences with lifecycle management for MDT. Task Sequences can be defined and managed from a pull server according to Desired State Configuration principles.

Available parameters with example:
* [Ensure] - Present/Absent
* [Name] - Name of drive
* [Path] - MDT path
* [OperatingSystemPath] - MDT path
* [WIMFileName] - Name of Operating System WIM file to create Task Sequence for. Overrides OperatingSystemPath Parameter.
* [ID] - MDT path
* [PSDriveName] - MDT path
* [PSDrivePath] - MDT path

The DscResource will import applications according to the following principle:
* Verify status present or absent
* If present:
    * Check if Task Sequence exist in the MDT path
    * If it does not exist the Task Sequence will be created
* If absent:
    * The Task Sequence will be removed

Note: The Operating System WIM file must exist in the OperatingSystemPath for the Task Sequence to be created correctly.

Desired State Configuration job example:
```sh
cMDTTaskSequence Win10x64 {
    Ensure = "Present"
    Name = "Windows 10 x64"
    Path = "DS001:\Task Sequences\Windows 10"
    #OperatingSystemPath = "DS001:\Operating Systems\Windows 10\REFW10X64DDrive in Windows 10 Enterprise x64 REFW10X64.wim"
    WIMFileName = "REFW10X64"    
    ID = "01"
    PSDriveName = $PSDriveName
    PSDrivePath = $PSDrivePath
}
```

#### cMDTUpdateBootImage
cMDTUpdateBootImage is a DscResource that enables creation and management of boot images with lifecycle management for MDT. Boot images can be defined and managed from a pull server according to Desired State Configuration principles.

Available parameters with example:
* [Version] - Version number
* [PSDeploymentShare] - Name of drive
* [Force] - MDT path
* [Compress] - MDT path
* [DeploymentSharePath] - MDT path

The DscResource will import applications according to the following principle:
* Verify if the boot image exist in MDT, and if determine version
* If the boot image does not exist or version number do not match a boot image will be created

Desired State Configuration job example:
```sh
cMDTUpdateBootImage updateBootImage {
    Version = "1.0.0.0"
    PSDeploymentShare = $PSDriveName
    Force = $true
    Compress = $true
    DeploymentSharePath = $PSDrivePath
}
```

### Development

Want to contribute? Great!

E-mail us with any changes, questions or suggestions: pvs043@outlook.com

License
----

**MIT**

### Respects

[Johan Arwidmark] (http://deploymentresearch.com/Research): Deployment Research
[Mikael Nystrom] (https://anothermike2.wordpress.com): The Deployment Bunny
[Jason Helmick] (https://twitter.com/theJasonHelmick), [Jeffrey Snover] (https://twitter.com/@jsnover):
[1. Getting Started with PowerShell Desired State Configuration (DSC)] (https://mva.microsoft.com/en-US/training-courses/getting-started-with-powershell-desired-state-configuration-dsc--8672?l=ZwHuclG1_2504984382). ([Rus] (https://mva.microsoft.com/ru/training-courses/-powershell-dsc--8672?l=dlwgB3wFB_1704984382))
[2. Advanced PowerShell Desired State Configuration (DSC) and Custom Resources] (https://mva.microsoft.com/en-US/training-courses/advanced-powershell-desired-state-configuration-dsc-and-custom-resources-8702?l=3DnsS2H1_1504984382)

 
### Reference

[Create a Windows 10 reference image] (https://technet.microsoft.com/itpro/windows/deploy/create-a-windows-10-reference-image)<br>
[Back to Basics - Building a Windows 7 SP1 Reference Image using MDT 2013 Update 2] (http://deploymentresearch.com/Research/Post/521/Back-to-Basics-Building-a-Windows-7-SP1-Reference-Image-using-MDT-2013-Update-2)<br>
[Building reference images like a boss!] (http://deploymentresearch.com/Research/Post/357/Building-reference-images-like-a-boss)<br>
[PowerShell is King – Building a Reference Image Factory] (https://deploymentbunny.com/2014/01/06/powershell-is-king-building-a-reference-image-factory)<br>
[The battle begins - Building the perfect reference image for ConfigMgr 2012] (http://deploymentresearch.com/Research/Post/431/The-battle-begins-Building-the-perfect-reference-image-for-ConfigMgr-2012)
