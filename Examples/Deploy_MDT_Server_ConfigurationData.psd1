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

            #SMB or web link to a pull server
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

            #SMB share name
            PSDriveShareName   = "MDTBuildLab$"

            #Operating system MDT directory information
            OSDirectories   = @(
                @{  
                    Ensure = "Present"
                    OperatingSystem = "Windows 10"
                }
            )

            #MDT Application Folder Structure
            ApplicationFolderStructure   = @(
                @{  
                    Ensure = "Present"
                    Folder = "Core Applications"
                    SubFolders   = @(
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

            #Selection profile creation
            SelectionProfiles  = @("WinPE x86","WinPE x64")

            #Operating systems to import to MDT
            OperatingSystems   = @(
                @{  
                    Ensure     = "Present"
                    Name       = "Windows 10 Enterprise x64"
                    Version    = "1.0.0.0"
                    Path       = "\Operating Systems\Windows 10"
                    SourcePath = "/Install"
                }
            )

            #Task sqeuences; are dependent on imported Operating system in MDT
            TaskSequences   = @(
                @{  
                    Ensure      = "Present"
                    Name        = "Windows 10 x64"
                    Path        = "\Task Sequences\Windows 10"
                    WIMFileName = "Install"
                    ID          = "01"
                }
            )

            <#
            #Applications to import
            Applications   = @(
                @{  
                    Ensure                = "Present"
                    Name                  = "Teamviewer"
                    Version               = "1.0.0.0"
                    Path                  = "\Applications\Common Applications"
                    ShortName             = "Teamviewer"
                    Publisher             = "Teamviewer"
                    Language              = "en-US"
                    CommandLine           = "install.cmd"
                    WorkingDirectory      = ".\"
                    ApplicationSourcePath = "/TeamViewer_Setup_sv"
                    DestinationFolder     = "Common Applications\Teamviewer"
                }
            )
            #>

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