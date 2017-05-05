enum Ensure
{
    Absent
    Present
}

[DscResource()]
class cMDTBuildPersistentDrive
{
    [DscProperty()]
    [Ensure] $Ensure = "Present"

    [DscProperty(Key)]
    [string]$Path

    [DscProperty(Key)]
    [string]$Name

    [DscProperty(Mandatory)]
    [string]$Description

    [DscProperty(Mandatory)]
    [string]$NetworkPath

    [void] Set()
    {
        if ($this.ensure -eq [Ensure]::Present) {
            $this.CreateDirectory()
        }
        else {
            $this.RemoveDirectory()
        }
    }

    [bool] Test()
    {
        $present = $this.TestDirectoryPath()
        if ($this.Ensure -eq [Ensure]::Present) {
            return $present
        }
        else {
            return -not $present
        }
    }

    [cMDTBuildPersistentDrive] Get()
    {
        return $this
    }

    [bool] TestDirectoryPath()
    {
        $present = $false
        Import-MDTModule
        if (Test-Path -Path $this.Path -PathType Container -ErrorAction Ignore) {
            $mdtShares = (GET-MDTPersistentDrive -ErrorAction SilentlyContinue)
            If ($mdtShares) {
                ForEach ($share in $mdtShares) {
                    If ($share.Name -eq $this.Name) {
                        $present = $true
                    }
                }
            }
        }
        return $present
    }

    [void] CreateDirectory()
    {
        Import-MDTModule
        New-PSDrive -Name $this.Name -PSProvider "MDTProvider" -Root $this.Path -Description $this.Description -NetworkPath $this.NetworkPath -Verbose:$false | `
        Add-MDTPersistentDrive -Verbose
    }

    [void] RemoveDirectory()
    {
        Import-MDTModule
        Write-Verbose -Message "Removing MDTPersistentDrive $($this.Name)"
        New-PSDrive -Name $this.Name -PSProvider "MDTProvider" -Root $this.Path -Description $this.Description -NetworkPath $this.NetworkPath -Verbose:$false | `
        Remove-MDTPersistentDrive -Verbose
    }
}
