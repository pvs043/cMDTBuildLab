#
# cMDTBuildDirectory Test
#
$PSDriveName = "MDT001"
$PSDrivePath = "E:\MDTBuildLab"

Configuration MDTServer
{
    cMDTBuildDirectory Windows10 {
        Ensure = "Present"
        Name = "Windows 10"
        Path = "$($PSDriveName):\Operating Systems"
        PSDriveName = $PSDriveName
        PSDrivePath = $PSDrivePath
    }
}
