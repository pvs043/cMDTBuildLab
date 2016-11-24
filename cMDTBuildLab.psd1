@{

# Script module or binary module file associated with this manifest.
RootModule = 'cMDTBuildLab.psm1'

DscResourcesToExport = @('cMDTBuildApplication','cMDTBuildBootstrapIni','cMDTBuildCustomize','cMDTBuildCustomSettingsIni','cMDTBuildDirectory','cMDTBuildOperatingSystem','cMDTBuildPackage','cMDTBuildPersistentDrive','cMDTBuildPreReqs','cMDTBuildSelectionProfile','cMDTBuildTaskSequence','cMDTBuildTaskSequenceCustomize','cMDTBuildUpdateBootImage')

#CmdletsToExport     = @('Import-MicrosoftDeploymentToolkitModule','Invoke-ExpandArchive','Invoke-RemovePath','Invoke-TestPath')
FunctionsToExport  = @('Import-MicrosoftDeploymentToolkitModule','Invoke-ExpandArchive','Invoke-RemovePath','Invoke-TestPath')

# Version number of this module.
ModuleVersion = '0.8.0'

# ID used to uniquely identify this module
GUID = 'df45de26-88b1-4a95-98af-b798fde1424f'

# Author of this module
Author = 'Pavel Andreev'

# Company or vendor of this module
CompanyName = ''

# Copyright statement for this module
Copyright = '(c) 2016 Pavel Andreev. All rights reserved.'

# Description of the functionality provided by this module
Description = 'A DSC Module to help automize deployment Windows Reference Images on MDT Server'

# Project site link
HelpInfoURI = 'https://github.com/pvs043/cMDTBuildLab/wiki'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.0'

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @('xSmbShare', 'cNtfsAccessControl')

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('DesiredStateConfiguration', 'DSC', 'DSCResource', 'MDT', 'Deploy')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/pvs043/cMDTBuildLab/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/pvs043/cMDTBuildLab'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = '
 * Bugfix: Rename script Install-MicrosoftVisualC++x86x64.wsf with Install-MicrosoftVisualCx86x64.wsf
 * Add script ImageFactoryV3-Build.ps1 by Mikael Nystrom for build Reference Images directly from MDT server with remote Powershell access to Hyper-V host
 * Install Windows Update Client for Windows 7 (KB3138612) before scan updates
 * Install July 2016 update rollup for Windows 8.1 and Windows Server 2012 R2 (KB3172614) before scan updates: fix for Windows Update Client
 * Add Windows 2016 support to Install Roles and Features TS customize
'
    } # End of PSData hashtable

} # End of PrivateData hashtable

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''
}
