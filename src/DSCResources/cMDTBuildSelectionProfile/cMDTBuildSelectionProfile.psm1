enum Ensure
{
    Absent
    Present
}

[DscResource()]
class cMDTBuildSelectionProfile
{
    [DscProperty()]
    [Ensure]$Ensure = "Present"

    [DscProperty(Key)]
    [string]$Name

    [DscProperty()]
    [string]$Comments

    [DscProperty(Mandatory)]
    [string]$IncludePath

    [DscProperty(Mandatory)]
    [string]$PSDriveName

    [DscProperty(Mandatory)]
    [string]$PSDrivePath

    [void] Set()
    {
        if ($this.ensure -eq [Ensure]::Present) {
            $this.ImportSelectionProfile()
        }
        else {
            Invoke-RemovePath -Path "$($this.PSDriveName):\Selection Profiles\$($this.name)" -PSDriveName $this.PSDriveName -PSDrivePath $this.PSDrivePath -Verbose
        }
    }

    [bool] Test()
    {
        $present = Invoke-TestPath -Path "$($this.PSDriveName):\Selection Profiles\$($this.name)" -PSDriveName $this.PSDriveName -PSDrivePath $this.PSDrivePath
        if ($this.Ensure -eq [Ensure]::Present) {
            return $present
        }
        else {
            return -not $present
        }
    }

    [cMDTBuildSelectionProfile] Get()
    {
        return $this
    }

    [void] ImportSelectionProfile()
    {
        Import-MDTModule
        New-PSDrive -Name $this.PSDriveName -PSProvider "MDTProvider" -Root $this.PSDrivePath -Verbose:$false
        New-Item -Path "$($this.PSDriveName):\Selection Profiles" -enable "True" -Name $this.Name -Comments $this.Comments -Definition "<SelectionProfile><Include path=`"$($this.IncludePath)`" /></SelectionProfile>" -ReadOnly "False" -Verbose
    }
}
