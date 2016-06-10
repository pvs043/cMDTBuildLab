<#     
    ************************************************************************************************************ 
    Purpose:    Remove built in apps specified in list 
    Pre-Reqs:    Windows 8.1 
    ************************************************************************************************************ 
#>

#--------------------------------------------------------------------------------------------------------------- 
# Main Routine 
#---------------------------------------------------------------------------------------------------------------

# Get log path. Will log to Task Sequence log folder if the script is running in a Task Sequence 
# Otherwise log to \windows\temp

try
{
    $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
    $logPath = $tsenv.Value("LogPath")
}
catch
{
    Write-Host "This script is not running in a task sequence"
    $logPath = $env:windir + "\temp"
}

$logFile = "$logPath\$($myInvocation.MyCommand).log"

# Start logging
Start-Transcript $logFile
Write-Host "Logging to $logFile"

# List of Applications that will be removed
$AppsList = "microsoft.windowscommunicationsapps","Microsoft.BingFinance","Microsoft.BingMaps",`
"Microsoft.ZuneVideo","Microsoft.ZuneMusic","Microsoft.Media.PlayReadyClient.2",`
"Microsoft.XboxLIVEGames","Microsoft.HelpAndTips","Microsoft.BingSports",`
"Microsoft.BingFoodAndDrink","Microsoft.BingTravel","Microsoft.WindowsReadingList",`
"Microsoft.BingHealthAndFitness","Microsoft.Reader","Microsoft.WindowsScan",`
"Microsoft.WindowsSoundRecorder","Microsoft.SkypeApp"

ForEach ($App in $AppsList)
{
    $Packages = Get-AppxPackage -AllUsers | Where-Object {$_.Name -eq $App}
    if ($Packages -ne $null)
    {
        Write-Host "Removing Appx Package: $App"
        foreach ($Package in $Packages)
        {
            Remove-AppxPackage -package $Package.PackageFullName
        }
    }
    else
    {
        Write-Host "Unable to find package: $App"
    }
    
    $ProvisionedPackage = Get-AppxProvisionedPackage -online | Where-Object {$_.displayName -eq $App}
    if ($ProvisionedPackage -ne $null)
    {
        Write-Host "Removing Appx Provisioned Package: $App"
        remove-AppxProvisionedPackage -online -packagename $ProvisionedPackage.PackageName
    }
    else
    {
        Write-Host "Unable to find provisioned package: $App"
    }

}

# Stop logging
Stop-Transcript
