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
                @{ OperatingSystem = "Windows 10" }
            )

            #MDT Application Folder Structure
            ApplicationFolderStructure = @(
                @{
                    Folder     = "Core"
                    SubFolders = @(
                        @{ SubFolder = "Configure" }
                        @{ SubFolder = "Microsoft" }
                    )
                }
                @{ Folder = "Common Applications" }
            )

            PackagesFolderStructure = @(
                @{ Folder = "Windows 10 x64" }
            )

            #Operating systems to import to MDT
            OperatingSystems   = @(
                @{
                    Name       = "Windows 10 x64"
                    Path       = "Windows 10"
                    SourcePath = "Windows10x64"
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

            #Selection profile creation
            SelectionProfiles  = @(
                @{
                    Name        = "Windows 10 x64"
                    Comments    = "Packages for Windows 10 x64"
                    IncludePath = "Packages\Windows 10 x64"
                }
            )

            #Task sqeuences; are dependent on imported Operating system and Applications in MDT
            TaskSequences   = @(
                @{
                    Name     = "Windows 10 x64"
                    Path     = "Windows 10"
                    OSName   = "Windows 10\Windows 10 Enterprise Evaluation in Windows 10 x64 install.wim"
                    OrgName  = "BuildLab"
                    Template = "Client.xml"
                    ID       = "REFW10X64-001"
                    Customize = @(
                        # Set Product Key needed for MSDN/Evalution Windows distributives only. Skip this step if your ISO sources is VLCS.
                        @{
                            Name        = "Set Product Key"
                            Type        = "Set Task Sequence Variable"
                            GroupName   = "Initialization"
                            Description = "KMS Client Setup Keys: https://docs.microsoft.com/en-us/windows-server/get-started/kmsclientkeys"
                            TSVarName   = "ProductKey"
                            TSVarValue  = "NPPR9-FWDCX-D2C8J-H872K-2YT43"
                        }
                        @{
                            Name             = "Apply Patches"
                            Type             = "Install Updates Offline"
                            GroupName        = "Preinstall"
                            SelectionProfile = "Windows 10 x64"
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
                            OSFeatures = "NetFx3"
                        }
                        @{
                            Name       = "Configure - Disable SMB 1.0"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            Command    = 'powershell.exe -Command "Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart"'
                            AddAfter   = "Install - Microsoft NET Framework 3.5.1"
                        }
                        @{
                            Name       = "Install - Microsoft Visual C++"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Configure - Disable SMB 1.0"
                        }
                        @{
                            Name       = "Configure - Set Control+Shift Keyboard Toggle"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Install - Microsoft Visual C++"
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
                            Name       = "Suspend1"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            Disable    = "true"
                            Command    = 'cscript.exe "%SCRIPTROOT%\LTISuspend.wsf"'
                            AddAfter   = "Configure - Enable App-V Client"
                        }
                        @{
                            Name       = "Configure - Remove Windows Default Applications"
                            Type       = "Run PowerShell Script"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            PSCommand  = "%SCRIPTROOT%\Invoke-RemoveBuiltinApps.ps1"
                            AddAfter   = "Suspend1"
                        }
                        @{
                            Name       = "Suspend2"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            Disable    = "true"
                            Command    = 'cscript.exe "%SCRIPTROOT%\LTISuspend.wsf"'
                            AddAfter   = "Configure - Remove Windows Default Applications"
                        }
                        @{
                            Name       = "Restart Computer"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Suspend2"
                        }
                        @{
                            Name       = "Action - CleanupBuildWSUS"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Cleanup before Sysprep"
                            Command    = "reg delete HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /f"
                        }
                        @{
                            Name       = "Action - CleanupBeforeSysprep"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Cleanup before Sysprep"
                            AddAfter   = "Action - CleanupBuildWSUS"
                        }
                        @{
                            Name       = "Restart Computer"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Cleanup before Sysprep"
                            AddAfter   = "Action - CleanupBeforeSysprep"
                        }
                    )
                }
            )

            #Custom folder/files to add to the MDT
            CustomSettings   = @(
                @{
                    Name       = "Invoke-RemoveBuiltinApps.ps1"
                    SourcePath = "RemoveDefaultApps"
                }
            )

            #Custom settings and boot ini file management
            CustomizeIniFiles  = @(
                @{
                    Name           = "CustomSettingsIni"
                    Path           = "\Control\CustomSettings.ini"
                    Company        = "Build Lab"
                    TimeZoneName   = "Russian Standard Time"
                    WSUSServer     = "http://fqdn:port"
                    UserLocale     = "en-US"
                    KeyboardLocale = "en-US;ru-RU"
                }
                @{
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
