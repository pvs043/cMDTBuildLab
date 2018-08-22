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
                @{OperatingSystem = "Windows 7"}
                @{OperatingSystem = "Windows 8.1"}
                @{OperatingSystem = "Windows 10"}
                @{OperatingSystem = "Windows 2012 R2"}
                @{OperatingSystem = "Windows 2016"}
            )

            #Packages Folder Structure
            PackagesFolderStructure = @(
                @{Folder = "Windows 7 x86"}
                @{Folder = "Windows 7 x64"}
                @{Folder = "Windows 8.1 x86"}
                @{Folder = "Windows 8.1 x64"}
                @{Folder = "Windows 10 x86"}
                @{Folder = "Windows 10 x64"}
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
                @{
                    Folder = "Common Applications"
                }
            )

            # MDT Drivers Folder Structure
            DriverFolderStructure = @(
                @{
                    Folder     = "Workstation"
                    SubFolders = @(
                        @{ SubFolder = "Windows-8.1"}
                        @{ SubFolder = "Windows-10"}
                    )
                }
                @{
                    Folder     = "Server"
                    SubFolders = @(
                        @{ SubFolder = "Windows-2012R2"}
                        @{ SubFolder = "Windows-2016"}
                    )
                }
            )

            # Drivers to import (will automatically search & import infs from subdirectories provided in DriverSourcePath (will attempt to expand cabs as well, but some hang the process so watch out!))
            Drivers   = @(
                @{
                    Path                  = "\Out-of-box Drivers\Workstation\Windows-8.1"
                    DriverSourcePath = "Drivers\Workstation\Windows-8.1"
                }
                @{
                    Path                  = "\Out-of-box Drivers\Workstation\Windows-10"
                    DriverSourcePath = "Drivers\Workstation\Windows-10"
                }
                @{
                    Path                  = "\Out-of-box Drivers\Server\Windows-2012R2"
                    DriverSourcePath = "Drivers\Server\Windows-2012R2"
                }
                @{
                    Path                  = "\Out-of-box Drivers\Server\Windows-2016"
                    DriverSourcePath = "Drivers\Server\Windows-2016"
                }
            )

            #Selection profile creation
            SelectionProfiles  = @(
                @{
                    Name        = "Windows 7 x86"
                    Comments    = "Packages for Windows 7 x86"
                    IncludePath = "Packages\Windows 7 x86"
                }
                @{
                    Name        = "Windows 7 x64"
                    Comments    = "Packages for Windows 7 x64"
                    IncludePath = "Packages\Windows 7 x64"
                }
                @{
                    Name        = "Windows 8.1 x86"
                    Comments    = "Packages for Windows 8.1 x86"
                    IncludePath = "Packages\Windows 8.1 x86"
                }
                @{
                    Name        = "Windows 8.1 x64"
                    Comments    = "Packages for Windows 8.1 x64"
                    IncludePath = "Packages\Windows 8.1 x64"
                }
                @{
                    Name        = "Windows 10 x86"
                    Comments    = "Packages for Windows 10 x86"
                    IncludePath = "Packages\Windows 10 x86"
                }
                @{
                    Name        = "Windows 10 x64"
                    Comments    = "Packages for Windows 10 x64"
                    IncludePath = "Packages\Windows 10 x64"
                }
            )

            #Operating systems to import to MDT
            OperatingSystems   = @(
                @{
                    Name       = "Windows 7 x86"
                    Path       = "Windows 7"
                    SourcePath = "Windows7x86"
                }
                @{
                    Name       = "Windows 7 x64"
                    Path       = "Windows 7"
                    SourcePath = "Windows7x64"
                }
                @{
                    Name       = "Windows 8.1 x86"
                    Path       = "Windows 8.1"
                    SourcePath = "Windows81x86"
                }
                @{
                    Name       = "Windows 8.1 x64"
                    Path       = "Windows 8.1"
                    SourcePath = "Windows81x64"
                }
                @{
                    Name       = "Windows 10 x86"
                    Path       = "Windows 10"
                    SourcePath = "Windows10x86"
                }
                @{
                    Name       = "Windows 10 x64"
                    Path       = "Windows 10"
                    SourcePath = "Windows10x64"
                }
                @{
                    Name       = "Windows 2012 R2"
                    Path       = "Windows 2012 R2"
                    SourcePath = "Windows2012R2"
                }
                @{
                    Name       = "Windows 2016"
                    Path       = "Windows 2016"
                    SourcePath = "Windows2016"
                }
                @{
                    Name       = "Windows 1803"
                    Path       = "Windows 2016"
                    SourcePath = "Windows1803"
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
                    Name                  = "Install - Convenience rollup update for Windows 7 SP1 - x86"
                    Path                  = "\Applications\Core\Microsoft"
                    CommandLine           = "wusa.exe windows6.1-kb3125574-v4-x86_ba1ff5537312561795cc04db0b02fbb0a74b2cbd.msu /quiet /norestart"
                    ApplicationSourcePath = "KB3125574-x86"
                }
                @{
                    Name                  = "Install - Convenience rollup update for Windows 7 SP1 - x64"
                    Path                  = "\Applications\Core\Microsoft"
                    CommandLine           = "wusa.exe windows6.1-kb3125574-v4-x64_2dafb1d203c8964239af3048b5dd4b1264cd93b9.msu /quiet /norestart"
                    ApplicationSourcePath = "KB3125574-x64"
                }
                @{
                    Name                  = "Install - July 2016 update rollup for Windows 7 SP1 - x86"
                    Path                  = "\Applications\Core\Microsoft"
                    CommandLine           = "wusa.exe windows6.1-kb3172605-x86_ae03ccbd299e434ea2239f1ad86f164e5f4deeda.msu /quiet /norestart"
                    ApplicationSourcePath = "KB3172605-x86"
                }
                @{
                    Name                  = "Install - July 2016 update rollup for Windows 7 SP1 - x64"
                    Path                  = "\Applications\Core\Microsoft"
                    CommandLine           = "wusa.exe windows6.1-kb3172605-x64_2bb9bc55f347eee34b1454b50c436eb6fd9301fc.msu /quiet /norestart"
                    ApplicationSourcePath = "KB3172605-x64"
                }
                @{
                    Name                  = "Install - July 2016 update rollup for Windows 8.1 - x86"
                    Path                  = "\Applications\Core\Microsoft"
                    CommandLine           = "wusa.exe windows8.1-kb3172614-x86_d11c233c8598b734de72665e0d0a3f2ef007b91f.msu /quiet /norestart"
                    ApplicationSourcePath = "KB3172614-x86"
                 }
                @{
                    Name                  = "Install - July 2016 update rollup for Windows 8.1 and Windows Server 2012 R2 - x64"
                    Path                  = "\Applications\Core\Microsoft"
                    CommandLine           = "wusa.exe windows8.1-kb3172614-x64_e41365e643b98ab745c21dba17d1d3b6bb73cfcc.msu /quiet /norestart"
                    ApplicationSourcePath = "KB3172614-x64"
                }
                @{
                    Name                  = "Install - Windows Management Framework 3.0 - x86"
                    Path                  = "\Applications\Core\Microsoft"
                    CommandLine           = "wusa.exe Windows6.1-KB2506143-x86.msu /quiet /norestart"
                    ApplicationSourcePath = "WMF30x86"
                }
                @{
                    Name                  = "Install - Windows Management Framework 3.0 - x64"
                    Path                  = "\Applications\Core\Microsoft"
                    CommandLine           = "wusa.exe Windows6.1-KB2506143-x64.msu /quiet /norestart"
                    ApplicationSourcePath = "WMF30x64"
                }
                @{
                    Name                  = "Install - Windows Management Framework 5.1 - x86"
                    Path                  = "\Applications\Core\Microsoft"
                    CommandLine           = "wusa.exe Win8.1-KB3191564-x86.msu /quiet /norestart"
                    ApplicationSourcePath = "WMF51w81x86"
                }
                @{
                    Name                  = "Install - Windows Management Framework 5.1 - x64"
                    Path                  = "\Applications\Core\Microsoft"
                    CommandLine           = "wusa.exe Win8.1AndW2K12R2-KB3191564-x64.msu /quiet /norestart"
                    ApplicationSourcePath = "WMF51w81x64"
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
                    Name                  = "Configure - Firewall rules"
                    Path                  = "\Applications\Core\Configure"
                    CommandLine           = "powershell.exe -ExecutionPolicy Bypass -File .\Config-NetFwRules.ps1"
                    ApplicationSourcePath = "ConfigureFirewall"
                }
                @{
                    Name                  = "Configure - Set Start Layout"
                    Path                  = "\Applications\Core\Configure"
                    CommandLine           = "powershell.exe -ExecutionPolicy Bypass -File .\Customize-DefaultProfile.ps1"
                    ApplicationSourcePath = "Set-Startlayout"
                }
                @{
                    Name                  = "Install - APP-V Client 5.1 - x86-x64"
                    Path                  = "\Applications\Common Applications"
                    CommandLine           = "appv_client_setup.exe /ACCEPTEULA /q /ENABLEPACKAGESCRIPTS=1"
                    ApplicationSourcePath = "APPV51x86x64"
                }
            )

            #Packages
            Packages = @(
                # Servicing stack update for Windows 7 SP1 x86
                @{
                    Name              = "Package_for_KB3177467 neutral x86 6.1.1.1"
                    Path              = "\Packages\Windows 7 x86"
                    PackageSourcePath = "KB3177467-x86"
                }
                # Servicing stack update for Windows 7 SP1 x86
                @{
                    Name              = "Package_for_KB3177467 neutral amd64 6.1.1.1"
                    Path              = "\Packages\Windows 7 x64"
                    PackageSourcePath = "KB3177467-x64"
                }
            )

            #Task sqeuences; are dependent on imported Operating system and Applications in MDT
            TaskSequences   = @(
                @{
                    Name     = "Windows 7 x86"
                    Path     = "Windows 7"
                    OSName   = "Windows 7\Windows 7 ENTERPRISE in Windows 7 x86 install.wim"
                    OrgName  = "BuildLab"
                    Template = "Client.xml"
                    ID       = "REFW7X86-001"
                    Customize = @(
                        # Set Product Key needed for MSDN/Evalution Windows distributives only. Skip this step if your ISO sources is VLSC.
                        @{
                            Name        = "Set Product Key"
                            Type        = "Set Task Sequence Variable"
                            GroupName   = "Initialization"
                            Description = "KMS Client Setup Keys: https://docs.microsoft.com/en-us/windows-server/get-started/kmsclientkeys"
                            TSVarName   = "ProductKey"
                            TSVarValue  = "33PXH-7Y6KF-2VJC9-XBBR8-HVTHH"
                            Disable     = "true"
                        }
                        @{
                            Name             = "Apply Patches"
                            Type             = "Install Updates Offline"
                            GroupName        = "Preinstall"
                            SelectionProfile = "Windows 7 x86"
                        }
                        @{
                            Name       = "Windows Update (Pre-Application Installation)"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            Disable    = "false"
                        }
                        @{
                            Name       = "Windows Update (Post-Application Installation)"
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
                            OSName     = "Windows 7"
                            OSFeatures = "InboxGames,NetFx3,TelnetClient"
                        }
                        @{
                            Name       = "Configure - Disable SMB 1.0"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            Command    = 'powershell.exe -Command "Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters SMB1 -Type DWORD -Value 0 -Force"'
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
                            Name       = "Install - Convenience rollup update for Windows 7 SP1 - x86"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Configure - Set Control+Shift Keyboard Toggle"
                        }
                        @{
                            Name       = "Restart Computer"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Install - Convenience rollup update for Windows 7 SP1 - x86"
                        }
                        @{
                            Name       = "Install - July 2016 update rollup for Windows 7 SP1 - x86"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Restart Computer"
                        }
                        @{
                            Name       = "Restart Computer 1"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Install - July 2016 update rollup for Windows 7 SP1 - x86"
                        }
                        @{
                            Name       = "Install APP-V 5.1"
                            Type       = "Group"
                            GroupName  = "State Restore"
                            AddAfter   = "Install Applications"
                        }
                        @{
                            Name       = "Install - Windows Management Framework 3.0 - x86"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Install APP-V 5.1"
                        }
                        @{
                            Name       = "Restart Computer 2"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Install APP-V 5.1"
                            AddAfter   = "Install - Windows Management Framework 3.0 - x86"
                        }
                        @{
                            Name       = "Install - APP-V Client 5.1 - x86-x64"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Install APP-V 5.1"
                            Disable    = "true"
                            AddAfter   = "Restart Computer 2"
                        }
                        @{
                            Name       = "Restart Computer 3"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Install APP-V 5.1"
                            Disable    = "true"
                            AddAfter   = "Install - APP-V Client 5.1 - x86-x64"
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
                            Name       = "Restart Computer 4"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Cleanup before Sysprep"
                            AddAfter   = "Action - CleanupBeforeSysprep"
                    }
                    )
                }
                @{
                    Name     = "Windows 7 x64"
                    Path     = "Windows 7"
                    OSName   = "Windows 7\Windows 7 ENTERPRISE in Windows 7 x64 install.wim"
                    OrgName  = "BuildLab"
                    Template = "Client.xml"
                    ID       = "REFW7X64-001"
                    Customize = @(
                        # Set Product Key needed for MSDN/Evalution Windows distributives only. Skip this step if your ISO sources is VLSC.
                        @{
                            Name        = "Set Product Key"
                            Type        = "Set Task Sequence Variable"
                            GroupName   = "Initialization"
                            Description = "KMS Client Setup Keys: https://docs.microsoft.com/en-us/windows-server/get-started/kmsclientkeys"
                            TSVarName   = "ProductKey"
                            TSVarValue  = "33PXH-7Y6KF-2VJC9-XBBR8-HVTHH"
                            Disable     = "true"
                        }
                        @{
                            Name             = "Apply Patches"
                            Type             = "Install Updates Offline"
                            GroupName        = "Preinstall"
                            SelectionProfile = "Windows 7 x64"
                        }
                        @{
                            Name       = "Windows Update (Pre-Application Installation)"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            Disable    = "false"
                        }
                        @{
                            Name       = "Windows Update (Post-Application Installation)"
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
                            OSName     = "Windows 7"
                            OSFeatures = "InboxGames,NetFx3,TelnetClient"
                        }
                        @{
                            Name       = "Configure - Disable SMB 1.0"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            Command    = 'powershell.exe -Command "Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters SMB1 -Type DWORD -Value 0 -Force"'
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
                            Name       = "Install - Convenience rollup update for Windows 7 SP1 - x64"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Configure - Set Control+Shift Keyboard Toggle"
                        }
                        @{
                            Name       = "Restart Computer"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Install - Convenience rollup update for Windows 7 SP1 - x64"
                        }
                        @{
                            Name       = "Install - July 2016 update rollup for Windows 7 SP1 - x64"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Restart Computer"
                        }
                        @{
                            Name       = "Restart Computer 1"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Install - July 2016 update rollup for Windows 7 SP1 - x64"
                        }
                        @{
                            Name       = "Install APP-V 5.1"
                            Type       = "Group"
                            GroupName  = "State Restore"
                            AddAfter   = "Install Applications"
                        }
                        @{
                            Name       = "Install - Windows Management Framework 3.0 - x64"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Install APP-V 5.1"
                        }
                        @{
                            Name       = "Restart Computer 2"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Install APP-V 5.1"
                            AddAfter   = "Install - Windows Management Framework 3.0 - x64"
                        }
                        @{
                            Name       = "Install - APP-V Client 5.1 - x86-x64"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Install APP-V 5.1"
                            Disable    = "true"
                            AddAfter   = "Restart Computer 2"
                        }
                        @{
                            Name       = "Restart Computer 3"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Install APP-V 5.1"
                            Disable    = "true"
                            AddAfter   = "Install - APP-V Client 5.1 - x86-x64"
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
                            Name       = "Restart Computer 4"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Cleanup before Sysprep"
                            AddAfter   = "Action - CleanupBeforeSysprep"
                        }
                    )
                }
                @{
                    Name     = "Windows 8.1 x86"
                    Path     = "Windows 8.1"
                    OSName   = "Windows 8.1\Windows 8.1 Enterprise in Windows 8.1 x86 install.wim"
                    OrgName  = "BuildLab"
                    Template = "Client.xml"
                    ID       = "REFW81X86-001"
                    Customize = @(
                        # Set Product Key needed for MSDN/Evalution Windows distributives only. Skip this step if your ISO sources is VLSC.
                        @{
                            Name        = "Set Product Key"
                            Type        = "Set Task Sequence Variable"
                            GroupName   = "Initialization"
                            Description = "KMS Client Setup Keys: https://docs.microsoft.com/en-us/windows-server/get-started/kmsclientkeys"
                            TSVarName   = "ProductKey"
                            TSVarValue  = "MHF9N-XY6XB-WVXMC-BTDCT-MKKG7"
                            Disable     = "true"
                        }
                        @{
                            Name             = "Apply Patches"
                            Type             = "Install Updates Offline"
                            GroupName        = "Preinstall"
                            SelectionProfile = "Windows 8.1 x86"
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
                            OSName     = "Windows 8.1"
                            OSFeatures = "NetFx3"
                        }
                        @{
                            Name       = "Install - Microsoft Visual C++"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Install - Microsoft NET Framework 3.5.1"
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
                            Name       = "Install - July 2016 update rollup for Windows 8.1 - x86"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Configure - Set Start Layout"
                        }
                        @{
                            Name       = "Restart Computer"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Install - July 2016 update rollup for Windows 8.1 - x86"
                        }
                        @{
                            Name       = "Configure - Disable SMB 1.0"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            Command    = 'powershell.exe -Command "Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart"'
                            AddAfter   = "Restart Computer"
                        }
                        @{
                            Name       = "Restart Computer 1"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Configure - Disable SMB 1.0"
                        }
                        @{
                            Name       = "Install WMF 5.1 and APP-V 5.1"
                            Type       = "Group"
                            GroupName  = "State Restore"
                            AddAfter   = "Install Applications"
                        }
                        @{
                            Name       = "Install - Windows Management Framework 5.1 - x86"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Install WMF 5.1 and APP-V 5.1"
                        }
                        @{
                            Name       = "Restart Computer 2"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Install WMF 5.1 and APP-V 5.1"
                            AddAfter   = "Install - Windows Management Framework 5.1 - x86"
                        }
                        @{
                            Name       = "Install - APP-V Client 5.1 - x86-x64"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Install WMF 5.1 and APP-V 5.1"
                            Disable    = "true"
                            AddAfter   = "Restart Computer 2"
                        }
                        @{
                            Name       = "Restart Computer 3"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Install WMF 5.1 and APP-V 5.1"
                            Disable    = "true"
                            AddAfter   = "Install - APP-V Client 5.1 - x86-x64"
                        }
                        @{
                            Name       = "Set-ExecutionPolicy Bypass"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Post-Windows Update)"
                            Command    = 'powershell.exe -command "Set-ExecutionPolicy Bypass -Force"'
                        }
                        @{
                            Name       = "Configure - Remove Windows Default Applications"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Post-Windows Update)"
                            Command    = 'powershell.exe -ExecutionPolicy Bypass -File "%SCRIPTROOT%\RemoveApps.ps1"'
                            StartIn    = "%SCRIPTROOT%"
                            AddAfter   = "Set-ExecutionPolicy Bypass"
                        }
                        @{
                            Name       = "Suspend"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Post-Windows Update)"
                            Disable    = "true"
                            Command    = 'cscript.exe "%SCRIPTROOT%\LTISuspend.wsf"'
                            AddAfter   = "Configure - Remove Windows Default Applications"
                        }
                        @{
                            Name       = "Set-ExecutionPolicy RemoteSigned"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Post-Windows Update)"
                            Command    = 'powershell.exe -command "Set-ExecutionPolicy RemoteSigned -Force"'
                            AddAfter   = "Suspend"
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
                            Name       = "Restart Computer 4"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Cleanup before Sysprep"
                            AddAfter   = "Action - CleanupBeforeSysprep"
                        }
                    )
                }
                @{
                    Name     = "Windows 8.1 x64"
                    Path     = "Windows 8.1"
                    OSName   = "Windows 8.1\Windows 8.1 Enterprise in Windows 8.1 x64 install.wim"
                    OrgName  = "BuildLab"
                    Template = "Client.xml"
                    ID       = "REFW81X64-001"
                    Customize = @(
                        # Set Product Key needed for MSDN/Evalution Windows distributives only. Skip this step if your ISO sources is VLSC.
                        @{
                            Name        = "Set Product Key"
                            Type        = "Set Task Sequence Variable"
                            GroupName   = "Initialization"
                            Description = "KMS Client Setup Keys: https://docs.microsoft.com/en-us/windows-server/get-started/kmsclientkeys"
                            TSVarName   = "ProductKey"
                            TSVarValue  = "MHF9N-XY6XB-WVXMC-BTDCT-MKKG7"
                            Disable     = "true"
                        }
                        @{
                            Name             = "Apply Patches"
                            Type             = "Install Updates Offline"
                            GroupName        = "Preinstall"
                            SelectionProfile = "Windows 8.1 x64"
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
                            OSName     = "Windows 8.1"
                            OSFeatures = "NetFx3"
                        }
                        @{
                            Name       = "Install - Microsoft Visual C++"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Install - Microsoft NET Framework 3.5.1"
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
                            Name       = "Install - July 2016 update rollup for Windows 8.1 and Windows Server 2012 R2 - x64"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Configure - Set Start Layout"
                        }
                        @{
                            Name       = "Restart Computer"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Install - July 2016 update rollup for Windows 8.1 and Windows Server 2012 R2 - x64"
                        }
                        @{
                            Name       = "Configure - Disable SMB 1.0"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            Command    = 'powershell.exe -Command "Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart"'
                            AddAfter   = "Restart Computer"
                        }
                        @{
                            Name       = "Restart Computer 1"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Configure - Disable SMB 1.0"
                        }
                        @{
                            Name       = "Install WMF 5.1 and APP-V 5.1"
                            Type       = "Group"
                            GroupName  = "State Restore"
                            AddAfter   = "Install Applications"
                        }
                        @{
                            Name       = "Install - Windows Management Framework 5.1 - x64"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Install WMF 5.1 and APP-V 5.1"
                        }
                        @{
                            Name       = "Restart Computer 2"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Install WMF 5.1 and APP-V 5.1"
                            AddAfter   = "Install - Windows Management Framework 5.1 - x64"
                        }
                        @{
                            Name       = "Install - APP-V Client 5.1 - x86-x64"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Install WMF 5.1 and APP-V 5.1"
                            Disable    = "true"
                            AddAfter   = "Restart Computer 2"
                        }
                        @{
                            Name       = "Restart Computer 3"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Install WMF 5.1 and APP-V 5.1"
                            Disable    = "true"
                            AddAfter   = "Install - APP-V Client 5.1 - x86-x64"
                        }
                        @{
                            Name       = "Set-ExecutionPolicy Bypass"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Post-Windows Update)"
                            Command    = 'powershell.exe -command "Set-ExecutionPolicy Bypass -Force"'
                        }
                        @{
                            Name       = "Configure - Remove Windows Default Applications"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Post-Windows Update)"
                            Command    = 'powershell.exe -ExecutionPolicy Bypass -File "%SCRIPTROOT%\RemoveApps.ps1"'
                            StartIn    = "%SCRIPTROOT%"
                            AddAfter   = "Set-ExecutionPolicy Bypass"
                        }
                        @{
                            Name       = "Suspend"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Post-Windows Update)"
                            Disable    = "true"
                            Command    = 'cscript.exe "%SCRIPTROOT%\LTISuspend.wsf"'
                            AddAfter   = "Configure - Remove Windows Default Applications"
                        }
                        @{
                            Name       = "Set-ExecutionPolicy RemoteSigned"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Post-Windows Update)"
                            Command    = 'powershell.exe -command "Set-ExecutionPolicy RemoteSigned -Force"'
                            AddAfter   = "Suspend"
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
                            Name       = "Restart Computer 4"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Cleanup before Sysprep"
                            AddAfter   = "Action - CleanupBeforeSysprep"
                        }
                    )
                }
                @{
                    Name     = "Windows 10 x86"
                    Path     = "Windows 10"
                    OSName   = "Windows 10\Windows 10 Enterprise in Windows 10 x86 install.wim"
                    OrgName  = "BuildLab"
                    Template = "Client.xml"
                    ID       = "REFW10X86-001"
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
                            Name             = "Apply Patches"
                            Type             = "Install Updates Offline"
                            GroupName        = "Preinstall"
                            SelectionProfile = "Windows 10 x86"
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
                            Name       = "Restart Computer"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Configure - Enable App-V Client"
                        }
                        @{
                            Name       = "Set-ExecutionPolicy Bypass"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Post-Windows Update)"
                            Command    = 'powershell.exe -command "Set-ExecutionPolicy Bypass -Force"'
                        }
                        @{
                            Name       = "Configure - Remove Windows Default Applications"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Post-Windows Update)"
                            Command    = 'powershell.exe -ExecutionPolicy Bypass -File "%SCRIPTROOT%\RemoveApps.ps1"'
                            StartIn    = "%SCRIPTROOT%"
                            AddAfter   = "Set-ExecutionPolicy Bypass"
                        }
                        @{
                            Name       = "Suspend"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Post-Windows Update)"
                            Disable    = "true"
                            Command    = 'cscript.exe "%SCRIPTROOT%\LTISuspend.wsf"'
                            AddAfter   = "Configure - Remove Windows Default Applications"
                        }
                        @{
                            Name       = "Set-ExecutionPolicy RemoteSigned"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Post-Windows Update)"
                            Command    = 'powershell.exe -command "Set-ExecutionPolicy RemoteSigned -Force"'
                            AddAfter   = "Suspend"
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
                            Name       = "Restart Computer 1"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Cleanup before Sysprep"
                            AddAfter   = "Action - CleanupBeforeSysprep"
                        }
                    )
                }
                @{
                    Name     = "Windows 10 x64"
                    Path     = "Windows 10"
                    OSName   = "Windows 10\Windows 10 Enterprise in Windows 10 x64 install.wim"
                    OrgName  = "BuildLab"
                    Template = "Client.xml"
                    ID       = "REFW10X64-001"
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
                            Name       = "Restart Computer"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Configure - Enable App-V Client"
                        }
                        @{
                            Name       = "Set-ExecutionPolicy Bypass"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Post-Windows Update)"
                            Command    = 'powershell.exe -command "Set-ExecutionPolicy Bypass -Force"'
                        }
                        @{
                            Name       = "Configure - Remove Windows Default Applications"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Post-Windows Update)"
                            Command    = 'powershell.exe -ExecutionPolicy Bypass -File "%SCRIPTROOT%\RemoveApps.ps1"'
                            StartIn    = "%SCRIPTROOT%"
                            AddAfter   = "Set-ExecutionPolicy Bypass"
                        }
                        @{
                            Name       = "Suspend"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Post-Windows Update)"
                            Disable    = "true"
                            Command    = 'cscript.exe "%SCRIPTROOT%\LTISuspend.wsf"'
                            AddAfter   = "Configure - Remove Windows Default Applications"
                        }
                        @{
                            Name       = "Set-ExecutionPolicy RemoteSigned"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Post-Windows Update)"
                            Command    = 'powershell.exe -command "Set-ExecutionPolicy RemoteSigned -Force"'
                            AddAfter   = "Suspend"
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
                            Name       = "Restart Computer 1"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Cleanup before Sysprep"
                            AddAfter   = "Action - CleanupBeforeSysprep"
                        }
                    )
                }
                @{
                    Name     = "Windows 2012 R2"
                    Path     = "Windows 2012 R2"
                    OSName   = "Windows 2012 R2\Windows Server 2012 R2 SERVERSTANDARD in Windows 2012 R2 install.wim"
                    OrgName  = "BuildLab"
                    Template = "Server.xml"
                    ID       = "REFW2012R2-001"
                    Customize = @(
                        # Set Product Key needed for MSDN/Evalution Windows distributives only. Skip this step if your ISO sources is VLSC.
                        @{
                            Name        = "Set Product Key"
                            Type        = "Set Task Sequence Variable"
                            GroupName   = "Initialization"
                            Description = "KMS Client Setup Keys: https://docs.microsoft.com/en-us/windows-server/get-started/kmsclientkeys"
                            TSVarName   = "ProductKey"
                            TSVarValue  = "D2N9P-3P6X9-2R39C-7RTCD-MDVJX"
                            Disable     = "true"
                        }
                        @{
                            Name             = "Apply Patches"
                            Type             = "Install Updates Offline"
                            GroupName        = "Preinstall"
                            SelectionProfile = "Windows 8.1 x64"
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
                            Name       = "Install WMF 5.1"
                            Type       = "Group"
                            GroupName  = "State Restore"
                            AddAfter   = "Install Applications"
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
                            OSName     = "Windows 2012 R2"
                            OSFeatures = "NET-Framework-Features"
                        }
                        @{
                            Name       = "Configure - Firewall rules"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Install - Microsoft NET Framework 3.5.1"
                        }
                        @{
                            Name       = "Configure - Set Control+Shift Keyboard Toggle"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Configure - Firewall rules"
                        }
                        @{
                            Name       = "Install - July 2016 update rollup for Windows 8.1 and Windows Server 2012 R2 - x64"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Configure - Set Control+Shift Keyboard Toggle"
                        }
                        @{
                            Name       = "Restart Computer"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Install - July 2016 update rollup for Windows 8.1 and Windows Server 2012 R2 - x64"
                        }
                        @{
                            Name       = "Configure - Disable SMB 1.0"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            Command    = 'powershell.exe -Command "Remove-WindowsFeature -Name FS-SMB1"'
                            Disable    = "true"
                            AddAfter   = "Restart Computer"
                        }
                        @{
                            Name       = "Restart Computer 1"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            Disable    = "true"
                            AddAfter   = "Configure - Disable SMB 1.0"
                        }
                        @{
                            Name       = "Install - Windows Management Framework 5.1 - x64"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Install WMF 5.1"
                        }
                        @{
                            Name       = "Restart Computer 2"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Install WMF 5.1"
                            AddAfter   = "Install - Windows Management Framework 5.1 - x64"
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
                            Name       = "Restart Computer 3"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Cleanup before Sysprep"
                            AddAfter   = "Action - CleanupBeforeSysprep"
                        }
                    )
                }
                @{
                    Name     = "Windows 2016"
                    Path     = "Windows 2016"
                    OSName   = "Windows 2016\Windows Server 2016 SERVERSTANDARD in Windows 2016 install.wim"
                    OrgName  = "BuildLab"
                    Template = "Server.xml"
                    ID       = "REFW2016-001"
                    Customize = @(
                        # Set Product Key needed for MSDN/Evalution Windows distributives only. Skip this step if your ISO sources is VLSC.
                        @{
                            Name        = "Set Product Key"
                            Type        = "Set Task Sequence Variable"
                            GroupName   = "Initialization"
                            Description = "KMS Client Setup Keys: https://docs.microsoft.com/en-us/windows-server/get-started/kmsclientkeys"
                            TSVarName   = "ProductKey"
                            TSVarValue  = "WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY"
                            Disable     = "true"
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
                            Name       = "Configure - Firewall rules"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                        }
                        @{
                            Name       = "Configure - Set Control+Shift Keyboard Toggle"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Configure - Firewall rules"
                        }
                        @{
                            Name       = "Configure - Disable SMB 1.0"
                            Type       = "Run Command Line"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            Command    = 'powershell.exe -Command "Remove-WindowsFeature -Name FS-SMB1"'
                            Disable    = "true"
                            AddAfter   = "Configure - Set Control+Shift Keyboard Toggle"
                        }
                        @{
                            Name       = "Restart Computer"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            Disable    = "true"
                            AddAfter   = "Configure - Disable SMB 1.0"
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
                            Name       = "Restart Computer 1"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Cleanup before Sysprep"
                            AddAfter   = "Action - CleanupBeforeSysprep"
                        }
                    )
                }
                @{
                    Name     = "Windows 1803"
                    Path     = "Windows 2016"
                    OSName   = "Windows 2016\Windows Server 2016 SERVERDATACENTERACORE in Windows 1803 install.wim"
                    OrgName  = "BuildLab"
                    Template = "Server.xml"
                    ID       = "REFW1803-001"
                    Customize = @(
                        # Set Product Key needed for MSDN/Evalution Windows distributives only. Skip this step if your ISO sources is VLSC.
                        @{
                            Name        = "Set Product Key"
                            Type        = "Set Task Sequence Variable"
                            GroupName   = "Initialization"
                            Description = "KMS Client Setup Keys: https://docs.microsoft.com/en-us/windows-server/get-started/kmsclientkeys"
                            TSVarName   = "ProductKey"
                            TSVarValue  = "6Y6KB-N82V8-D8CQV-23MJW-BWTG6"
                            Disable     = "true"
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
                            Name       = "Configure - Firewall rules"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Cleanup before Sysprep"
                        }
                        @{
                            Name       = "Configure - Set Control+Shift Keyboard Toggle"
                            Type       = "Install Application"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            AddAfter   = "Configure - Firewall rules"
                        }
                        @{
                            Name       = "Restart Computer"
                            Type       = "Restart Computer"
                            GroupName  = "State Restore"
                            SubGroup   = "Custom Tasks (Pre-Windows Update)"
                            Disable    = "true"
                            AddAfter   = "Configure - Set Control+Shift Keyboard Toggle"
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
                            Name       = "Restart Computer 1"
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
                    Name       = "Scripts"
                    SourcePath = "Scripts"
                    TestFiles  = @("RemoveApps.ps1",
                                   "RemoveApps81.xml",
                                   "RemoveApps10.xml"
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
