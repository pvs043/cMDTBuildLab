#
# cMDTBuildPreReqs is a DscResource that enables download of prerequisites for MDT server deployment.
# Prerequisites can be defined and managed from a pull server according to Desired State Configuration principles.
#

enum Ensure
{
    Absent
    Present
}

[DscResource()]
class cMDTBuildPreReqs
{

    [DscProperty(Mandatory)]
    [Ensure]$Ensure
    
    [DscProperty(Key)]
    [string]$DownloadPath

    [DscProperty(NotConfigurable)]
    [hashtable]
    $downloadFiles = @{
        MDT = "https://download.microsoft.com/download/3/0/1/3012B93D-C445-44A9-8BFB-F28EB937B060/MicrosoftDeploymentToolkit2013_x64.msi"  #Version: MDT 2013 Update 2 (Build: 6.3.8330.1000)
        ADK = "http://download.microsoft.com/download/3/8/B/38BBCA6A-ADC9-4245-BCD8-DAA136F63C8B/adk/adksetup.exe"                         #Version: Windows 10 (Build: 10.1.10586.0)
    }
    
    [void] Set()
    {
        Write-Verbose "Starting Set MDT PreReqs..."

        if ($this.ensure -eq [Ensure]::Present)
        {
            $present = $this.TestDownloadPath()

            if ($present){
                Write-Verbose "   Download folder present!"
            }
            else{
                New-Item -Path $this.DownloadPath -ItemType Directory -Force
            }

            [string]$separator = ""
            If ($this.DownloadPath -like "*/*")
            { $separator = "/" }
            Else
            { $separator = "\" }
            
            #Set all files:               
            ForEach ($file in $this.downloadFiles)
            {
                if($file.MDT){                     
                    if(Test-Path -Path "$($this.DownloadPath)\Microsoft Deployment Toolkit"){
                        Write-Verbose "   MDT already present!"
                    }
                    Else{
                        Write-Verbose "   Creating MDT folder..."
                        New-Item -Path "$($this.DownloadPath)\Microsoft Deployment Toolkit" -ItemType Directory -Force
                        $this.WebClientDownload($file.MDT, "$($this.DownloadPath)\Microsoft Deployment Toolkit\MicrosoftDeploymentToolkit2013_x64.msi")
                    }
                }

                if($file.ADK){                     
                    if(Test-Path -Path "$($this.DownloadPath)\Windows Assessment and Deployment Kit"){
                        Write-Verbose "   ADK folder already present!"
                    }
                    Else{
                        Write-Verbose "   Creating ADK folder..."
                        New-Item -Path "$($this.DownloadPath)\Windows Assessment and Deployment Kit" -ItemType Directory -Force
                        $this.WebClientDownload($file.ADK,"$($this.DownloadPath)\Windows Assessment and Deployment Kit\adksetup.exe")
                        #Run setup to prepp files...
                    }
                }
            }            
        }
        else
        {
            $this.RemoveDirectory("")
        }

        Write-Verbose "MDT PreReqs set completed!"
    }

    [bool] Test()
    {
        Write-Verbose "Testing MDT PreReqs..."
        $present = $this.TestDownloadPath()

        if ($this.ensure -eq [Ensure]::Present)
        {            
            Write-Verbose "   Testing for download path.."            
            if($present){
                Write-Verbose "   Download path found!"}            
            Else{
                Write-Verbose "   Download path not found!"
                return $present }

            ForEach ($File in $this.downloadFiles)
            {
               if($file.MDT){
                 Write-Verbose "   Testing for MDT..."                
                 $present = (Test-Path -Path "$($this.DownloadPath)\Microsoft Deployment Toolkit\MicrosoftDeploymentToolkit2013_x64.msi")
                 Write-Verbose "   $present"
                 if($Present){}Else{return $false}
               }
               
               if($file.ADK){
                 Write-Verbose "   Testing for ADK..."                 
                 $present = (Test-Path -Path "$($this.DownloadPath)\Windows Assessment and Deployment Kit\adksetup.exe")
                 Write-Verbose "   $present"
                 if($Present){}Else{return $false}   
               }
            }
        }
        else{
            if ($Present){
               $present = $false 
            }
            else{
               $present = $true 
            }
        }

        Write-Verbose "Test completed!"
        return $present
    }

    [cMDTBuildPreReqs] Get()
    {
        return $this
    }

    [bool] TestDownloadPath()
    {
        $present = $false

        if (Test-Path -Path $this.DownloadPath -ErrorAction Ignore)
        {
            $present = $true
        }        

        return $present
    }

    [bool] VerifyFiles()
    {

        [bool]$match = $false

        if (Get-ChildItem -Path $this.DownloadPath -Recurse)
        {
            #ForEach File, test...
            $match = $true
        }
        
        return $match
    }

    [void] WebClientDownload($Source,$Target)
    {
        $WebClient = New-Object System.Net.WebClient
        Write-Verbose "      Downloading file $($Source)"
        Write-Verbose "      Downloading to $($Target)"
        $WebClient.DownloadFile($Source, $Target)
    }

    [void] ExtractFile($Source,$Target)
    {
        Write-Verbose "      Extracting file to $($Target)"
        Expand-Archive $Source -DestinationPath $Target -Force
    }

    [void] CleanTempDirectory($Object)
    {

        Remove-Item -Path $Object -Force -Recurse -Verbose:$False
    }

    [void] RemoveDirectory($referencefile = "")
    {
        Remove-Item -Path $this.DownloadPath -Force -Verbose     
    }

    [void] RemoveReferenceFile($File)
    {
        Remove-Item -Path $File -Force -Verbose:$False
    }
}
