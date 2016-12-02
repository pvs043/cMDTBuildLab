$winVer = (Get-WmiObject win32_operatingsystem).version
if ($winVer -like '6.3*') {
    # Windows 8.1 / Windows 2012 R2
    Invoke-Item "Z:\Applications\Configure - Set Start Layout\Theme01.deskthemepack"
    Import-StartLayout -LayoutPath "Z:\Applications\Configure - Set Start Layout\Default_Start_Screen_Layout.bin" -MountPath $env:SystemDrive\
}
elseif ($winVer -like '10.0*') {
    # Windows 10
    Import-StartLayout -LayoutPath "Z:\Applications\Configure - Set Start Layout\Default_Start_Screen_Layout_10.bin" -MountPath $env:SystemDrive\
}