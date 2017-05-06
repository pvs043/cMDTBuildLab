enum Ensure
{
    Absent
    Present
}

[DscResource()]
class cMDTBuildPackage
{
    [DscProperty()]
    [Ensure]$Ensure = "Present"

    [DscProperty(Key)]
    [string]$Name

    [DscProperty(Key)]
    [string]$Path

    [DscProperty(Mandatory)]
    [string]$PackageSourcePath
    
    [DscProperty(Mandatory)]
    [string]$PSDriveName

    [DscProperty(Mandatory)]
    [string]$PSDrivePath

    [void] Set()
    {
        if ($this.ensure -eq [Ensure]::Present) {
            $present = Invoke-TestPath -Path "$($this.path)\$($this.name)" -PSDriveName $this.PSDriveName -PSDrivePath $this.PSDrivePath
            if ( !$present ) {
                $this.ImportPackage()
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

    [cMDTBuildPackage] Get()
    {
        return $this
    }

    [void] ImportPackage()
    {
        # The Import-MDTPackage command crashes WMI when run from inside DSC. Using workflow is a work around.
        workflow Import-Pkg {
            [CmdletBinding()]
            param(
                [string]$PSDriveName,
                [string]$PSDrivePath,
                [string]$Path,
                [string]$Source
            )
            InlineScript {
                Import-MDTModule
                New-PSDrive -Name $Using:PSDriveName -PSProvider "MDTProvider" -Root $Using:PSDrivePath -Verbose:$false
                Import-MDTPackage -Path $Using:Path -SourcePath $Using:Source -Verbose
            }
        }
        Import-Pkg $this.PSDriveName $this.PSDrivePath $this.Path $this.PackageSourcePath
    }
}

