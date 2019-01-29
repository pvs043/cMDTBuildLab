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
    [string]$TargetPath

    [DscProperty()]
    [string[]]$TestFiles

    [void] Set()
    {
        $filename = "$($this.SourcePath)\$($this.name)"
        $extractfolder = "$($this.path)\$($this.TargetPath)"

        if ($this.ensure -eq [Ensure]::Present) {
            if ($filename -like '*.zip') {
                Invoke-ExpandArchive -Source $filename -Target $extractfolder -Verbose
            }
            else {
                Copy-Item -Path $filename $extractfolder -Verbose
            }
        }
    }

    [bool] Test()
    {
        $present = $true
        if ($this.Name -like '*.zip') {
            foreach ($file in $this.TestFiles) {
                if ( !(Test-Path -Path "$($this.path)\$($this.TargetPath)\$($file)") ) {
                    $present = $false
                    break
                }
            }
        }
        else {
            if ( !(Test-Path -Path "$($this.path)\$($this.TargetPath)\$($this.name)") ) {
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

