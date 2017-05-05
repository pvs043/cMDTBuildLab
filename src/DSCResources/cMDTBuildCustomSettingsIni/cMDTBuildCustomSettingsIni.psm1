enum Ensure
{
    Absent
    Present
}

[DscResource()]
class cMDTBuildCustomSettingsIni
{
    [DscProperty()]
    [Ensure]$Ensure = "Present"

    [DscProperty(Key)]
    [string]$Path

    [DscProperty()]
    [string]$Content

    [void] Set()
    {
        if ($this.Ensure -eq [Ensure]::Present) {
            $this.SetContent()
        }
        else {
            $this.SetDefaultContent()
        }
    }

    [bool] Test()
    {
        $present = $this.TestFileContent()
        if ($this.Ensure -eq [Ensure]::Present) {
            return $present
        }
        else {
            return -not $present
        }
    }

    [cMDTBuildCustomSettingsIni] Get()
    {
        return $this
    }

    [bool] TestFileContent()
    {
        $present = $false 
        $existingConfiguration = Get-Content -Path $this.Path -Raw #-Encoding UTF8
        if ($existingConfiguration -eq $this.Content.Replace("`n","`r`n")) {
            $present = $true   
        }
        return $present
    }

    [void] SetContent()
    {
        Set-Content -Path $this.Path -Value $this.Content.Replace("`n","`r`n") -NoNewline -Force #-Encoding UTF8
    }
    
    [void] SetDefaultContent()
    {
        $defaultContent = @"
[Settings]
Priority=Default
Properties=MyCustomProperty

[Default]
OSInstall=Y
SkipCapture=YES
SkipAdminPassword=NO
SkipProductKey=YES

"@
        Set-Content -Path $this.Path -Value $defaultContent -NoNewline -Force #-Encoding UTF8
    }
}
