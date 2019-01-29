#
# cMDTBuildCustomize Test
#
$PSDrivePath = "E:\MDTBuildLab"
$SourcePath  = "E:\Source"

Configuration MDTServer
{
    cMDTBuildCustomize PEExtraFiles {
        Ensure = "Present"
        Name = "ExtraFiles"
        Path = $PSDrivePath
        SourcePath = "$($SourcePath)\Scripts"
        TestFiles = @("Script1.vbs", "Script2.vbs")
    }
}
