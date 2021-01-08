# cMDTBuildLab

cMDTBuildLab is a Powershell Module to help automize deployment Windows Reference Images on MDT Server with Desired State Configuration.<p>
cMDTBuildLab is a fork from [cMDT module](https://github.com/servicedudes/cmdt).

## Releases

### GitHub master branch
[![Build status][appveyor-badge-master]][appveyor-build-master]
This is the branch containing the latest release, published at PowerShell Gallery.

### GitHub dev branch
[![Build status][appveyor-badge-dev]][appveyor-build-dev]
This is the development branch with latest changes.

### PowerShell Gallery
[![PowerShell Gallery Version][psgallery-version-badge]][psgallery]
[![PowerShell Gallery Downloads][psgallery-badge]][psgallery]
Official repository - latest module version and download count.

## Version
3.0.0

See version history at [Project Site](https://github.com/pvs043/cMDTBuildLab/wiki/Version-History)

## Tech

Prerequisites for infrastructure:
* Domain Controller: DC01 (Windows 2012 R2 or above)
* Windows Update Server (WSUS): WU01 (Windows 2012 R2 or above)
* Deployment server: MDT01 (Windows 2016/2019)<br>
    Disk C: - System<br>
    Disk E: - DATA<br>
    (Disk D: is used for Temp in Azure or Virtual DVD for on-premise deploy)
* Hyper-V Host: HV01 (Windows 2012 R2 or above)
* Original Microsoft media (ISO) images:<br>
    Windows 10 Version 20H2 (October 2020)<br>
    Windows 2016 (February 2018)<br>
    Windows 2019 (April 2019)

This module is tested on Windows 2016/2019 server, but it will be worked on Windows 10 or Windows 2012 R2/Windows 8.1 + WMF 5.1.

The following prerequisites automatically downloaded with the cMDTBuildPreReqs DSC resource:
* [MicrosoftDeploymentToolkit_x64](https://docs.microsoft.com/en-us/sccm/mdt/) - Microsoft Deployment Toolkit (MDT) (Build 6.3.8456.1000)
* [ADK & WinPE v.2004](https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install) - Windows PE, v.2004 (Build: 10.1.19041.1)
* [Visual C++ runtimes](https://support.microsoft.com/en-us/kb/2977003) - 2008,2010,2012,2013,2017
* [Windows Management Framewework 3.0 for Windows 7 SP1](https://www.microsoft.com/en-us/download/details.aspx?id=34595)
* [Convenience rollup update for Windows 7 SP1](https://support.microsoft.com/en-us/kb/3125574)
* [July 2016 update rollup for Windows 7 SP1](https://support.microsoft.com/en-us/kb/3172605) - this include fixes the Windows Update Client

If your MDT01 host does not have direct connection to Internet, run DSC configuration from Deploy\Download_MDT_Prereqs.ps1 at Windows machine connected to Internet.
After completion of downloading:
* Run E:\Source\ADK\adksetup.exe. Select E:\Source\ADK for download folder
* Run E:\Source\WindowsPE\adkwinpesetup.exe. Select E:\Source\WindowsPE for download folder

Note for APP-V 5.1 (Windows 7) client:<p>
This module include *fake* archive Sources\appv_client_setup.zip.<p>
If you have Microsoft Software Assurance subscription, take original client of APP-V 5.1 (appv_client_setup.exe) from MDOP 2015 and place into this ZIP file.<p>
This archive will be unpack to source folder with cMDTBuildPreReqs DSC resource.

## Quick start
See [Project Documentation](https://github.com/pvs043/cMDTBuildLab/wiki/Quick-Start).

## DscResources

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

## Development

Want to contribute? Great!

Requiest for the new features at [GitHub](https://github.com/pvs043/cMDTBuildLab/issues).<br>
Thanks to Community: [Issue](https://github.com/pvs043/cMDTBuildLab/issues) and [Pull Requests](https://github.com/pvs043/cMDTBuildLab/pulls)

## Respects

[Johan Arwidmark](http://deploymentresearch.com/Research): Deployment Research<br>
[Mikael Nystrom](https://anothermike2.wordpress.com): The Deployment Bunny<br>
[Jason Helmick](https://twitter.com/theJasonHelmick), [Jeffrey Snover](https://twitter.com/@jsnover)<br>

## License

**Free usage**

[appveyor-badge-master]: https://ci.appveyor.com/api/projects/status/h8qth51otb888a7v?branch=master&svg=true
[appveyor-build-master]: https://ci.appveyor.com/project/pvs043/cmdtbuildlab/branch/master?fullLog=true
[appveyor-badge-dev]: https://ci.appveyor.com/api/projects/status/h8qth51otb888a7v?branch=dev&svg=true
[appveyor-build-dev]: https://ci.appveyor.com/project/pvs043/cmdtbuildlab/branch/dev?fullLog=true
[psgallery-badge]: https://img.shields.io/powershellgallery/dt/cmdtbuildlab.svg
[psgallery]: https://www.powershellgallery.com/packages/cmdtbuildlab
[psgallery-version-badge]: https://img.shields.io/powershellgallery/v/cmdtbuildlab.svg
[psgallery-version]: https://www.powershellgallery.com/packages/cmdtbuildlab
