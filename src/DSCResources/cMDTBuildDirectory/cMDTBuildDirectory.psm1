enum Ensure
{
    Absent
    Present
}

[DscResource()]
class cMDTBuildDirectory
{
    [DscProperty()]
    [Ensure]$Ensure = "Present"

    [DscProperty(Key)]
    [string]$Path

    [DscProperty(Key)]
    [string]$Name

    [DscProperty()]
    [string]$PSDriveName

    [DscProperty()]
    [string]$PSDrivePath

    [void] Set()
    {
        if ($this.ensure -eq [Ensure]::Present) {
            $this.CreateDirectory()
        }
        else
        {
            if (($this.PSDrivePath) -and ($this.PSDriveName)) {
                Invoke-RemovePath -Path "$($this.path)\$($this.Name)" -PSDriveName $this.PSDriveName -PSDrivePath $this.PSDrivePath -Verbose
            }
            else {
                Invoke-RemovePath -Path "$($this.path)\$($this.Name)" -Verbose
            }
        }
    }

    [bool] Test()
    {
        if (($this.PSDrivePath) -and ($this.PSDriveName)) {
            $present = Invoke-TestPath -Path "$($this.path)\$($this.Name)" -PSDriveName $this.PSDriveName -PSDrivePath $this.PSDrivePath -Verbose
        }
        else {
            $present = Invoke-TestPath -Path "$($this.path)\$($this.Name)" -Verbose
        }

        if ($this.Ensure -eq [Ensure]::Present) {
            return $present
        }
        else {
            return -not $present
        }
    }

    [cMDTBuildDirectory] Get()
    {
        return $this
    }

    [void] CreateDirectory()
    {
        if (($this.PSDrivePath) -and ($this.PSDriveName)) {
            Import-MDTModule
            New-PSDrive -Name $this.PSDriveName -PSProvider "MDTProvider" -Root $this.PSDrivePath -Verbose:$false | `
                    New-Item -ItemType Directory -Path "$($this.path)\$($this.Name)" -Verbose
        }
        else {
            New-Item -ItemType Directory -Path "$($this.path)\$($this.Name)" -Verbose
        }
    }
}

