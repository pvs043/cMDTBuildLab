###
# Script for prepare Windows distributives
#
# 1. Download source Windows ISO from VLSC, MSDN on Evalution portals
# 2. Save to folders on MDT server or File server:
#    \\server\ISO
#      + Windows 7
#        + SW_DVD5_SA_Win_Ent_7w_SP1_64BIT_Russian_-2_MLF_X17-59024.ISO
#      + Windows 10
#        + SW_DVD5_Win_Pro_10_1607_64BIT_English_MLF_X21-06988.ISO
#      [...]
# 3. Run this script as Administrator and get info of the images:
#    Unpack-ISO.ps1 -ISOPath '\\server\ISO'
# 4. Edit parameters at TaskSequences section of the Deploy_MDT_Server_ConfigurationData.psd1:
#    TaskSequences   = @(
#        @{
#            Ensure   = "Present"
#            Name     = "Windows 7 x86"
#            Path     = "Windows 7"
#            OSName   = "Windows 7\Windows 7 ENTERPRISE in Windows 7 x86 install.wim"
#            [...]
# 5. Edit configuration data of this script ($destinations)
# 6. Unpack Windows sources from ISO:
#    Unpack-ISO.ps1 -ISOPath '\\server\ISO' -unpack
#
# Author: @sundmoon (https://github.com/sundmoon)
#
###

[CmdletBinding()]
param(
    [parameter(Mandatory = $true, HelpMessage="Source path for ISO files directory tree. Enter the local folder or file share name")]
    [String]$ISOPath,

    [parameter(Mandatory = $false)]
    [String]$MountFolder = 'E:\Mount',

    [parameter(Mandatory = $false)]
    [String]$dstPath = 'E:\Source',

    [switch]$Unpack
)

$destinations = @(
    @{
        Name =  "Windows 7 ENTERPRISE"
        Lang =  "Russian"
        Arch =  "x32"
        Build = "59024"
        Dest =  "Windows7x86"
    }
    @{
        Name  = "Windows 7 ENTERPRISE"
        Lang  = "Russian"
        Arch  = "x64"
        Build = "59028"
        Dest  = "Windows7x64"
    }
    @{
        Name  = "Windows 8.1 Enterprise"
        Lang  = "Russian"
        Arch  = "x32"
        Build = "84253"
        Dest  = "Windows81x86"
    }
    @{
        Name  = "Windows 8.1 Enterprise"
        Lang  = "Russian"
        Arch  = "x64"
        Build = "84254"
        Dest  = "Windows81x64"
    }
    @{
        Name  = "Windows 10 Enterprise"
        Lang  = "Russian"
        Arch  = "x32"
        Build = "27096"
        Dest  = "Windows10x86"
    }
    @{
        Name  = "Windows 10 Enterprise"
        Lang  = "Russian"
        Arch  = "x64"
        Build = "27097"
        Dest  = "Windows10x64"
    }
    @{
        Name  = "Windows Server 2012 R2 SERVERSTANDARD"
        Lang  = "English"
        Arch  = "x64"
        Build = "82891"
        Dest  = "Windows2012R2"
    }
    @{
        Name  = "Windows Server 2016 SERVERSTANDARD"
        Lang  = "English"
        Arch  = "x64"
        Build = "30350"
        Dest  = "Windows2016"
    }
)


if (!(Test-Path -Path $ISOPath)) {
    Write-Warning -Message "Could not find ISO store at $ISOPath. Aborting..."
    Break
}

if (!(Test-Path -Path $MountFolder)) {
    New-Item $MountFolder -ItemType Directory
}
else {
    if ((Get-ChildItem $MountFolder).count -ne 0) {
        Write-Warning -Message "Mount folder $MountFolder should be empty. Aborting..."
        Break
    }
}

#best effort to parse conventional iso names for meaningful tokens, may not match all possible iso names
function Get-ISOTokens {
    param (
        [string]$FullName
    )

    #you may add your languages here or amend the logic to encompass more complex variants
    $Lang = switch -regex ($FullName) {
        '\\en_windows_|_English_' {'English'}
        '\\ru_windows_|_Russian_' {'Russian'}
        default {'Unknown/Custom'}
    }

    #extracting 5 or more sequential digits
    [regex]$rx='\d{5,}'
    $Build = $rx.Match($FullName).value

    #mining for Arch
    $x64 = $FullName -match 'x64' -or $FullName -match '64BIT'
    $x32 = $FullName -match 'x32' -or $FullName -match 'x86' -or $FullName -match '32BIT'
    If ($x64 -and $x32) { $Arch = 'x32_x64' }
    elseif ($x64) { $Arch = 'x64' }
    elseif ($x32) { $Arch = 'x32' }

    @{
        Lang = $Lang
        Arch = $Arch
        Build = $Build
    }
}


function Get-ISO
{
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $true,
        ValueFromPipeline = $true)]
        [System.IO.FileInfo[]]$ISO,

        [switch]$Unpack
    )

    process {
        Mount-DiskImage -ImagePath $PSItem.FullName
        $ISOImage = Get-DiskImage -ImagePath $PSItem.fullname | Get-Volume
        $ISODrive = [string]$ISOImage.DriveLetter+':'
        $InstallImage = "$ISODrive\sources\install.wim"
        if (!(Test-Path -Path $InstallImage ))
        {
            Write-Warning -Message "Could not find install.wim in $($PSItem.FullName)"
        }
        else
        {
            Write-Verbose -Message "Processing $PSItem"

            #assuming wim image format, don't mess with esd, swm etc. for now
            $images = Get-WindowsImage -ImagePath $ISODrive\sources\install.wim
            Write-Verbose -Message "Images count: $($images.count)"
            foreach ($image in $images)
            {
                $tokens = Get-ISOTokens $PSItem.FullName
                [PSCustomObject]@{
                    'FullName'   = $PSItem.FullName
                    'Name'       = $image.ImageName
                    'Language'   = $tokens['Lang']
                    'Arch'       = $tokens['Arch']
                    'Build'      = $tokens['Build']
                    'ImageIndex' = $image.ImageIndex
                    'ImageSize'  = "{0:N2}" -f ($image.ImageSize / 1GB) + " Gb"
                }

                #unpack images to MDT source folder
                if ($Unpack)
                {
                    foreach ($dst in $destinations) {
                        $dst.GetEnumerator() | % {
                            If ($_.key -eq "Name")  { $Name  = $_.value }
                            If ($_.key -eq "Lang")  { $Lang  = $_.value }
                            If ($_.key -eq "Arch")  { $Arch  = $_.value }
                            If ($_.key -eq "Build") { $Build = $_.value }
                            If ($_.key -eq "Dest")  { $Dest  = $_.value }
                        }

                        if ($Name -eq $image.ImageName -and $Lang -eq $tokens['Lang'] -and $Arch -eq $tokens['Arch'] -and $Build -eq $tokens['Build'])
                        {
                            Write-Host "Unpack $Name from $($PSItem.FullName) to $Dest" -ForegroundColor Green
                            if (Test-Path $dstPath\$Dest)
                            {
                                Write-Warning "Remove directory $dstPath\$Dest"
                                Remove-Item $dstPath\$Dest -Recurse -Force
                            }
                            New-Item $dstPath\$Dest -ItemType Directory
                            Copy-Item -Path "$ISODrive\*" -Destination $dstPath\$Dest -Recurse
                            Write-Host "Done!" -ForegroundColor Green
                        }
                    }
                }
            }
        }
        Dismount-DiskImage -ImagePath $PSItem.fullname
    }
}

$ISO = Get-ChildItem $ISOPath -Recurse -Filter *.iso
$ISO | Get-ISO -Unpack:$Unpack -Verbose
