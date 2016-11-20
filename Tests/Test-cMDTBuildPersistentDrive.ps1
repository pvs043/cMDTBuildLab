#
# cMDTBuildPersistentDrive Test
#
$PSDriveName  = "MDT001"
$PSDrivePath  = "E:\MDTBuildLab"
$ComputerName = "$env:computername"

Configuration MDTServer
{
	cMDTBuildPersistentDrive DeploymentPSDrive {
		Ensure = "Present"
		Name = $PSDriveName
		Path = $PSDrivePath
		Description = "MDT Build Share"
		NetworkPath = "\\$ComputerName\DeploymentShare$"
	}
}

