@{
    Prereqs = @(
        @{
            # Microsoft Deployment Toolkit (Build: 6.3.8450.1000)
            Name   = "MDT"
            URI    = "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi"
            Folder = "Microsoft Deployment Toolkit"
            File   = "MicrosoftDeploymentToolkit_x64.msi"
        }
        @{
            # Windows Assessment and Deployment Kit 10, v.1709 (Build: 10.1.16299.15)
            Name   = "ADK"
            URI    = "https://go.microsoft.com/fwlink/p/?linkid=859206"
            Folder = "Windows Assessment and Deployment Kit"
            File   = "adksetup.exe"
        }
        @{
            # Install script for Visual C++ runtimes
            Name   = "VS++Application"
            URI    = "https://raw.githubusercontent.com/DeploymentBunny/Files/master/Tools/Install-X86-X64-C%2B%2B/Install-MicrosoftVisualC%2B%2Bx86x64.wsf"
            Folder = "VC++"
            File   = "Install-MicrosoftVisualCx86x64.wsf"
        }
        @{
            Name   = "VS2008SP1x86"
            URI    = "http://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe"
            Folder = "VC++\Source\VS2008"
            File   = "vcredist_x86.exe"
        }
        @{
            Name   = "VS2008SP1x64"
            URI    = "http://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe"
            Folder = "VC++\Source\VS2008"
            File   = "vcredist_x64.exe"
         }
        @{
            Name   = "VS2010SP1x86"
            URI    = "http://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe"
            Folder = "VC++\Source\VS2010"
            File   = "vcredist_x86.exe"
        }
        @{
            Name   = "VS2010SP1x64"
            URI    = "http://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe"
            Folder = "VC++\Source\VS2010"
            File   = "vcredist_x64.exe"
        }
        @{
            Name   = "VS2012UPD4x86"
            URI    = "http://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe"
            Folder = "VC++\Source\VS2012"
            File   = "vcredist_x86.exe"
        }
        @{
            Name   = "VS2012UPD4x64"
            URI    = "http://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe"
            Folder = "VC++\Source\VS2012"
            File   = "vcredist_x64.exe"
        }
        @{
            Name   = "VS2013x86"
            URI    = "http://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x86.exe"
            Folder = "VC++\Source\VS2013"
            File   = "vcredist_x86.exe"
        }
        @{
            Name   = "VS2013x64"
            URI    = "http://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe"
            Folder = "VC++\Source\VS2013"
            File   = "vcredist_x64.exe"
        }
        @{
            Name   = "VS2017x86"
            URI    = "https://go.microsoft.com/fwlink/?LinkId=746571"
            Folder = "VC++\Source\VS2017"
            File   = "vc_redist.x86.exe"
        }
        @{
            Name   = "VS2017x64"
            URI    = "https://go.microsoft.com/fwlink/?LinkId=746572"
            Folder = "VC++\Source\VS2017"
            File   = "vc_redist.x64.exe"
        }
        <#
        @{
            # Servicing stack update for Windows 10 Version 1607 x86: November 14, 2017
            Name   = "KB4049065-x86"
            URI    = "http://download.windowsupdate.com/d/msdownload/update/software/crup/2017/10/windows10.0-kb4049065-x86_f680d06952404dcae7719f2b9d713b7b9d2cd6a2.msu"
            Folder = "KB4049065-x86"
            File   = "windows10.0-kb4049065-x86_f680d06952404dcae7719f2b9d713b7b9d2cd6a2.msu"
        }
        @{
            # Servicing stack update for Windows 10 Version 1607 x64: November 14, 2017
            Name   = "KB4049065-x64"
            URI    = "http://download.windowsupdate.com/d/msdownload/update/software/crup/2017/10/windows10.0-kb4049065-x64_f92abbe03d011154d52cf13be7fb60e2c6feb35b.msu"
            Folder = "KB4049065-x64"
            File   = "windows10.0-kb4049065-x64_f92abbe03d011154d52cf13be7fb60e2c6feb35b.msu"
        }
        #>
        @{
            # Cumulative update for Windows 10 Version 1607 x86: January 3, 2018
            Name   = "KB4056890-x86"
            URI    = "http://download.windowsupdate.com/c/msdownload/update/software/secu/2018/01/windows10.0-kb4056890-x86_078b34bfdc198bee26c4f13e2e45cb231ba0d843.msu"
            Folder = "KB4056890-x86"
            File   = "windows10.0-kb4056890-x86_078b34bfdc198bee26c4f13e2e45cb231ba0d843.msu"
        }
        @{
            # Cumulative update for Windows 10 Version 1607 x64: January 3, 2018
            Name   = "KB4056890-x64"
            URI    = "http://download.windowsupdate.com/c/msdownload/update/software/secu/2018/01/windows10.0-kb4056890-x64_1d0f5115833be3d736caeba63c97cfa42cae8c47.msu"
            Folder = "KB4056890-x64"
            File   = "windows10.0-kb4056890-x64_1d0f5115833be3d736caeba63c97cfa42cae8c47.msu"
        }
        @{
            # Action - CleanupBeforeSysprep
            Name   = "CleanupBeforeSysprep"
            URI    = "https://raw.githubusercontent.com/DeploymentBunny/Files/master/Tools/Action-CleanupBeforeSysprep/Action-CleanupBeforeSysprep.wsf"
            Folder = "CleanupBeforeSysprep"
            File   = "Action-CleanupBeforeSysprep.wsf"
        }
        @{
            # Configure - Set Control+Shift Keyboard Toggle
            Name   = "KeyboardToggle"
            URI    = "Sources\Toggle.reg"
            Folder = "KeyboardToggle"
            File   = "Toggle.reg"
        }
        @{
            # Configure - Set Start Layout (script)
            Name   = "CustomizeDefaultProfile"
            URI    = "Sources\Customize-DefaultProfile.ps1"
            Folder = "Set-Startlayout"
            File   = "Customize-DefaultProfile.ps1"
        }
        @{
            # Configure - Set Start Layout (Windows 10)
            Name   = "StartLayout10"
            URI    = "Sources\Default_Start_Screen_Layout_10.bin"
            Folder = "Set-Startlayout"
            File   = "Default_Start_Screen_Layout_10.bin"
        }
    )
}
