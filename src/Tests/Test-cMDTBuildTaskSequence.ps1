#
# cMDTBuildTaskSequence Test
#
$PSDriveName = "MDT001"
$PSDrivePath = "E:\MDTBuildLab"

Configuration MDTServer
{
    cMDTBuildTaskSequence Win10x64 {
        Ensure      = "Present"
        Name        = "Windows 10 x64"
        Path        = "Windows 10"
        OSName      = "Windows 10\Windows 10 Enterprise in Windows 10 x64 install.wim"
        OrgName     = "BuildLab"
        Template    = "Client.xml"
        ID          = "REFW10X64-001"
        PSDriveName = $PSDriveName
        PSDrivePath = $PSDrivePath
    }
}
