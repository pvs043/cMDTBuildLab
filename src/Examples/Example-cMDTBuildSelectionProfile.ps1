#
# cMDTBuildSelectionProfile Example
#
$PSDriveName = "MDT001"
$PSDrivePath = "E:\MDTBuildLab"

Configuration MDTServer
{
    cMDTBuildSelectionProfile Win10x64 {
        Ensure      = "Present"
        Name        = "Windows 10 x64"
        Comments    = "Packages for Windows 10 x64"
        IncludePath = "Packages\Windows 10 x64"
        PSDriveName = $PSDriveName
        PSDrivePath = $PSDrivePath
    }
}
