# cMDTBuildLab

cMDTBuildLab is a Powershell Module to help automize deployment Windows Reference Images on MDT Server with Desired State Configuration.<p>
cMDTBuildLab is a fork from cMDT module (https://github.com/servicedudes/cmdt).

### Version
0.7.3

See version history at [Project Site] (https://github.com/pvs043/cMDTBuildLab/wiki/Version-History)

### Tech

Prerequisites for infrastructure:
* Domain Controller: DC01 (Windows 2012 R2 or above)
* Windows Update Server (WSUS): WU01 (Windows 2012 R2 or above)
* Deployment server: MDT01 (Windows 2012 R2 + WMF 5.0 or Windows 2016)<br>
    Disk C: - System<br>
    Disk E: - DATA<br>
    (Disk D: is used for Temp in Azure or Virtual DVD for on-premise deploy)
* Hyper-V Host: HV01 (Windows 2012 R2 or above)

This module is tested on Windows 2016 server, but it will be worked on Windows 10 or Windows 2012 R2/Windows 8.1 with Windows Management Framewework 5.0.

cMDTBuildLab uses a number of components and open resource kit modules. The following are prerequisites for the module and need to be installed to the inteded deployment server (MDT01):
* [WMF5] (http://aka.ms/wmf5latest) - Windows Management Framework 5.0 (for windows 2012 R2/Windows 8.1 host only).
* [xSmbShare] (http://www.powershellgallery.com/packages/xSmbShare/) - DSC Module available from Powershell Gallery<br>
  ```powershell
  Install-Module -Name xSmbShare
  ```
* [cNtfsAccessControl] (http://www.powershellgallery.com/packages/cNtfsAccessControl/) - DSC Module available from Powershell Gallery.<br>
  ```powershell
  Install-Module -Name cNtfsAccessControl
  ```

The following prerequisites automatically downloaded with the cMDTBuildPreReqs DSC resource:
* [MicrosoftDeploymentToolkit2013_x64] (https://www.microsoft.com/en-us/download/details.aspx?id=50407) - Microsoft Deployment Toolkit (MDT) 2013 Update 2 (6.3.8330.1000)
* [adksetup] (https://developer.microsoft.com/en-us/windows/hardware/windows-assessment-deployment-kit) - Windows Assessment and Deployment Kit 10, v.1607 (10.1.14393.0)
* [Visual C++ runtimes] (https://support.microsoft.com/en-us/kb/2977003) - 2005,2008,2010,2012,2013,2015
* [Microsoft Silverlight 5] (https://www.microsoft.com/getsilverlight/Get-Started/Install/Default.aspx)
* [Windows Management Framewework 3.0] (https://www.microsoft.com/en-us/download/details.aspx?id=34595)
* [Windows Management Framewework 5.0] (http://aka.ms/wmf5latest)
* [Servicing stack update for Windows 7 SP1] (https://support.microsoft.com/en-us/kb/3177467)
* [Convenience rollup update for Windows 7 SP1] (https://support.microsoft.com/en-us/kb/3125574)
* [Cumulative update for Windows 10 Version 1607 and Windows Server 2016: November 8, 2016] (https://support.microsoft.com/en-us/kb/3200970)

If your MDT01 host does not have direct connection to Internet, run DSC configuration from Examples\Download_MDT_Prereqs.ps1 at Windows machine connected to Internet. After completion of downloading run E:\Source\Windows Assessment and Deployment Kit\adksetup.exe for download ADK. Then copy E:\Source to production server.

This extra files included to module (\Sources\Extra.zip):
* devcon.exe: tool from [Windows Driver Kit] (https://msdn.microsoft.com/en-us/library/windows/hardware/ff544707(v=vs.85).aspx).
* KVP (Key Value Pair Exchange) driver for WinPE. This extracted from VMGuest.iso image on Hyper-V host (\support\x86\Windows6.x-HyperVIntegrationServices-x86.cab).

Note for APP-V 5.1 client:<p>
This module include *fake* archive Sources\appv_client_setup.zip.<p>
If you have Microsoft Software Assurance subscription, take original client of APP-V 5.1 (appv_client_setup.exe) from MDOP 2015 and place into this ZIP file.<p>
This archive will be unpack to source folder with cMDTBuildPreReqs DSC resource.

### Quick start
See [Project Documentation] (https://github.com/pvs043/cMDTBuildLab/wiki/Quick-Start).

### DscResources

The cMDTBuildLab Module contain the following DscResources:

* [cMDTBuildApplication](https://github.com/pvs043/cMDTBuildLab/wiki/cMDTBuildApplication)
* [cMDTBuildBootstrapIni](https://github.com/pvs043/cMDTBuildLab/wiki/cMDTBuildBootstrapIni)
* [cMDTBuildCustomize](https://github.com/pvs043/cMDTBuildLab/wiki/cMDTBuildCustomize)
* [cMDTBuildCustomSettingsIni](https://github.com/pvs043/cMDTBuildLab/wiki/cMDTBuildCustomSettingsIni)
* [cMDTBuildDirectory](https://github.com/pvs043/cMDTBuildLab/wiki/cMDTBuildDirectory)
* [cMDTBuildOperatingSystem](https://github.com/pvs043/cMDTBuildLab/wiki/cMDTBuildOperatingSystem)
* [cMDTBuildPackage](https://github.com/pvs043/cMDTBuildLab/wiki/cMDTBuildPackage)
* [cMDTBuildPersistentDrive](https://github.com/pvs043/cMDTBuildLab/wiki/cMDTBuildPersistentDrive)
* [cMDTBuildPreReqs](https://github.com/pvs043/cMDTBuildLab/wiki/cMDTBuildPreReqs)
* [cMDTBuildSelectionProfile](https://github.com/pvs043/cMDTBuildLab/wiki/cMDTBuildSelectionProfile)
* [cMDTBuildTaskSequence](https://github.com/pvs043/cMDTBuildLab/wiki/cMDTBuildTaskSequence)
* [cMDTBuildTaskSequenceCustomize](https://github.com/pvs043/cMDTBuildLab/wiki/cMDTBuildTaskSequenceCustomize)
* [cMDTBuildUpdateBootImage](https://github.com/pvs043/cMDTBuildLab/wiki/cMDTBuildUpdateBootImage)

### Development

Want to contribute? Great!

E-mail me with any changes, questions or suggestions: pvs043@outlook.com

License
----

**MIT**

### Respects

[Johan Arwidmark] (http://deploymentresearch.com/Research): Deployment Research<br>
[Mikael Nystrom] (https://anothermike2.wordpress.com): The Deployment Bunny<br>
[Jason Helmick] (https://twitter.com/theJasonHelmick), [Jeffrey Snover] (https://twitter.com/@jsnover):<br>
[1. Getting Started with PowerShell Desired State Configuration (DSC)] (https://mva.microsoft.com/en-US/training-courses/getting-started-with-powershell-desired-state-configuration-dsc--8672?l=ZwHuclG1_2504984382). ([Rus] (https://mva.microsoft.com/ru/training-courses/-powershell-dsc--8672?l=dlwgB3wFB_1704984382))<br>
[2. Advanced PowerShell Desired State Configuration (DSC) and Custom Resources] (https://mva.microsoft.com/en-US/training-courses/advanced-powershell-desired-state-configuration-dsc-and-custom-resources-8702?l=3DnsS2H1_1504984382)
