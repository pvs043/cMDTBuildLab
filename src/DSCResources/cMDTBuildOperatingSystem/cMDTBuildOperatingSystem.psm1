enum Ensure
{
    Absent
    Present
}

[DscResource()]
class cMDTBuildOperatingSystem
{
    [DscProperty()]
    [Ensure]$Ensure = "Present"

    [DscProperty(Key)]
    [string]$Name

    [DscProperty(Key)]
    [string]$Path

    [DscProperty(Key)]
    [string]$SourcePath

    [DscProperty(Mandatory)]
    [string]$PSDriveName

    [DscProperty(Mandatory)]
    [string]$PSDrivePath

    [void] Set()
    {
        if ($this.ensure -eq [Ensure]::Present)
        {
            if ( !$this.Test() ) {
                                $this.ImportOperatingSystem("$($this.SourcePath)")
            }
        }
        else
        {
            Invoke-RemovePath -Path "$($this.PSDrivePath)\Operating Systems\$($this.Name)" -PSDriveName $this.PSDriveName -PSDrivePath $this.PSDrivePath -Verbose
            If ( $this.Test() ) { Write-Error "Cannot remove '$($this.PSDrivePath)\Operating Systems\$($this.Name)'" }
        }
    }

    [bool] Test()
    {
        $present = Invoke-TestPath -Path "$($this.PSDrivePath)\Operating Systems\$($this.Name)\sources\install.wim"
        return $present
    }

    [cMDTBuildOperatingSystem] Get()
    {
        return $this
    }

    [void] ImportOperatingSystem($OperatingSystem)
    {
        Import-MDTModule
        New-PSDrive -Name $this.PSDriveName -PSProvider "MDTProvider" -Root $this.PSDrivePath -Verbose:$false

        Try {
            $ErrorActionPreference = "Stop"
            Import-MDTOperatingSystem -Path $this.Path -SourcePath $OperatingSystem -DestinationFolder $this.Name -Verbose
            $ErrorActionPreference = "Continue"
        }
        Catch [Microsoft.Management.Infrastructure.CimException] {
            If ($_.FullyQualifiedErrorId -notlike "*ItemAlreadyExists*") {
                throw $_
            }
        }
        Finally {
        }
    }
}

