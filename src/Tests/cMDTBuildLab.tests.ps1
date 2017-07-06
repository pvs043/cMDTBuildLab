#region Variables
$Rules = Get-ScriptAnalyzerRule | Where-Object RuleName -NotIn @('PSUseShouldProcessForStateChangingFunctions','PSAvoidUsingWMICmdlet')
#endregion

$modules = Get-ChildItem -Path $PSScriptRoot\.. -Include 'cMDTBuildLab*'
$modules += Get-ChildItem -Path $PSScriptRoot\..\Deploy -Recurse -Include @('*.ps1','*.psd1')
$modules += Get-ChildItem -Path $PSScriptRoot\..\Examples -Recurse -Include @('*.ps1','*.psd1')
$modules += Get-ChildItem -Path $PSScriptRoot\..\Sources -Recurse -Include @('*.ps1','*.psd1')
$modules += Get-ChildItem -Path $PSScriptRoot\..\Tests -Recurse -Include @('*.ps1','*.psd1')

Describe 'Script analyzer rule: ' {
    foreach ($module in $modules) {
        foreach ($rule in $rules) {
            It "$($module.Name) Passes the `"$($rule.CommonName)`" validation" {
                $output = $null
                $results = Invoke-ScriptAnalyzer -Path $module.FullName -IncludeRule $Rule.RuleName
                if ($results.count -eq 1) {
                    $output = "$($results.Message) at line $($results.Line)"
                }
                elseif ($results.count -gt 1) {
                    foreach ($result in $results) {
                        $output += "$($result.Message) at line $($result.Line)`r`n"
                    }
                }
                $output | should be $null
            }
        }
    }
}
