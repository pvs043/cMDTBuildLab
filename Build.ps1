$moduleName     = "cMDTBuildLab"
$moduleGuid     = "df45de26-88b1-4a95-98af-b798fde1424f"
$year           = (Get-Date).Year
$moduleVersion  = "2.4.0"
$releaseNotes  = "
* Update Servicing stack update for Windows 7 SP1 (KB3177467) to V2. Do not forget to delete KB3177467-x64 and KB3177467-x86 folders at E:\Source before upgrade
* Update to WinPE v.1809 (Build: 10.1.17763.1). Do not forget uninstall previous version of ADK before upgrade and delete E:\Source\Windows Assessment and Deployment Kit folder
* Update Microsoft Deployment Toolkit (6.3.8456.1000)
* Rename E:\Source\Microsoft Deployment Toolkit to E:\Source\MDT
* Add support for Windows 2019
* Use script by @NickolajA for remove default Windows 10 apps
* Add TargetPath parameter to cMDTBuildCustomize class. Do not forget change Deploy_MDT_Server.ps1 script
"
$allResources   = @( Get-ChildItem -Path $PSScriptRoot\src\DSCResources\*.psm1 -ErrorAction SilentlyContinue -Recurse | Sort-Object)
$allFunctions   = @( Get-ChildItem -Path $PSScriptRoot\src\Public\*.ps1 -ErrorAction SilentlyContinue -Recurse | Sort-Object)
$buildDir       = "C:\Projects"
$combinedModule = "$BuildDir\Build\$moduleName\$ModuleName.psm1"
$manifestFile   = "$BuildDir\Build\$moduleName\$ModuleName.psd1"
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
PowerShellVersion = '5.0'

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
If (Test-Path -Path "$buildDir\Build") { Remove-Item -Path "$buildDir\Build" -Recurse -Force}
$null = New-Item -ItemType Directory -Path "$buildDir\Build\$moduleName"

# Build module from sources
Set-Content -Path $combinedModule -Value $combinedResources
Set-Content -Path $manifestFile -Value $ManifestDefinition
Copy-Item   -Path "$PSScriptRoot\src\cMDTBuildLabPrereqs.psd1" -Destination "$BuildDir\Build\$moduleName\cMDTBuildLabPrereqs.psd1" -Force

# Add artefacts
Copy-Item -Path "$PSScriptRoot\src\Deploy"   -Destination "$BuildDir\Build\$moduleName\Deploy" -Recurse -Force
Copy-Item -Path "$PSScriptRoot\src\Examples" -Destination "$BuildDir\Build\$moduleName\Examples" -Recurse -Force
Copy-Item -Path "$PSScriptRoot\src\Sources"  -Destination "$BuildDir\Build\$moduleName\Sources" -Recurse -Force
Copy-Item -Path "$PSScriptRoot\src\Tests"    -Destination "$BuildDir\Build\$moduleName\Tests" -Recurse -Force
Copy-Item -Path "$PSScriptRoot\README.md"    -Destination "$BuildDir\Build\$moduleName\Readme.md" -Force
Copy-Item -Path "$PSScriptRoot\LICENSE"      -Destination "$BuildDir\Build\$moduleName\LICENSE" -Force
