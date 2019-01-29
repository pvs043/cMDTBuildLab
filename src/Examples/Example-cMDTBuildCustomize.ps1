#
# cMDTBuildCustomize Example
#
$PSDrivePath = "E:\MDTBuildLab"
$SourcePath  = "E:\Source"

Configuration MDTServer
{
        cMDTBuildCustomize ExtraFiles {
            Ensure = "Present"
            Name = "ExtraFiles.zip"
            Path = $PSDrivePath
            SourcePath = "$($SourcePath)\Scripts"
            TestFiles = @("Script1.vbs", "Script2.vbs")
        }
}
