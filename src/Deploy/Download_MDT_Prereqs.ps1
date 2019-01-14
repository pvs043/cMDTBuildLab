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
        Package WinPE {
            Ensure     = "Present"
            Name       = "Windows PE x86 x64"
            Path       = "$($Node.SourcePath)\WindowsPE\adkwinpesetup.exe"
            ProductId  = "351E5003-D07A-441B-02D1-045CEB797F30"
            Arguments  = "/Features OptionId.WindowsPreinstallationEnvironment /norestart /quiet /ceip off"
            ReturnCode = 0
        }

        Package MDT {
            Ensure     = "Present"
            Name       = "Microsoft Deployment Toolkit (6.3.8450.1000)"
            Path       = "$($Node.SourcePath)\MDT\MicrosoftDeploymentToolkit_x64.msi"
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
