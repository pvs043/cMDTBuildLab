
Function Get-ConfigurationData
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    Param (
        [Parameter(Mandatory)]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformation()]
        [hashtable] $ConfigurationData
    )
    return $ConfigurationData
}

