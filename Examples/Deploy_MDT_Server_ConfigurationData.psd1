@{
    AllNodes = 
    @(
        @{

            #Global Settings for the configuration of Desired State Local Configuration Manager:
            NodeName                    = "*"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser        = $true
            RebootNodeIfNeeded          = $true
            ConfigurationMode           = "ApplyAndAutoCorrect"      
        },

        @{

            #Node Settings for the configuration of an MDT Server:
            NodeName           = "$env:computername"
            Role               = "MDT Server"

            #Sources for download/Prereqs
            SourcePath         = "E:\Source"

            #Local account to create for MDT
            MDTLocalAccount    = "SVCMDTConnect001"
            MDTLocalPassword   = "P@ssw0rd"

            #Client local administrator password on client
            LocalAdminPassword   = "P@ssw0rd"

            #Download and extraction temporary folder
            TempLocation       = "E:\Temp"

            #MDT deoployment share paths
            PSDriveName        = "MDT001"
            PSDrivePath        = "E:\MDTBuildLab"
            PSDriveShareName   = "MDTBuildLab$"

            #Operating system MDT directory information
            OSDirectories   = @(
                @{  
                    Ensure = "Present"
                    OperatingSystem = "Windows 7"
                }
                @{  
                    Ensure = "Present"
                    OperatingSystem = "Windows 8.1"
                }
                @{  
                    Ensure = "Present"
                    OperatingSystem = "Windows 10"
                }
                @{  
                    Ensure = "Present"
                    OperatingSystem = "Windows 2012 R2"
                }
                @{  
                    Ensure = "Present"
                    OperatingSystem = "Windows 2016 TP5"
                }
            )

            #MDT Application Folder Structure
            ApplicationFolderStructure = @(
                @{  
                    Ensure     = "Present"
                    Folder     = "Core"
                    SubFolders = @(
                        @{  
                            Ensure    = "Present"
                            SubFolder = "Configure"
                        }
                        @{  
                            Ensure    = "Present"
                            SubFolder = "Microsoft"
                        }
                    )
                }
                @{  
                    Ensure = "Present"
                    Folder = "Common Applications"
                }
            )

            #Operating systems to import to MDT
            OperatingSystems   = @(
                @{
                    Ensure     = "Present"
                    Name       = "Windows 7 x86"
                    Path       = "Windows 7"
                    SourcePath = "$SourcePath\Windows7x86"
                }
                @{
                    Ensure     = "Present"
                    Name       = "Windows 7 x64"
                    Path       = "Windows 7"
                    SourcePath = "$SourcePath\Windows7x64"
                }
                @{
                    Ensure     = "Present"
                    Name       = "Windows 8.1 x86"
                    Path       = "Windows 8.1"
                    SourcePath = "$SourcePath\Windows81x86"
                }
                @{
                    Ensure     = "Present"
                    Name       = "Windows 8.1 x64"
                    Path       = "Windows 8.1"
                    SourcePath = "$SourcePath\Windows81x64"
                }
                @{
                    Ensure     = "Present"
                    Name       = "Windows 10 x86"
                    Path       = "Windows 10"
                    SourcePath = "$SourcePath\Windows10x86"
                }
                @{
                    Ensure     = "Present"
                    Name       = "Windows 10 x64"
                    Path       = "Windows 10"
                    SourcePath = "$SourcePath\Windows10x64"
                }
                @{
                    Ensure     = "Present"
                    Name       = "Windows 2012 R2"
                    Path       = "Windows 2012 R2"
                    SourcePath = "$SourcePath\Windows2012R2"
                }
                @{
                    Ensure     = "Present"
                    Name       = "Windows 2016 TP5"
                    Path       = "Windows 2016 TP5"
                    SourcePath = "$SourcePath\Windows2016TP5"
                }
            )

            #Applications to import
            Applications   = @(
				@{
                    Ensure                = "Present"
                    Name                  = "Install - Microsoft Visual C++"
                    Path                  = "\Applications\Core\Microsoft"
                    CommandLine           = "cscript.exe Install-MicrosoftVisualC++x86x64.wsf"
                    ApplicationSourcePath = "VC++"
				}
				@{
                    Ensure                = "Present"
                    Name                  = "Install - Microsoft Silverlight - x86"
                    Path                  = "\Applications\Core\Microsoft"
                    CommandLine           = "Silverlight.exe /Q"
                    ApplicationSourcePath = "Silverlight_x86"
				}
				@{
                    Ensure                = "Present"
                    Name                  = "Install - Microsoft Silverlight - x64"
                    Path                  = "\Applications\Core\Microsoft"
                    CommandLine           = "Silverlight_x64.exe /Q"
                    ApplicationSourcePath = "Silverlight_x64"
				}
				@{
                    Ensure                = "Present"
                    Name                  = "Install - Windows Management Framework 3.0 - x86"
                    Path                  = "\Applications\Core\Microsoft"
                    CommandLine           = "wusa.exe Windows6.1-KB2506143-x86.msu /quiet /norestart"
                    ApplicationSourcePath = "WMF30x86"
				}
				@{
                    Ensure                = "Present"
                    Name                  = "Install - Windows Management Framework 3.0 - x64"
                    Path                  = "\Applications\Core\Microsoft"
                    CommandLine           = "wusa.exe Windows6.1-KB2506143-x64.msu /quiet /norestart"
                    ApplicationSourcePath = "WMF30x64"
				}
				@{
                    Ensure                = "Present"
                    Name                  = "Install - Windows Management Framework 5.0 - x64"
                    Path                  = "\Applications\Core\Microsoft"
                    CommandLine           = "wusa.exe Win8.1AndW2K12R2-KB3134758-x64.msu /quiet /norestart"
                    ApplicationSourcePath = "WMF50x64"
				}
				@{
                    Ensure                = "Present"
                    Name                  = "Configure - Set Control+Shift Keyboard Toggle"
                    Path                  = "\Applications\Core\Configure"
                    CommandLine           = "cmd /c reg import Toggle.reg"
                    ApplicationSourcePath = "KeyboardToggle"
				}
				@{
                    Ensure                = "Present"
                    Name                  = "Action - CleanupBeforeSysprep"
                    Path                  = "\Applications\Core\Configure"
                    CommandLine           = "cscript.exe Action-CleanupBeforeSysprep.wsf"
                    ApplicationSourcePath = "CleanupBeforeSysprep"
				}
				@{
                    Ensure                = "Present"
                    Name                  = "Configure - Remove Windows 8.1 Default Applications"
                    Path                  = "\Applications\Core\Configure"
                    CommandLine           = "powershell.exe -ExecutionPolicy Bypass -File Remove-Windows8.1Apps.ps1"
                    ApplicationSourcePath = "Remove-Windows8.1Apps"
				}
				@{
                    Ensure                = "Present"
                    Name                  = "Configure - Set Start Layout"
                    Path                  = "\Applications\Core\Configure"
                    CommandLine           = "powershell.exe -ExecutionPolicy Bypass -File Customize-DefaultProfile.ps1"
                    ApplicationSourcePath = "Set-Startlayout"
				}
				<#
                @{
                    Ensure                = "Present"
                    Name                  = "Install - APP-V Client 5.1 - x86-x64"
                    Path                  = "\Applications\Common Applications"
                    CommandLine           = "appv_client_setup.exe /ACCEPTEULA /q /ENABLEPACKAGESCRIPTS=1"
                    ApplicationSourcePath = "APPV51x86x64"
                }
				#>
            )

            #Task sqeuences; are dependent on imported Operating system and Applications in MDT
            TaskSequences   = @(
                @{  
                    Ensure   = "Present"
                    Name     = "Windows 7 x86"
                    Path     = "Windows 7"
					OSName   = "Windows 7\Windows 7 ENTERPRISE in Windows 7 x86 install.wim"
                    OrgName  = "BuildLab"
					Template = "Client.xml"
                    ID       = "REFW7X86-001"
                }
                @{  
                    Ensure   = "Present"
                    Name     = "Windows 7 x64"
                    Path     = "Windows 7"
					OSName   = "Windows 7\Windows 7 ENTERPRISE in Windows 7 x64 install.wim"
                    OrgName  = "BuildLab"
					Template = "Client.xml"
                    ID       = "REFW7X64-001"
                }
                @{  
                    Ensure   = "Present"
                    Name     = "Windows 8.1 x86"
                    Path     = "Windows 8.1"
					OSName   = "Windows 8.1\Windows 8.1 Enterprise in Windows 8.1 x86 install.wim"
                    OrgName  = "BuildLab"
					Template = "Client.xml"
                    ID       = "REFW81X86-001"
                }
                @{  
                    Ensure   = "Present"
                    Name     = "Windows 8.1 x64"
                    Path     = "Windows 8.1"
					OSName   = "Windows 8.1\Windows 8.1 Enterprise in Windows 8.1 x64 install.wim"
                    OrgName  = "BuildLab"
					Template = "Client.xml"
                    ID       = "REFW81X64-001"
                }
                @{
                    Ensure   = "Present"
                    Name     = "Windows 10 x86"
                    Path     = "Windows 10"
					OSName   = "Windows 10\Windows 10 Enterprise in Windows 10 x86 install.wim"
                    OrgName  = "BuildLab"
					Template = "Client.xml"
                    ID       = "REFW10X86-001"
                }
                @{
                    Ensure   = "Present"
                    Name     = "Windows 10 x64"
                    Path     = "Windows 10"
					OSName   = "Windows 10\Windows 10 Enterprise in Windows 10 x64 install.wim"
                    OrgName  = "BuildLab"
					Template = "Client.xml"
                    ID       = "REFW10X64-001"
					Customize = @(
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
							Name       = "Cleanup before Sysprep"
							Type       = "Group"
							GroupName  = "State Restore"
							AddAfter   = "Apply Local GPO Package"
						}
						@{
							Name       = "Custom Tasks"
							Type       = "Group"
							GroupName  = "State Restore"
							NewName    = "Custom Tasks (Post-Windows Update). "
						}
						@{
							Name       = "Install - Microsoft NET Framework 3.5.1"
							Type       = "Install Roles and Features"
							GroupName  = "Custom Tasks (Pre-Windows Update)"
							OSName     = "Windows 10"
							OSFeatures = "NetFx3,TelnetClient"
						}
						@{
							Name       = "Install - Microsoft Visual C++"
							Type       = "Install Application"
							AddAfter   = "Install - Microsoft NET Framework 3.5.1"
							AppName    = "Install - Microsoft Visual C++"
						}
						@{
							Name       = "Install - Microsoft Silverlight - x64"
							Type       = "Install Application"
							AddAfter   = "Install - Microsoft Visual C++"
							AppName    = "Install - Microsoft Silverlight - x64"
						}
						@{
							Name       = "Configure - Set Control+Shift Keyboard Toggle"
							Type       = "Install Application"
							AddAfter   = "Install - Microsoft Silverlight - x64"
							AppName    = "Configure - Set Control+Shift Keyboard Toggle"
						}
						@{
							Name       = "Action - CleanupBeforeSysprep"
							Type       = "Install Application"
							GroupName  = "Cleanup before Sysprep"
							AppName    = "Action - CleanupBeforeSysprep"
						}
						@{
							Name       = "Restart Computer"
							Type       = "Restart Computer"
							GroupName  = "Cleanup before Sysprep"
							AddAfter   = "Action - CleanupBeforeSysprep"
						}
					)
                }
                @{  
                    Ensure   = "Present"
                    Name     = "Windows 2012 R2"
                    Path     = "Windows 2012 R2"
					OSName   = "Windows 2012 R2\Windows Server 2012 R2 SERVERSTANDARD in Windows 2012 R2 install.wim"
                    OrgName  = "BuildLab"
					Template = "Server.xml"
                    ID       = "REFW2012R2-001"
                }
                @{  
                    Ensure   = "Present"
                    Name     = "Windows 2016 TP5"
                    Path     = "Windows 2016 TP5"
					OSName   = "Windows 2016 TP5\Windows Server 2016 Technical Preview 5 SERVERDATACENTER in Windows 2016 TP5 install.wim"
                    OrgName  = "BuildLab"
					Template = "Server.xml"
                    ID       = "REFW2016TP5-001"
                }
            )

            #Custom folder/files to add to the MDT
			<#
            CustomSettings   = @(
                @{  
                    Ensure     = "Present"
                    Name       = "PEExtraFiles"
                    Version    = "1.0.0.0"
                    SourcePath = "/PEExtraFiles"
                }
                @{  
                    Ensure     = "Present"
                    Name       = "Scripts"
                    Version    = "1.0.0.0"
                    SourcePath = "/Scripts"
                    Protected  = $true
                }
            )
			#>

            #Custom settings and boot ini file management
            CustomizeIniFiles  = @(
                @{  
                    Ensure               = "Present"
                    Name                 = "CustomSettingsIni"
                    Path                 = "\Control\CustomSettings.ini"
                    HomePage             = "http://companyURL"
                    SkipAdminPassword    = "NO"
                    SkipApplications     = "YES"
                    SkipBitLocker        = "NO"
                    SkipCapture          = "YES"
                    SkipComputerBackup   = "YES"
                    SkipComputerName     = "NO"
                    SkipDomainMembership = "NO"
                    SkipFinalSummary     = "NO"
                    SkipLocaleSelection  = "NO"
                    SkipPackageDisplay   = "YES"
                    SkipProductKey       = "YES"
                    SkipRoles            = "YES"
                    SkipSummary          = "NO"
                    SkipTimeZone         = "NO"
                    SkipUserData         = "YES"
                    SkipTaskSequence     = "NO"
                    JoinDomain           = "ad.company.net"
                    DomainAdmin          = "DomainJoinAccount"
                    DomainAdminDomain    = "ad.company.net"
                    DomainAdminPassword  = "DomainJoinAccountPassword"
                    MachineObjectOU      = "OU=Clients,OU=company,DC=ad,DC=company,DC=net"
                    TimeZoneName         = "W. Europe Standard Time"
                    WSUSServer           = "http://fqdn:port"
                    UserLocale           = "en-US"
                    KeyboardLocale       = "en-US"
                    UILanguage           = "en-US"
                }
                @{  
                    Ensure           = "Present"
                    Name             = "BootstrapIni"
                    Path             = "\Control\Bootstrap.ini"
                    DeployRoot       = "\DeploymentShare$"
                    KeyboardLocalePE = "0411:E0010411"
                }
            )

            #Boot image creation and management
            BootImage  = @(
                @{  
                    Ensure     = "Present"
                    Name       = "BootImage"
                    Version    = "1.0.0.0"
                    Path       = "\Boot\LiteTouchPE_x64.wim"
                    ImageName  = "LiteTouchTest X64"
                    #ExtraDirectory = "PEExtraFiles"
                    #BackgroundFile = "PEExtraFiles\background.bmp"
                    LiteTouchWIMDescription = "Customer Deployment"
                }
            )
        }

    ); 
}