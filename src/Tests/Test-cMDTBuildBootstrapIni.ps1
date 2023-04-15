#
# cMDTBuildBootstrapIni Test
#
$PSDrivePath = "E:\MDTBuildLab"

Configuration MDTServer
{
    cMDTBuildBootstrapIni ini {
        Ensure = "Present"
        Path = "$($PSDrivePath)\Control\Bootstrap.ini"
        Content = @"
[Settings]
Priority=Default

[Default]
DeployRoot=\\$($ComputerName)\DeploymentShare$
SkipBDDWelcome=YES

;MDT Connect Account
UserID=$($UserName)
UserPassword=$($Password)
UserDomain=$($env:COMPUTERNAME)
"@
    }
}
