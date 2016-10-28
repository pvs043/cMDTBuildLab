Configuration Download-MDTPrereqs
{
    Import-Module -Name PSDesiredStateConfiguration, cMDTBuildLab
    Import-DscResource –ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cMDTBuildLab

    node $AllNodes.Where{$_.Role -match "MDT Server"}.NodeName
    {
        LocalConfigurationManager  
        {
            RebootNodeIfNeeded = $AllNodes.RebootNodeIfNeeded
            ConfigurationMode  = $AllNodes.ConfigurationMode   
        }

        cMDTBuildPreReqs MDTPreReqs {
            Ensure       = "Present"            
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
            ProductId  = "39ebb79f-797c-418f-b329-97cfdf92b7ab"
            Arguments  = "/quiet /features OptionId.DeploymentTools OptionId.WindowsPreinstallationEnvironment"
            ReturnCode = 0
        }

        Package MDT {
            Ensure     = "Present"
            Name       = "Microsoft Deployment Toolkit 2013 Update 2 (6.3.8330.1000)"
            Path       = "$($Node.SourcePath)\Microsoft Deployment Toolkit\MicrosoftDeploymentToolkit2013_x64.msi"
            ProductId  = "F172B6C7-45DD-4C22-A5BF-1B2C084CADEF"
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
Download-MDTPrereqs -OutputPath "$PSScriptRoot\Download-MDTPrereqs" -ConfigurationData $ConfigurationData

#Set DSC LocalConfigurationManager
Set-DscLocalConfigurationManager -Path "$PSScriptRoot\Download-MDTPrereqs" -Verbose

#Start DSC MOF job
Start-DscConfiguration -Wait -Force -Verbose -ComputerName "$env:computername" -Path "$PSScriptRoot\Download-MDTPrereqs"

#Set data deduplication
Enable-DedupVolume -Volume "E:"
Set-DedupVolume -Volume "E:" -MinimumFileAgeDays 3

Write-Output ""
Write-Output "Download MDT Prereqs is completed!"
