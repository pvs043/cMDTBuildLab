#
# cMDTBuildOutofBoxDrivers Test
#
$PSDriveName = "MDT001"
$PSDrivePath = "E:\MDTBuildLab"

Configuration MDTServer
{
    cMDTBuildOutOfBoxDrivers "\Out-of-box Drivers\Workstation\Windows-10" {
        Ensure = "Present"
        Path = "\Applications\Core\Microsoft"
        DriverSourcePath = "Drivers\Workstation\Windows-10"
        PSDriveName = $PSDriveName
        PSDrivePath = $PSDrivePath
    }
}
