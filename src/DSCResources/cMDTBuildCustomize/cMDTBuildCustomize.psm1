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
        $filename = "$($this.path)\$($this.name)\$($this.SourcePath)"
        $extractfolder = "$($this.path)\$($this.Name)"

        if ($this.ensure -eq [Ensure]::Present) {
            if ($filename -like '*.zip') {
                Invoke-ExpandArchive -Source $filename -Target $extractfolder -Verbose
            }
            else {
                Copy-Item -Path $filename $extractfolder -Verbose
            }
        }
        else {
            Invoke-RemovePath -Path $extractfolder -Verbose
        }
    }

    [bool] Test()
    {
        $present = $true
        if ($this.SourcePath -like '*.zip') {
            foreach ($file in $this.TestFiles) {
                if ( !(Test-Path -Path "$($this.path)\$($this.name)\$($file)") ) {
                    $present = $false
                    break
                }
            }
        }
        else {
            if ( !(Test-Path -Path "$($this.path)\$($this.name)\$($this.SourcePath)") ) {
                $present = $false
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

