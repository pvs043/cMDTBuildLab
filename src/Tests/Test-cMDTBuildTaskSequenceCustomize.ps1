#
# cMDTBuildTaskSequenceCustomize Test
#
$PSDriveName = "MDT001"
$PSDrivePath = "E:\MDTBuildLab"
$TSID = "REFW10X64-001"
$TSFile = "$($PSDrivePath)\Control\$($TSID)\ts.xml"

Configuration MDTServer
{
    cMDTBuildTaskSequenceCustomize AddFeatures {
        TSFile      = $TSFile
        Name        = "Install - Microsoft NET Framework 3.5.1"
        Type        = "Install Roles and Features"
        GroupName   = "State Restore"
        SubGroup    = "Custom Tasks (Pre-Windows Update)"
        OSName      = "Windows 10"
        OSFeatures  = "NetFx3,TelnetClient"
        PSDriveName = $PSDriveName
        PSDrivePath = $PSDrivePath
    }
}
