Configuration DownloadMDTPrereqs
{
    Import-Module -Name PSDesiredStateConfiguration, cMDTBuildLab
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cMDTBuildLab

    node $AllNodes.Where{$_.Role -match "MDT Server"}.NodeName
    {
        LocalConfigurationManager {
            RebootNodeIfNeeded = $AllNodes.RebootNodeIfNeeded
            ConfigurationMode  = $AllNodes.ConfigurationMode   
        }

        cMDTBuildPreReqs MDTPreReqs {
            DownloadPath = $Node.SourcePath
        }

        WindowsFeature  DataDeduplication {
            Ensure = "Present"
            Name   = "FS-Data-Deduplication"
        }

<#
        Package ADK {
            Ensure     = "Present"
            Name       = "Windows Assessment and Deployment Kit - Windows 10"
            Path       = "$($Node.SourcePath)\Windows Assessment and Deployment Kit\adksetup.exe"
            ProductId  = "d794748d-72e9-45d7-9ab7-83d6c4c80f7f"
            Arguments  = "/quiet /features OptionId.DeploymentTools OptionId.WindowsPreinstallationEnvironment"
            ReturnCode = 0
        }

        Package MDT {
            Ensure     = "Present"
            Name       = "Microsoft Deployment Toolkit (6.3.8450.1000)"
            Path       = "$($Node.SourcePath)\Microsoft Deployment Toolkit\MicrosoftDeploymentToolkit_x64.msi"
            ProductId  = "38D2CBE2-862C-4C39-8D65-A4C1C2220160"
            ReturnCode = 0
        }
#>
    }
}

#Set configuration data
$ConfigurationData = @{
    AllNodes = 
    @(
        @{
            #Global Settings for the configuration of Desired State Local Configuration Manager:
            NodeName                    = "*"
            RebootNodeIfNeeded          = $true
            ConfigurationMode           = "ApplyOnly"      
        },
        @{
            #Node Settings for the configuration of an MDT Server:
            NodeName           = "$env:computername"
            Role               = "MDT Server"
            #Sources for download/Prereqs
            SourcePath         = "E:\Source"
        }
    )
}

#Create DSC MOF job
DownloadMDTPrereqs -OutputPath "$PSScriptRoot\DownloadMDTPrereqs" -ConfigurationData $ConfigurationData

#Set DSC LocalConfigurationManager
Set-DscLocalConfigurationManager -Path "$PSScriptRoot\DownloadMDTPrereqs" -Verbose

#Start DSC MOF job
Start-DscConfiguration -Wait -Force -Verbose -ComputerName "$env:computername" -Path "$PSScriptRoot\DownloadMDTPrereqs"

#Set data deduplication
Enable-DedupVolume -Volume "E:"
Set-DedupVolume -Volume "E:" -MinimumFileAgeDays 1

Write-Output ""
Write-Output "Download MDT Prereqs is completed!"
