@{
    Prereqs = @(
        @{
            # Microsoft Deployment Toolkit (Build: 6.3.8456.1000)
            Name   = "MDT"
            URI    = "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi"
            Folder = "MDT"
            File   = "MicrosoftDeploymentToolkit_x64.msi"
        }
        @{
            # Windows Assessment and Deployment Kit v.2004 (Build: 10.1.19041.1)
            Name   = "ADK"
            URI    = "https://download.microsoft.com/download/8/6/c/86c218f3-4349-4aa5-beba-d05e48bbc286/adk/adksetup.exe"
            Folder = "ADK"
            File   = "adksetup.exe"
        }
        @{
            # Windows PE v.2004 (Build: 10.1.19041.1)
            Name   = "WinPE"
            URI    = "https://download.microsoft.com/download/3/c/2/3c2b23b2-96a0-452c-b9fd-6df72266e335/adkwinpeaddons/adkwinpesetup.exe"
            Folder = "WindowsPE"
            File   = "adkwinpesetup.exe"
        }
        @{
            # Install script for Visual C++ runtimes
            Name   = "VS++Application"
            #URI    = "https://raw.githubusercontent.com/DeploymentBunny/Files/master/Tools/Install-X86-X64-C%2B%2B/Install-MicrosoftVisualC%2B%2Bx86x64.wsf"
            URI    = "https://github.com/pvs043/Files/blob/master/Tools/Install-X86-X64-C%2B%2B/Install-MicrosoftVisualC%2B%2Bx86x64.wsf"
            Folder = "VC++"
            File   = "Install-MicrosoftVisualCx86x64.wsf"
        }
        @{
            Name   = "VS2013x86"
            URI    = "https://aka.ms/highdpimfc2013x86enu"
            Folder = "VC++\Source\VS2013"
            File   = "vcredist_x86.exe"
        }
        @{
            Name   = "VS2013x64"
            URI    = "https://aka.ms/highdpimfc2013x64enu"
            Folder = "VC++\Source\VS2013"
            File   = "vcredist_x64.exe"
        }
        @{
            Name   = "VS2022x86"
            URI    = "https://aka.ms/vs/17/release/vc_redist.x86.exe"
            Folder = "VC++\Source\VS2022"
            File   = "vc_redist.x86.exe"
        }
        @{
            Name   = "VS2022x64"
            URI    = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
            Folder = "VC++\Source\VS2022"
            File   = "vc_redist.x64.exe"
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
            # Configure - Firewall rules
            Name   = "ConfigureFirewall"
            URI    = "Sources\Config-NetFwRules.ps1"
            Folder = "ConfigureFirewall"
            File   = "Config-NetFwRules.ps1"
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
            URI    = "Sources\Default_Start_Screen_Layout_10.xml"
            Folder = "Set-Startlayout"
            File   = "Default_Start_Screen_Layout_10.xml"
        }
        @{
            # Configure - Remove Windows 10 Default Applications
            Name   = "RemoveDefaultApps"
            URI    = "https://raw.githubusercontent.com/SCConfigMgr/ConfigMgr/master/Operating%20System%20Deployment/Invoke-RemoveBuiltinApps.ps1"
            Folder = "RemoveDefaultApps"
            File   = "Invoke-RemoveBuiltinApps.ps1"
        }
    )
}
