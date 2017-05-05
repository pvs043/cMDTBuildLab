enum Ensure
{
    Absent
    Present
}

[DscResource()]
class cMDTBuildUpdateBootImage
{
    [DscProperty(Key)]
    [string]$Version

    [DscProperty(Key)]
    [string]$PSDeploymentShare

    [DscProperty(Mandatory)]
    [string]$PSDrivePath

    [DscProperty()]
    [string]$ExtraDirectory

    [DscProperty()]
    [string]$BackgroundFile

    [DscProperty()]
    [string]$LiteTouchWIMDescription
      
    [void] Set()
    {
        $this.UpdateBootImage()
    }

    [bool] Test()
    {
        Return ($this.VerifyVersion())
    }

    [cMDTBuildUpdateBootImage] Get()
    {
        return $this
    }

    [bool] VerifyVersion()
    {
        [bool]$match = $false

        if ((Get-Content -Path "$($this.PSDrivePath)\Boot\CurrentBootImage.version" -ErrorAction Ignore) -eq $this.Version) {
            $match = $true
        }
        return $match
    }

    [void] UpdateBootImage()
    {
        Import-MDTModule
        New-PSDrive -Name $this.PSDeploymentShare -PSProvider "MDTProvider" -Root $this.PSDrivePath -Verbose:$false

        If ([string]::IsNullOrEmpty($($this.ExtraDirectory))) {
            Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x64.ExtraDirectory -Value ""
            Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x86.ExtraDirectory -Value ""
        }
        ElseIf (Invoke-TestPath -Path "$($this.PSDrivePath)\$($this.ExtraDirectory)") {
            Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x64.ExtraDirectory -Value "$($this.PSDrivePath)\$($this.ExtraDirectory)"                        
            Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x86.ExtraDirectory -Value "$($this.PSDrivePath)\$($this.ExtraDirectory)"                       
        }

        If ([string]::IsNullOrEmpty($($this.BackgroundFile))) {
            Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x64.BackgroundFile -Value ""
            Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x86.BackgroundFile -Value ""
        }
        ElseIf (Invoke-TestPath -Path "$($this.PSDrivePath)\$($this.BackgroundFile)") {
             Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x64.BackgroundFile -Value "$($this.PSDrivePath)\$($this.BackgroundFile)"
             Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x86.BackgroundFile -Value "$($this.PSDrivePath)\$($this.BackgroundFile)"
        }
        Else {
             Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x64.BackgroundFile -Value $this.BackgroundFile
             Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x86.BackgroundFile -Value $this.BackgroundFile
        }

        If ($this.LiteTouchWIMDescription) {
            Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x64.LiteTouchWIMDescription -Value "$($this.LiteTouchWIMDescription) x64 $($this.Version)"
            Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x86.LiteTouchWIMDescription -Value "$($this.LiteTouchWIMDescription) x86 $($this.Version)"
            Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x64.LiteTouchISOName -Value "$($this.LiteTouchWIMDescription)_x64.iso".Replace(' ','_')
            Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x86.LiteTouchISOName -Value "$($this.LiteTouchWIMDescription)_x86.iso".Replace(' ','_')
        }

        Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x64.SelectionProfile -Value "Nothing"
        Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x86.SelectionProfile -Value "Nothing"

        # for offline remove Windows default apps
        Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x86.FeaturePacks -Value "winpe-dismcmdlets,winpe-mdac,winpe-netfx,winpe-powershell,winpe-storagewmi"

        Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x64.GenerateLiteTouchISO -Value $false
        Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x86.GenerateLiteTouchISO -Value $true

        #The Update-MDTDeploymentShare command crashes WMI when run from inside DSC. This section is a work around.
        workflow Update-DeploymentShare {
            param (
                [string]$PSDeploymentShare,
                [string]$PSDrivePath
            )
            InlineScript {
                Import-MDTModule
                New-PSDrive -Name $Using:PSDeploymentShare -PSProvider "MDTProvider" -Root $Using:PSDrivePath -Verbose:$false
                Update-MDTDeploymentShare -Path "$($Using:PSDeploymentShare):" -Force:$true -Compress:$true
            }
        }
        Update-DeploymentShare $this.PSDeploymentShare $this.PSDrivePath
        Set-Content -Path "$($this.PSDrivePath)\Boot\CurrentBootImage.version" -Value "$($this.Version)"
    }
}
