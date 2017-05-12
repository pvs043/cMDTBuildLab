#
# cMDTBuildCustomSettingsIni Test
#
$ComputerName   = "$env:computername"
$PSDrivePath    = "E:\MDTBuildLab"
$Company        = "MDT Build Lab"
$TimeZoneName   = "Ekaterinburg Standard Time"
$WSUSServer     = "http://fqdn:port"
$UserLocale     = "en-US"
$KeyboardLocale = "en-US;ru-RU"

Configuration MDTServer
{
    cMDTBuildCustomSettingsIni ini {
        Ensure = "Present"
        Path = "$($PSDrivePath)\Control\CustomSettings.ini"
        Content = @"
[Settings]
Priority=Init,Default
Properties=VMNameAlias

[Init]
UserExit=ReadKVPData.vbs
VMNameAlias=#SetVMNameAlias()#

[Default]
$($Company)
OSInstall=Y
HideShell=YES
ApplyGPOPack=NO
UserDataLocation=NONE
DoNotCreateExtraPartition=YES
JoinWorkgroup=WORKGROUP
$($TimeZoneName)
$($WSUSServer)
;SLShare=%DeployRoot%\Logs
TaskSequenceID=%VMNameAlias%
FinishAction=SHUTDOWN

;Set keyboard layout
$($UserLocale)
$($KeyboardLocale)

ComputerBackupLocation=NETWORK
BackupShare=\\$($ComputerName)\DeploymentShare$
BackupDir=Captures
BackupFile=#left("%TaskSequenceID%", len("%TaskSequenceID%")-3) & year(date) & right("0" & month(date), 2) & right("0" & day(date), 2)#.wim
DoCapture=YES

;Disable all wizard pages
SkipAdminPassword=YES
SkipApplications=YES
SkipBitLocker=YES
SkipCapture=YES
SkipComputerBackup=YES
SkipComputerName=YES
SkipDomainMembership=YES
SkipFinalSummary=YES
SkipLocaleSelection=YES
SkipPackageDisplay=YES
SkipProductKey=YES
SkipRoles=YES
SkipSummary=YES
SkipTimeZone=YES
SkipUserData=YES
SkipTaskSequence=YES
"@
    }
}
