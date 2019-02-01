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

    [DscProperty()]
    [bool]$CustomImage = $false

    [DscProperty(Mandatory)]
    [string]$PSDriveName

    [DscProperty(Mandatory)]
    [string]$PSDrivePath

    [void] Set()
    {
        if ($this.ensure -eq [Ensure]::Present)
        {
            if ( !$this.Test() ) {
                $this.ImportOperatingSystem()
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
        $present = $false
        if ( !$this.CustomImage ) {
            $present = Invoke-TestPath -Path "$($this.PSDrivePath)\Operating Systems\$($this.Name)\sources\install.wim"
        }
        else {
            $image = $this.GetCustomImage()
            $present = Invoke-TestPath -Path "$($this.PSDrivePath)\Operating Systems\$($this.Name)\$image"
        }
        return $present
    }

    [cMDTBuildOperatingSystem] Get()
    {
        return $this
    }

    [void] ImportOperatingSystem()
    {
        Import-MDTModule
        New-PSDrive -Name $this.PSDriveName -PSProvider "MDTProvider" -Root $this.PSDrivePath -Verbose:$false

        Try {
            $ErrorActionPreference = "Stop"
            if ( !$this.CustomImage ) {
                Import-MDTOperatingSystem -Path $this.Path -SourcePath $this.SourcePath -DestinationFolder $this.Name -Verbose
            }
            else {
                $image = $this.GetCustomImage()
                if ($image -like "*.wim") {
                    Import-MDTOperatingystem -path $this.Path -SourceFile "$($this.SourcePath)\$image" -DestinationFolder $this.Name -Verbose
                }
            }
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

    [string] GetCustomImage()
    {
        $file = Get-Item -Path "$($this.SourcePath)\*.wim" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($file) {
            return $file.Name
        }
        else {
            return ""
        }
    }
}

