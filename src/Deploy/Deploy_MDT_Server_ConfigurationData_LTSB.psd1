@{
    AllNodes = 
    @(
        @{

            #Global Settings for the configuration of Desired State Local Configuration Manager:
            NodeName                       = "*"
            PSDscAllowPlainTextPassword    = $true
            RebootNodeIfNeeded             = $true
            ConfigurationMode              = "ApplyAndAutoCorrect"      
            ConfigurationModeFrequencyMins = 120
            RefreshFrequencyMins           = 120
        },

        @{
            #Node Settings for the configuration of an MDT Server:
            NodeName           = "$env:computername"
            Role               = "MDT Server"

            #Sources for download/Prereqs
            SourcePath         = "E:\Source"

            #MDT deoployment share paths
            PSDriveName        = "MDT001"
            PSDrivePath        = "E:\MDTBuildLab"
            PSDriveShareName   = "MDTBuildLab$"

            #Operating system MDT directory information
            OSDirectories   = @(
                @{OperatingSystem = "Windows 10"}
            )

            #MDT Application Folder Structure
            ApplicationFolderStructure = @(
                @{  
                    Folder     = "Core"
                    SubFolders = @(
                        @{SubFolder = "Configure"}
                        @{SubFolder = "Microsoft"}
                    )
                }
                @{Folder = "Common Applications"}
            )

            #Operating systems to import to MDT
            OperatingSystems   = @(
                @{
                    Name       = "Windows 10 LTSB x86"
                    Path       = "Windows 10"
                    SourcePath = "Windows10LTSBx86"
                }
                @{
                    Name       = "Windows 10 LTSB x64"
                    Path       = "Windows 10"
                    SourcePath = "Windows10LTSBx64"
                }
            )

            #Applications to import
            Applications   = @(
                @{
                    Name                  = "Install - Microsoft Visual C++"
                    Path                  = "\Applications\Core\Microsoft"
                    CommandLine           = "cscript.exe Install-MicrosoftVisualCx86x64.wsf"
                    ApplicationSourcePath = "VC++"
                }
                @{
                    Name                  = "Install - 2018-01 Cumulative Update for Windows 10 Version 1607 - x86"
                    Path                  = "\Applications\Core\Microsoft"
                    CommandLine           = "wusa.exe windows10.0-kb4056890-x86_078b34bfdc198bee26c4f13e2e45cb231ba0d843.msu /quiet /norestart"
                    ApplicationSourcePath = "KB4056890-x86"
                }
                @{
                    Name                  = "Install - 2018-01 Cumulative Update for Windows 10 Version 1607 - x64"
                    Path                  = "\Applications\Core\Microsoft"
                    CommandLine           = "wusa.exe windows10.0-kb4056890-x64_1d0f5115833be3d736caeba63c97cfa42cae8c47.msu /quiet /norestart"
                    ApplicationSourcePath = "KB4056890-x64"
                }
                @{
                    Name                  = "Configure - Set Control+Shift Keyboard Toggle"
                    Path                  = "\Applications\Core\Configure"
                    CommandLine           = "reg import Toggle.reg"
                    ApplicationSourcePath = "KeyboardToggle"
                }
                @{
                    Name                  = "Action - CleanupBeforeSysprep"
                    Path                  = "\Applications\Core\Configure"
                    CommandLine           = "cscript.exe Action-CleanupBeforeSysprep.wsf"
                    ApplicationSourcePath = "CleanupBeforeSysprep"
                }
                @{
                    Name                  = "Configure - Set Start Layout"
                    Path                  = "\Applications\Core\Configure"
                    CommandLine           = "powershell.exe -ExecutionPolicy Bypass -File .\Customize-DefaultProfile.ps1"
                    ApplicationSourcePath = "Set-Startlayout"
                }
            )

            #Task sqeuences; are dependent on imported Operating system and Applications in MDT
            TaskSequences   = @(
                @{
                    Name     = "Windows 10 LTSB x86"
                    Path     = "Windows 10"
                    OSName   = "Windows 10\Windows 10 Enterprise 2016 LTSB in Windows 10 LTSB x86 install.wim"
                    OrgName  = "BuildLab"
                    Template = "Client.xml"
                    ID       = "REFW1607X86-001"
                    Customize = @(
                        # Set Product Key needed for MSDN/Evalution Windows distributives only. Skip this step if your ISO sources is VLSC.
                        @{
                            Name        = "Set Product Key"
                            Type        = "Set Task Sequence Variable"
                            GroupName   = "Initialization"
                            Description = "KMS Client Setup Keys: https://docs.microsoft.com/en-us/windows-server/get-started/kmsclientkeys"
                            TSVarName   = "ProductKey"
                            TSVarValue  = "NPPR9-FWDCX-D2C8J-H872K-2YT43"
                            Disable     = "true"
                        }
                        @{
                            Name       = "Windows Update (Pre-Application Installation)"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            Disable    = "false"
                        }
                        @{
                            Name       = "Custom Tasks (Pre-Windows Update)"
                            Type       = "Group"
                            GroupName  = "State Restore"
                            AddAfter   = "Tattoo"
                        }
                        @{
                            Name       = "Custom Tasks"
                            Type       = "Group"
                            GroupName  = "State Restore"
                            NewName    = "Custom Tasks (Post-Windows Update)"
                        }
                        @{
                            Name       = "Cleanup before Sysprep"
                            Type       = "Group"
                            GroupName  = "State Restore"
                            AddAfter   = "Apply Local GPO Package"
                        }
                        @{
                            Name       = "Install - Microsoft NET Framework 3.5.1"
                            Type       = "Install Roles and Features"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            OSName     = "Windows 10"
                            OSFeatures = "NetFx3,TelnetClient"
                        }
                        @{
                            Name       = "Install - Microsoft Visual C++"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Install - Microsoft NET Framework 3.5.1"
                        }
                        @{
                            Name       = "Configure - Disable SMB 1.0"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            Command    = 'powershell.exe -Command "Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart"'
                            AddAfter   = "Install - Microsoft Visual C++"
                        }
                        @{
                            Name       = "Configure - Set Control+Shift Keyboard Toggle"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Configure - Disable SMB 1.0"
                        }
                        @{
                            Name       = "Configure - Set Start Layout"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Configure - Set Control+Shift Keyboard Toggle"
                        }
                        @{
                            Name       = "Configure - Enable App-V Client"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Configure - Set Start Layout"
                            Command    = 'powershell.exe -ExecutionPolicy ByPass -Command "Enable-Appv; Set-AppvClientConfiguration -EnablePackageScripts 1"'
                        }
                        @{
                            Name       = "Install - 2018-01 Cumulative Update for Windows 10 Version 1607 - x86"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Configure - Enable App-V Client"
                        }
                        @{
                            Name       = "Restart Computer"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Install - 2018-01 Cumulative Update for Windows 10 Version 1607 - x86"
                        }
                        @{
                            Name       = "Suspend"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            Disable    = "true"
                            Command    = 'cscript.exe "%SCRIPTROOT%\LTISuspend.wsf"'
                            AddAfter   = "Opt In to CEIP and WER"
                        }
                        @{
                            Name       = "Action - CleanupBeforeSysprep"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Cleanup before Sysprep"
                        }
                        @{
                            Name       = "Restart Computer 1"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Cleanup before Sysprep"
                            AddAfter   = "Action - CleanupBeforeSysprep"
                        }
                    )
                }
                @{
                    Name     = "Windows 10 LTSB x64"
                    Path     = "Windows 10"
                    OSName   = "Windows 10\Windows 10 Enterprise 2016 LTSB in Windows 10 LTSB x64 install.wim"
                    OrgName  = "BuildLab"
                    Template = "Client.xml"
                    ID       = "REFW1607X64-001"
                    Customize = @(
                        # Set Product Key needed for MSDN/Evalution Windows distributives only. Skip this step if your ISO sources is VLSC.
                        @{
                            Name        = "Set Product Key"
                            Type        = "Set Task Sequence Variable"
                            GroupName   = "Initialization"
                            Description = "KMS Client Setup Keys: https://docs.microsoft.com/en-us/windows-server/get-started/kmsclientkeys"
                            TSVarName   = "ProductKey"
                            TSVarValue  = "NPPR9-FWDCX-D2C8J-H872K-2YT43"
                            Disable     = "true"
                        }
                        @{
                            Name       = "Windows Update (Pre-Application Installation)"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            Disable    = "false"
                        }
                        @{
                            Name       = "Custom Tasks (Pre-Windows Update)"
                            Type       = "Group"
                            GroupName  = "State Restore"
                            AddAfter   = "Tattoo"
                        }
                        @{
                            Name       = "Custom Tasks"
                            Type       = "Group"
                            GroupName  = "State Restore"
                            NewName    = "Custom Tasks (Post-Windows Update)"
                        }
                        @{
                            Name       = "Cleanup before Sysprep"
                            Type       = "Group"
                            GroupName  = "State Restore"
                            AddAfter   = "Apply Local GPO Package"
                        }
                        @{
                            Name       = "Install - Microsoft NET Framework 3.5.1"
                            Type       = "Install Roles and Features"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            OSName     = "Windows 10"
                            OSFeatures = "NetFx3,TelnetClient"
                        }
                        @{
                            Name       = "Install - Microsoft Visual C++"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Install - Microsoft NET Framework 3.5.1"
                        }
                        @{
                            Name       = "Configure - Disable SMB 1.0"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            Command    = 'powershell.exe -Command "Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart"'
                            AddAfter   = "Install - Microsoft Visual C++"
                        }
                        @{
                            Name       = "Configure - Set Control+Shift Keyboard Toggle"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Configure - Disable SMB 1.0"
                        }
                        @{
                            Name       = "Configure - Set Start Layout"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Configure - Set Control+Shift Keyboard Toggle"
                        }
                        @{
                            Name       = "Configure - Enable App-V Client"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Configure - Set Start Layout"
                            Command    = 'powershell.exe -ExecutionPolicy ByPass -Command "Enable-Appv; Set-AppvClientConfiguration -EnablePackageScripts 1"'
                        }
                        @{
                            Name       = "Install - 2018-01 Cumulative Update for Windows 10 Version 1607 - x64"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Configure - Enable App-V Client"
                        }
                        @{
                            Name       = "Restart Computer"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Install - 2018-01 Cumulative Update for Windows 10 Version 1607 - x64"
                        }
                        @{
                            Name       = "Suspend"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            Disable    = "true"
                            Command    = 'cscript.exe "%SCRIPTROOT%\LTISuspend.wsf"'
                            AddAfter   = "Opt In to CEIP and WER"
                        }
                        @{
                            Name       = "Action - CleanupBeforeSysprep"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Cleanup before Sysprep"
                        }
                        @{
                            Name       = "Restart Computer 1"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Cleanup before Sysprep"
                            AddAfter   = "Action - CleanupBeforeSysprep"
                        }
                    )
                }
            )

            #Custom settings and boot ini file management
            CustomizeIniFiles  = @(
                @{  
                    Name           = "CustomSettingsIni"
                    Path           = "\Control\CustomSettings.ini"
                    Company        = "Build Lab"
                    TimeZoneName   = "Ekaterinburg Standard Time"
                    WSUSServer     = "http://fqdn:port"
                    UserLocale     = "en-US"
                    KeyboardLocale = "en-US;ru-RU"
                }
                @{  
                    Ensure         = "Present"
                    Name           = "BootstrapIni"
                    Path           = "\Control\Bootstrap.ini"
                }
            )

            #Boot image creation and management
            BootImage  = @(
                @{  
                    Version    = "1.0"
                    ExtraDirectory = "Extra"
                    BackgroundFile = "%INSTALLDIR%\Samples\Background.bmp"
                    LiteTouchWIMDescription = "MDT Build Lab"
                }
            )
        }
    )
}
