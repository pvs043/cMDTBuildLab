###
# Script for prepare Windows distributives
#
# 1. Download source Windows ISO from VLSC, MSDN on Evaluation portals
# 2. Save to folders on MDT server or File server:
#    \\server\ISO
#      + Windows 10
#        + 14393.0.160715-1616.RS1_RELEASE_CLIENTENTERPRISEEVAL_OEMRET_X86FRE_EN-US.ISO
#      + Windows 2016
#        + en_windows_server_2016_x64_dvd_9718492.iso
#      [...]
# 3. Run this script as Administrator and get info of the images:
#    Import-ISO.ps1 -ISOPath '\\server\ISO' -Verbose
# 4. Edit parameters at TaskSequences section of the Deploy_MDT_Server_ConfigurationData.psd1:
#    TaskSequences   = @(
#        @{
#            Ensure   = "Present"
#            Name     = "Windows 7 x86"
#            Path     = "Windows 7"
#            OSName   = "Windows 7\Windows 7 ENTERPRISE in Windows 7 x86 install.wim"
#            [...]
# 5. Select needed images for your Build Lab ($destinations)
# 6. Import Windows sources from ISO:
#    Import-ISO.ps1 -ISOPath '\\server\ISO' -Unpack -Verbose
#
# Author: @sundmoon (https://github.com/sundmoon)
#
###

[CmdletBinding()]

param(
    [parameter(Mandatory = $true, HelpMessage="Enter Source path for ISO files directory tree (local folder or file share name)")]
    [String]$ISOPath,

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
        Build = "36515"
        Dest  = "Windows10x86"
    }
    @{
        Name  = "Windows 10 Enterprise"
        Lang  = "Russian"
        Arch  = "x64"
        Build = "36516"
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

#best effort to parse conventional iso names for meaningful tokens, may not match all possible iso names
function Get-ISOToken {
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
                $tokens = Get-ISOToken $PSItem.FullName
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
                        if ($dst.Name -eq $image.ImageName -and $dst.Lang -eq $tokens['Lang'] -and $dst.Arch -eq $tokens['Arch'] -and $dst.Build -eq $tokens['Build'])
                        {
                            $unpackPath = "$dstPath\$($dst.Dest)"
                            Write-Output "Unpack $Name from $($PSItem.FullName) to $unpackPath"
                            if (Test-Path $unpackPath)
                            {
                                Write-Warning "Remove directory $unpackPath"
                                Remove-Item $unpackPath -Recurse -Force
                            }
                            New-Item $unpackPath -ItemType Directory
                            Copy-Item -Path "$ISODrive\*" -Destination $unpackPath -Recurse
                            Write-Output "Done!"
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
