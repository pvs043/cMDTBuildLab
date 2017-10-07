@{
    Prereqs = @(
        @{
            # Microsoft Deployment Toolkit (Build: 6.3.8443.1000)
            Name   = "MDT"
            URI    = "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi"
            Folder = "Microsoft Deployment Toolkit"
            File   = "MicrosoftDeploymentToolkit_x64.msi"
        }
        @{
            # Windows Assessment and Deployment Kit 10, v.1703 (Build: 10.1.15063.0)
            Name   = "ADK"
            URI    = "http://download.microsoft.com/download/5/D/9/5D915042-FCAA-4859-A1C3-29E198690493/adk/adksetup.exe"
            Folder = "Windows Assessment and Deployment Kit"
            File   = "adksetup.exe"
        }
        @{
            # Silverlight 5 x64 (Build: 5.1.50907.0)
            Name   = "Silverlight_x64"
            URI    = "https://download.microsoft.com/download/F/D/0/FD0B0093-DE8A-4C4E-BDC4-F0C56D72018C/50907.00/Silverlight_x64.exe"
            Folder = "Silverlight_x64"
            File   = "Silverlight_x64.exe"
        }
        @{
            # Silverlight 5 x86 (Build: 5.1.50907.0)
            Name   = "Silverlight_x86"
            URI    = "https://download.microsoft.com/download/F/D/0/FD0B0093-DE8A-4C4E-BDC4-F0C56D72018C/50907.00/Silverlight.exe"
            Folder = "Silverlight_x86"
            File   = "Silverlight.exe"
        }
        @{
            # Install script for Visual C++ runtimes
            Name   = "VS++Application"
            URI    = "Sources\Install-MicrosoftVisualCx86x64.wsf"
            Folder = "VC++"
            File   = "Install-MicrosoftVisualCx86x64.wsf"
        }
        @{
            Name   = "VS2005SP1x86"
            URI    = "http://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x86.exe"
            Folder = "VC++\Source\VS2005"
            File   = "vcredist_x86.exe"
        }
        @{
            Name   = "VS2005SP1x64"
            URI    = "http://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x64.exe"
            Folder = "VC++\Source\VS2005"
            File   = "vcredist_x64.exe"
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
            Name   = "VS2015x86"
            URI    = "https://download.microsoft.com/download/9/3/F/93FCF1E7-E6A4-478B-96E7-D4B285925B00/vc_redist.x86.exe"
            Folder = "VC++\Source\VS2015"
            File   = "vc_redist.x86.exe"
        }
        @{
            Name   = "VS2015x64"
            URI    = "https://download.microsoft.com/download/9/3/F/93FCF1E7-E6A4-478B-96E7-D4B285925B00/vc_redist.x64.exe"
            Folder = "VC++\Source\VS2015"
            File   = "vc_redist.x64.exe"
        }
        @{
            # Windows Management Framewework 3.0 for Windows 7 SP1 x86
            Name   = "WMF30x86"
            URI    = "https://download.microsoft.com/download/E/7/6/E76850B8-DA6E-4FF5-8CCE-A24FC513FD16/Windows6.1-KB2506143-x86.msu"
            Folder = "WMF30x86"
            File   = "Windows6.1-KB2506143-x86.msu"
        }
        @{
            # Windows Management Framewework 3.0 for Windows 7 SP1 x64
            Name   = "WMF30x64"
            URI    = "https://download.microsoft.com/download/E/7/6/E76850B8-DA6E-4FF5-8CCE-A24FC513FD16/Windows6.1-KB2506143-x64.msu"
            Folder = "WMF30x64"
            File   = "Windows6.1-KB2506143-x64.msu"
        }
        @{
            # Windows Management Framewework 5.1 for Windows 8.1 x86
            Name   = "WMF51w81x86"
            URI    = "https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win8.1-KB3191564-x86.msu"
            Folder = "WMF51w81x86"
            File   = "Win8.1-KB3191564-x86.msu"
        }
        @{
            # Windows Management Framewework 5.1 for Windows 8.1 x64 and Windows 2012 R2
            Name   = "WMF51w81x64"
            URI    = "https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win8.1AndW2K12R2-KB3191564-x64.msu"
            Folder = "WMF51w81x64"
            File   = "Win8.1AndW2K12R2-KB3191564-x64.msu"
        }
        @{
            # Servicing stack update for Windows 7 SP1 x86
            Name   = "KB3177467-x86"
            URI    = "http://download.windowsupdate.com/d/msdownload/update/software/crup/2016/08/windows6.1-kb3177467-x86_7fa40e58f6a8e56eb78b09502e5c8c6c1acf0158.msu"
            Folder = "KB3177467-x86"
            File   = "windows6.1-kb3177467-x86_7fa40e58f6a8e56eb78b09502e5c8c6c1acf0158.msu"
        }
        @{
            # Servicing stack update for Windows 7 SP1 x64
            Name   = "KB3177467-x64"
            URI    = "http://download.windowsupdate.com/d/msdownload/update/software/crup/2016/08/windows6.1-kb3177467-x64_42467e48b4cfeb44112d819f50b0557d4f9bbb2f.msu"
            Folder = "KB3177467-x64"
            File   = "windows6.1-kb3177467-x64_42467e48b4cfeb44112d819f50b0557d4f9bbb2f.msu"
        }
        @{
            # Convenience rollup update for Windows 7 SP1 x86
            Name   = "KB3125574-x86"
            URI    = "http://download.windowsupdate.com/d/msdownload/update/software/updt/2016/05/windows6.1-kb3125574-v4-x86_ba1ff5537312561795cc04db0b02fbb0a74b2cbd.msu"
            Folder = "KB3125574-x86"
            File   = "windows6.1-kb3125574-v4-x86_ba1ff5537312561795cc04db0b02fbb0a74b2cbd.msu"
        }
        @{
            # Convenience rollup update for Windows 7 SP1 x64
            Name   = "KB3125574-x64"
            URI    = "http://download.windowsupdate.com/d/msdownload/update/software/updt/2016/05/windows6.1-kb3125574-v4-x64_2dafb1d203c8964239af3048b5dd4b1264cd93b9.msu"
            Folder = "KB3125574-x64"
            File   = "windows6.1-kb3125574-v4-x64_2dafb1d203c8964239af3048b5dd4b1264cd93b9.msu"
        }
        @{
            # July 2016 update rollup for Windows 7 SP1 x86
            Name   = "KB3172605-x86"
            URI    = "http://download.windowsupdate.com/d/msdownload/update/software/updt/2016/09/windows6.1-kb3172605-x86_ae03ccbd299e434ea2239f1ad86f164e5f4deeda.msu"
            Folder = "KB3172605-x86"
            File   = "windows6.1-kb3172605-x86_ae03ccbd299e434ea2239f1ad86f164e5f4deeda.msu"
        }
        @{
            # July 2016 update rollup for Windows 7 SP1 x64
            Name   = "KB3172605-x64"
            URI    = "http://download.windowsupdate.com/d/msdownload/update/software/updt/2016/09/windows6.1-kb3172605-x64_2bb9bc55f347eee34b1454b50c436eb6fd9301fc.msu"
            Folder = "KB3172605-x64"
            File   = "windows6.1-kb3172605-x64_2bb9bc55f347eee34b1454b50c436eb6fd9301fc.msu"
        }
        @{
            # July 2016 update rollup for Windows 8.1 x86
            Name   = "KB3172614-x86"
            URI    = "http://download.windowsupdate.com/c/msdownload/update/software/updt/2016/07/windows8.1-kb3172614-x86_d11c233c8598b734de72665e0d0a3f2ef007b91f.msu"
            Folder = "KB3172614-x86"
            File   = "windows8.1-kb3172614-x86_d11c233c8598b734de72665e0d0a3f2ef007b91f.msu"
        }
        @{
            # July 2016 update rollup for Windows 8.1 x64 and Windows Server 2012 R2
            Name   = "KB3172614-x64"
            URI    = "http://download.windowsupdate.com/c/msdownload/update/software/updt/2016/07/windows8.1-kb3172614-x64_e41365e643b98ab745c21dba17d1d3b6bb73cfcc.msu"
            Folder = "KB3172614-x64"
            File   = "windows8.1-kb3172614-x64_e41365e643b98ab745c21dba17d1d3b6bb73cfcc.msu"
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
            # Configure - Set Start Layout (Desktop Theme for Windows 8.1)
            Name   = "DesktopTheme"
            URI    = "Sources\Theme01.deskthemepack"
            Folder = "Set-Startlayout"
            File   = "Theme01.deskthemepack"
        }
        @{
            # Configure - Set Start Layout (Windows 8.1)
            Name   = "StartLayout8.1"
            URI    = "Sources\Default_Start_Screen_Layout.bin"
            Folder = "Set-Startlayout"
            File   = "Default_Start_Screen_Layout.bin"
        }
        @{
            # Configure - Set Start Layout (Windows 10)
            Name   = "StartLayout10"
            URI    = "Sources\Default_Start_Screen_Layout_10.bin"
            Folder = "Set-Startlayout"
            File   = "Default_Start_Screen_Layout_10.bin"
        }
        @{
            # Configure - Remove Windows Default Applications
            Name   = "Scripts"
            URI    = "Sources\Scripts.zip"
            Folder = "Scripts"
            File   = "Scripts.zip"
        }
        @{
            # Install - APP-V Client 5.1 - x86-x64
            Name   = "APPV51"
            URI    = "Sources\appv_client_setup.zip"
            Folder = "APPV51x86x64"
            File   = "appv_client_setup.zip"
        }
    )
}
