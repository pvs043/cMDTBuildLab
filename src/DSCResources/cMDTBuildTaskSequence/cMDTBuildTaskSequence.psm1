enum Ensure
{
    Absent
    Present
}

[DscResource()]
class cMDTBuildTaskSequence
{

    [DscProperty()]
    [Ensure]$Ensure = "Present"

    [DscProperty(Key)]
    [string]$Name

    [DscProperty(Key)]
    [string]$Path

    [DscProperty(Mandatory)]
    [string]$OSName

    [DscProperty(Mandatory)]
    [string]$Template

    [DscProperty(Mandatory)]
    [string]$ID

    [DscProperty(Mandatory)]
    [string]$OrgName

    [DscProperty(Mandatory)]
    [string]$PSDriveName

    [DscProperty(Mandatory)]
    [string]$PSDrivePath

    [void] Set()
    {
        if ($this.ensure -eq [Ensure]::Present) {
            $this.ImportTaskSequence()
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

    [cMDTBuildTaskSequence] Get()
    {
        return $this
    }

    [void] ImportTaskSequence()
    {
        Import-MDTModule
        New-PSDrive -Name $this.PSDriveName -PSProvider "MDTProvider" -Root $this.PSDrivePath -Verbose:$false
        Import-MDTTaskSequence -path $this.Path -Name $this.Name -Template $this.Template -Comments "Build Reference Image" -ID $this.ID -Version "1.0" -OperatingSystemPath $this.OSName -FullName "Windows User" -OrgName $this.OrgName -HomePage "about:blank" -Verbose
        # Disable Windows autoupdate
        $UnattendXML = "$($this.PSDrivePath)\control\$($this.ID)\Unattend.xml"
        $unattend = Get-Content -Path $UnattendXML
        $unattend = $unattend.Replace('<ProtectYourPC>1','<ProtectYourPC>3')
        Set-Content -Path $UnattendXML -Value $unattend
    }
}

