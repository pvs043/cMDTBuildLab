enum Ensure
{
    Absent
    Present
}

[DscResource()]
class cMDTBuildPreReqs
{
    [DscProperty()]
    [Ensure]$Ensure = "Present"

    [DscProperty(Key)]
    [string]$DownloadPath

    [void] Set()
    {
        Write-Verbose "Starting Set MDT PreReqs..."
        [hashtable]$DownloadFiles = Get-ConfigurationData -ConfigurationData "$($PSScriptRoot)\cMDTBuildLabPrereqs.psd1"

        if ($this.ensure -eq [Ensure]::Present) {
            $present = $this.TestDownloadPath()
            if ($present) {
                Write-Verbose "   Download folder present!"
            }
            else {
                New-Item -Path $this.DownloadPath -ItemType Directory -Force
            }

            # Set all files:
            ForEach ($file in $downloadFiles.Prereqs) {
                $folder = "$($this.DownloadPath)\$($file.Folder)"
                if (Test-Path -Path "$folder\$($file.File)") {
                    Write-Verbose "   $($file.Name) already present!"
                }
                else {
                    Write-Verbose "   Creating $($file.Name) folder..."
                    New-Item -Path $folder -ItemType Directory -Force
                    if ($file.URI -like "*/*") {
                        $this.WebClientDownload($file.URI, "$folder\$($file.File)")
                    }
                    else {
                        $this.CopyFromSource("$($PSScriptRoot)\$($file.URI)", "$folder\$($file.File)")
                    }

                    # Workaround for external source scripts from GitHub: change EOL
                    if ($file.Name -eq "CleanupBeforeSysprep" -or $file.Name -eq "RemoveDefaultApps") {
                        $script = Get-Content -Path "$folder\$($file.File)"
                        if ($script -notlike '*`r`n*') {
                            $script.Replace('`n','`r`n')
                            Set-Content -Path "$folder\$($file.File)" -Value $script
                        }
                    }
                    # Download ADK Installers
                    if ($file.Name -eq "ADK" -or $file.Name -eq "WinPE") {
                        Write-Verbose "   Download $($file.Name) installers..."
                        Start-Process -FilePath "$folder\$($file.File)" -ArgumentList "/layout $Folder /norestart /quiet /ceip off" -Wait
                    }
                    # Unpack MDT hotfix
                    if ($file.Name -eq "KB4564442") {
                        Expand-Archive -Path "$folder\$($file.File)" -DestinationPath $folder
                    }
                }
            }
        }
        else {
            $this.RemoveDirectory("")
        }
        Write-Verbose "MDT PreReqs set completed!"
    }

    [bool] Test()
    {
        Write-Verbose "Testing MDT PreReqs..."
        $present = $this.TestDownloadPath()
        [hashtable]$DownloadFiles = Get-ConfigurationData -ConfigurationData "$($PSScriptRoot)\cMDTBuildLabPrereqs.psd1"

        if ($this.ensure -eq [Ensure]::Present) {
            Write-Verbose "   Testing for download path.."
            if($present) {
                Write-Verbose "   Download path found!"
            }
            Else {
                Write-Verbose "   Download path not found!"
                return $false
            }

            ForEach ($File in $downloadFiles.Prereqs) {
                 Write-Verbose "   Testing for $($File.Name)..."
                 $present = (Test-Path -Path "$($this.DownloadPath)\$($File.Folder)\$($File.File)")
                 Write-Verbose "   $present"
                 if(!$Present) {return $false}
            }
        }
        else {
            if ($Present) {$present = $false}
            else {$present = $true}
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
        if (Test-Path -Path $this.DownloadPath -ErrorAction Ignore) {
            $present = $true
        }
        return $present
    }

    [void] WebClientDownload($Source,$Target)
    {
        $WebClient = New-Object System.Net.WebClient
        Write-Verbose "      Downloading file $($Source)"
        Write-Verbose "      Downloading to $($Target)"
        $WebClient.DownloadFile($Source, $Target)
    }

    [void] CopyFromSource($Source,$Target)
    {
        Write-Verbose "      Copying $($Target)"
        Copy-Item -Path $Source -Destination $Target
    }

    [void] RemoveDirectory($referencefile = "")
    {
        Remove-Item -Path $this.DownloadPath -Force -Verbose
    }
}

