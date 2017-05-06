
Function Import-MDTModule
{
    If ( -Not (Get-Module MicrosoftDeploymentToolkit) ) {
        Import-Module "$env:ProgramFiles\Microsoft Deployment Toolkit\Bin\MicrosoftDeploymentToolkit.psd1" -ErrorAction Stop -Global -Verbose:$False
    }
}

