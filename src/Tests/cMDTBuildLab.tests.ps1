$Rules = Get-ScriptAnalyzerRule | Where-Object RuleName -NotIn @('PSUseShouldProcessForStateChangingFunctions','PSAvoidUsingWMICmdlet','PSReviewUnusedParameter')
$modules = Get-ChildItem -Path $PSScriptRoot\..\* -Include @('cMDTBuildLab.psm1','cMDTBuildLabPrereqs.psd1')
$modules += Get-ChildItem -Path $PSScriptRoot\..\Deploy -Recurse -Include @('*.ps1','*.psd1')
$modules += Get-ChildItem -Path $PSScriptRoot\..\Examples -Recurse -Include @('*.ps1','*.psd1')
$modules += Get-ChildItem -Path $PSScriptRoot\..\Sources -Recurse -Include @('*.ps1','*.psd1')

foreach ($module in $modules) {
    Describe "Script analyzer for $($module.Name)" {
        foreach ($rule in $rules) {
            It "$($module.Name) passes the $($rule.CommonName) validation" -TestCases @{ Module = $module.FullName; Rule = $rule.RuleName } {
                $output = $null
                $results = Invoke-ScriptAnalyzer -Path $Module -IncludeRule $Rule
                if ($results.count -eq 1) {
                    $output = "$($results.Message) at line $($results.Line)"
                }
                elseif ($results.count -gt 1) {
                    foreach ($result in $results) {
                        $output += "$($result.Message) at line $($result.Line)`r`n"
                    }
                }
                $output | should -Be $null
            }
        }
    }
}
