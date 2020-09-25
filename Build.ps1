$moduleName     = "cMDTBuildLab"
$moduleGuid     = "df45de26-88b1-4a95-98af-b798fde1424f"
$year           = (Get-Date).Year
$moduleVersion  = "3.0.0"
$releaseNotes  = "
* Remove Windows 8.1/2012 R2 deployment description from documentation. Windows 7 SP1 Deployment is still available for very old systems
* Remove Windows 8.1 desktop customization from code and prerequisites
* Remove WMF 5.1 from prerequisites
* Remove Servicing stack update for Windows 7 SP1 from prerequisites
* Update download URLs for MDT
* Update ADK (v.2004)
* Tested with latest Windows 10 Version 2004 (May 2020) and Windows Server 2019
"
$allResources   = @( Get-ChildItem -Path $PSScriptRoot\src\DSCResources\*.psm1 -ErrorAction SilentlyContinue -Recurse | Sort-Object)
$allFunctions   = @( Get-ChildItem -Path $PSScriptRoot\src\Public\*.ps1 -ErrorAction SilentlyContinue -Recurse | Sort-Object)
$buildDir       = "C:\Projects"
$combinedModule = "$BuildDir\$moduleName\$ModuleName.psm1"
$manifestFile   = "$BuildDir\$moduleName\$ModuleName.psd1"
[string]$dscResourcesToExport = $null

$ensureDefiniton = @"
enum Ensure
{
    Present
    Absent
}


"@

# Init module script
[string]$combinedResources = $ensureDefiniton

# Prepare DSC resources
Foreach ($resource in @($allResources)) {
    Write-Output "Add Resource: $resource"
    Try {
        $resourceContent = Get-Content $resource -Raw -Encoding UTF8
        $combinedResources += $resourceContent.Substring($resourceContent.IndexOf("[DscResource()]"))

        if ($resourceContent -match 'class\s*(?<ClassName>\w*)[\r\t]') {
            foreach ($match in $Matches.ClassName) {
                [string]$dscResourcesToExport += "'$match',"
            }
        }
    }
    Catch {
        throw $_
    }
}

# Prepare Functions
Foreach ($function in @($allFunctions)) {
    Write-Output "Add Function: $function"
    Try {
        $functionContent = Get-Content $function -Raw
        $combinedResources += $functionContent.Substring($functionContent.IndexOf("Function"))    
    }
    Catch {
        throw $_
    }
}

# Prepare Manifest
$dscResourcesToExport = $dscResourcesToExport.TrimEnd(",")
$ManifestDefinition = @"
@{

# Script module or binary module file associated with this manifest.
RootModule = '$moduleName.psm1'

DscResourcesToExport = @($dscResourcesToExport)

FunctionsToExport  = @('Import-MDTModule','Invoke-ExpandArchive','Invoke-RemovePath','Invoke-TestPath','Get-ConfigurationData')

# Version number of this module.
ModuleVersion = '$moduleVersion'

# ID used to uniquely identify this module
GUID = '$moduleGuid'

# Author of this module
Author = 'Pavel Andreev'

# Company or vendor of this module
CompanyName = ''

# Copyright statement for this module
Copyright = '(c) $Year Pavel Andreev. All rights reserved.'

# Description of the functionality provided by this module
Description = 'A DSC Module to help automize deployment Windows Reference Images on MDT Server'

# Project site link
HelpInfoURI = 'https://github.com/pvs043/cMDTBuildLab/wiki'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.1'

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @('cNtfsAccessControl',
@{ModuleName = 'xSmbShare'; ModuleVersion = '2.0.0.0';}
)

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('DesiredStateConfiguration', 'DSC', 'DSCResource', 'MDT', 'MicrosoftDeploymentToolkit', 'Deploy')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/pvs043/cMDTBuildLab/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/pvs043/cMDTBuildLab'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = '$releaseNotes'
    } # End of PSData hashtable

} # End of PrivateData hashtable

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''
}
"@

# Create Build dir
If (Test-Path -Path "$buildDir\$moduleName") { Remove-Item -Path "$buildDir\$moduleName" -Recurse -Force}
$null = New-Item -ItemType Directory -Path "$buildDir\$moduleName"

# Build module from sources
Set-Content -Path $combinedModule -Value $combinedResources
Set-Content -Path $manifestFile -Value $ManifestDefinition
Copy-Item   -Path "$PSScriptRoot\src\cMDTBuildLabPrereqs.psd1" -Destination "$BuildDir\$moduleName\cMDTBuildLabPrereqs.psd1" -Force

# Add artefacts
Copy-Item -Path "$PSScriptRoot\src\Deploy"   -Destination "$BuildDir\$moduleName\Deploy" -Recurse -Force
Copy-Item -Path "$PSScriptRoot\src\Examples" -Destination "$BuildDir\$moduleName\Examples" -Recurse -Force
Copy-Item -Path "$PSScriptRoot\src\Sources"  -Destination "$BuildDir\$moduleName\Sources" -Recurse -Force
Copy-Item -Path "$PSScriptRoot\src\Tests"    -Destination "$BuildDir\$moduleName\Tests" -Recurse -Force
Copy-Item -Path "$PSScriptRoot\README.md"    -Destination "$BuildDir\$moduleName\Readme.md" -Force
Copy-Item -Path "$PSScriptRoot\LICENSE"      -Destination "$BuildDir\$moduleName\LICENSE" -Force
