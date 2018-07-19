enum Ensure
{
    Absent
    Present
}

[DscResource()]
class cMDTBuildApplication
{
    [DscProperty()]
    [Ensure]$Ensure = "Present"

    [DscProperty(Key)]
    [string]$Name

    [DscProperty(Key)]
    [string]$Path

    [DscProperty(Mandatory)]
    [string]$Enabled

    [DscProperty(Mandatory)]
    [string]$CommandLine

    [DscProperty(Mandatory)]
    [string]$ApplicationSourcePath

    [DscProperty(Mandatory)]
    [string]$PSDriveName

    [DscProperty(Mandatory)]
    [string]$PSDrivePath

    [void] Set()
    {
        if ($this.ensure -eq [Ensure]::Present) {
            $present = Invoke-TestPath -Path "$($this.path)\$($this.name)" -PSDriveName $this.PSDriveName -PSDrivePath $this.PSDrivePath
            if ( !$present ) {
                $this.ImportApplication()
            }
        }
        else {
            Invoke-RemovePath -Path "$($this.path)\$($this.name)" -PSDriveName $this.PSDriveName -PSDrivePath $this.PSDrivePath -Verbose
        }
    }

    [bool] Test()
    {
        $present = Invoke-TestPath -Path "$($this.path)\$($this.name)" -PSDriveName $this.PSDriveName -PSDrivePath $this.PSDrivePath

        if ($this.Ensure -eq [Ensure]::Present) {
            return $present
        }
        else {
            return -not $present
        }
    }

    [cMDTBuildApplication] Get()
    {
        return $this
    }

    [void] ImportApplication()
    {
        Import-MDTModule
        New-PSDrive -Name $this.PSDriveName -PSProvider "MDTProvider" -Root $this.PSDrivePath -Verbose:$false
        Import-MDTApplication -Path $this.Path -Enable $this.Enabled -Name $this.Name -ShortName $this.Name `
                              -CommandLine $this.CommandLine -WorkingDirectory ".\Applications\$($this.Name)" `
                              -ApplicationSourcePath $this.ApplicationSourcePath -DestinationFolder $this.Name -Verbose
    }
}

