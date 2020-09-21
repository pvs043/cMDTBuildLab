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
            Path       = "$($Node.SourcePath)\ADK\adksetup.exe"
            ProductId  = "9346016b-6620-4841-8ea4-ad91d3ea02b5"
            Arguments  = "/Features OptionId.DeploymentTools /norestart /quiet /ceip off"
            ReturnCode = 0
        }

        Package WinPE {
            Ensure     = "Present"
            Name       = "Windows Assessment and Deployment Kit Windows Preinstallation Environment Add-ons - Windows 10"
            Path       = "$($Node.SourcePath)\WindowsPE\adkwinpesetup.exe"
            ProductId  = "353df250-4ecc-4656-a950-4df93078a5fd"
            Arguments  = "/Features OptionId.WindowsPreinstallationEnvironment /norestart /quiet /ceip off"
            ReturnCode = 0
        }

        Package MDT {
            Ensure     = "Present"
            Name       = "Microsoft Deployment Toolkit (6.3.8456.1000)"
            Path       = "$($Node.SourcePath)\MDT\MicrosoftDeploymentToolkit_x64.msi"
            ProductId  = "2E6CD7B9-9D00-4B04-882F-E6971BC9A763"
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
