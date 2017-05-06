enum Ensure
{
    Absent
    Present
}

[DscResource()]
class cMDTBuildCustomize
{
    [DscProperty()]
    [Ensure]$Ensure = "Present"
    
    [DscProperty(Key)]
    [string]$Name

    [DscProperty(Key)]
    [string]$Path
    
    [DscProperty(Mandatory)]
    [string]$SourcePath

    [DscProperty(Mandatory)]
    [string[]]$TestFiles

    [DscProperty(NotConfigurable)]
    [string]$Directory

    [void] Set()
    {
        $filename = "$($this.SourcePath)\$($this.Name).zip"
        $extractfolder = "$($this.path)\$($this.name)"

        if ($this.ensure -eq [Ensure]::Present) {
            Invoke-ExpandArchive -Source $filename -Target $extractfolder -Verbose
        }
        else {
            Invoke-RemovePath -Path $extractfolder -Verbose
        }
    }

    [bool] Test()
    {
        $present = $true
        foreach ($file in $this.TestFiles) {
            if ( !(Test-Path -Path "$($this.path)\$($this.name)\$($file)") ) {
                $present = $false
                break
            }
        }

        if ($this.Ensure -eq [Ensure]::Present) {
            return $present
        }
        else {
            return -not $present
        }
    }

    [cMDTBuildCustomize] Get()
    {
        return $this
    }
}

