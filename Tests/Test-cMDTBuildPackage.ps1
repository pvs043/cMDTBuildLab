#
# cMDTBuildPackage Test
#
$PSDriveName = "MDT001"
$PSDrivePath = "E:\MDTBuildLab"

Configuration MDTServer
{
	cMDTBuildPackage KB3125574_x64 {
		Ensure = "Present"
		Name = "Package_for_KB3125574 neutral amd64 6.1.4.4"
		Path = "Packages\Windows 7"
		PackageSourcePath = "Update for Windows 7 for x64-based Systems (KB3125574)"
		PSDriveName = $PSDriveName
		PSDrivePath = $PSDrivePath
	}
}
