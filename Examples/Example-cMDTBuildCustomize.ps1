#
# cMDTBuildCustomize Example
#
$PSDrivePath = "E:\MDTBuildLab"
$SourcePath  = "E:\Source"

Configuration MDTServer
{
        cMDTBuildCustomize PEExtraFiles {
            Ensure = "Present"
            Name = "PEExtraFiles"
            Path = $PSDrivePath
            SourcePath = "$($SourcePath)/PEExtraFiles"
            TestFiles = @("Script1.vbs", "Script2.vbs")
        }
}
