#
# cMDTBuildUpdateBootImage Test
#
$PSDriveName = "MDT001"
$PSDrivePath = "E:\MDTBuildLab"

Configuration MDTServer
{
	cMDTBuildUpdateBootImage updateBootImage {
		Version = "1.0"
		PSDeploymentShare = $PSDriveName
		PsDrivePath = $PSDrivePath
		ExtraDirectory = "Extra"
		BackgroundFile = "%INSTALLDIR%\Samples\Background.bmp"
		LiteTouchWIMDescription = "MDT Build Lab"
	}
}
