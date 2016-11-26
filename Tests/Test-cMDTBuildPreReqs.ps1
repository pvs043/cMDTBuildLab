#
# cMDTBuildPreReqs Test
#
$SourcePath  = "E:\Source"

Configuration MDTServer
{
    cMDTBuildPreReqs MDTPreReqs {
        Ensure = "Present"            
        DownloadPath = "$SourcePath"
    }
}
