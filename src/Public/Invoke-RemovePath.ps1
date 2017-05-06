
Function Invoke-RemovePath
{
    [cmdletbinding(SupportsShouldProcess=$True,ConfirmImpact="Low")]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory=$True)]
        [ValidateNotNullorEmpty()]
        [string]$Path,
        [Parameter()]
        [string]$PSDriveName,
        [Parameter()]
        [string]$PSDrivePath
    )

    [bool]$Verbosity
    If ($PSBoundParameters.Verbose) { $Verbosity = $True }
    Else { $Verbosity = $False }

    if (($PSDrivePath) -and ($PSDriveName)) {
        Import-MDTModule
        New-PSDrive -Name $PSDriveName -PSProvider "MDTProvider" -Root $PSDrivePath -Verbose:$False | `
        Remove-Item -Path "$($Path)" -Force -Verbose:$Verbosity
    }
    else {
        Remove-Item -Path "$($Path)" -Force -Verbose:$Verbosity
    }
}

