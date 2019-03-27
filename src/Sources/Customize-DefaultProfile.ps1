$winVer = (Get-CimInstance -ClassName win32_operatingsystem).version
if ($winVer -like '10.0*') {
    # Windows 10
    Import-StartLayout -LayoutPath "Z:\Applications\Configure - Set Start Layout\Default_Start_Screen_Layout_10.xml" -MountPath $env:SystemDrive\
}
