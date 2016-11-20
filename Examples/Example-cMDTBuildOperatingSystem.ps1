#
# cMDTBuildOperatingSystem Example
#
$SourcePath  = "E:\Source"
$PSDriveName = "MDT001"
$PSDrivePath = "E:\MDTBuildLab"

Configuration MDTServer
{
	cMDTBuildOperatingSystem Win10x64 {
		Ensure = "Present"
		Name = "Windows 10 x64"
		Path = "Windows 10"
		SourcePath = "$SourcePath\Windows10x64"
		PSDriveName = $PSDriveName
		PSDrivePath = $PSDrivePath
	}
}