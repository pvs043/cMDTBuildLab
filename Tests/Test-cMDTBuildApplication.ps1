#
# cMDTBuildApplication Test
#
$PSDriveName = "MDT001"
$PSDrivePath = "E:\MDTBuildLab"

Configuration MDTServer
{
	cMDTBuildApplication WMF5 {
		Ensure = "Present"
	    Name = "Install - Windows Management Framework 5.0 - x64"
		Path = "\Applications\Core\Microsoft"
		CommandLine = "wusa.exe Win8.1AndW2K12R2-KB3134758-x64.msu /quiet /norestart"
		ApplicationSourcePath = "WMF50x64"
		Enabled = "True"
		PSDriveName = $PSDriveName
		PSDrivePath = $PSDrivePath
	}
}
