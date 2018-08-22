enum Ensure
{
    Absent
    Present
}
[DscResource()]
class cMDTBuildOutofBoxDrivers
{
    [DscProperty()]
    [Ensure]$Ensure = "Present"

    [DscProperty(Key)]
    [string]$Path

    [DscProperty(Mandatory)]
    [string]$DriverSourcePath

    [DscProperty(Mandatory)]
    [string]$PSDriveName

    [DscProperty(Mandatory)]
    [string]$PSDrivePath

    [void] Set()
    {
        if ($this.ensure -eq [Ensure]::Present) {
                $this.ImportOutofBoxDrivers()
        }
        else {
            Invoke-RemovePath -Path "$($this.path)" -PSDriveName $this.PSDriveName -PSDrivePath $this.PSDrivePath -Verbose
        }
    }

    [bool] Test()
    {
        # Path configured to never pass a test-path, not entirely sure what the best way to handle this is
        # Considered a 'force' flag but unsure of the validity of that in a DSC Configuration
        $present = Invoke-TestPath -Path "$($this.path)\DoesNotExist" -PSDriveName $this.PSDriveName -PSDrivePath $this.PSDrivePath
        if ($this.Ensure -eq [Ensure]::Present) {
            return $present
        }
        else {
            return -not $present
        }
    }

    [cMDTBuildOutofBoxDrivers] Get()
    {
        return $this
    }

    [void] ImportOutofBoxDrivers()
    {
        Import-MDTModule
        New-PSDrive -Name $this.PSDriveName -PSProvider "MDTProvider" -Root $this.PSDrivePath -Verbose:$false
        # Loops through each of the defined subdirectories and performs driver import function
        Get-ChildItem $this.DriverSourcePath | Foreach-Object {
            Import-MDTDriver -Path $this.Path -SourcePath $_.FullName -Verbose
        }
    }
}