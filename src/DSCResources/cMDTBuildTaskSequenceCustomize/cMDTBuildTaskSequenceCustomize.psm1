enum Ensure
{
    Absent
    Present
}

[DscResource()]
class cMDTBuildTaskSequenceCustomize
{
    # Task Sequence File
    [DscProperty(Key)]
    [string]$TSFile

    # Step name
    [DscProperty(Key)]
    [string]$Name

    # New step name
    [DscProperty()]
    [string]$NewName

    # Step type
    [DscProperty(Mandatory)]
    [string]$Type

    # Group for step
    [DscProperty(Mandatory)]
    [string]$GroupName

    # SubGroup for step
    [DscProperty()]
    [string]$SubGroup

    # Enable/Disable step
    [DscProperty()]
    [string]$Disable

    # Description
    [DscProperty()]
    [string]$Description

    # Add this step after that step
    [DscProperty()]
    [string]$AddAfter

    # TS variable name
    [DscProperty()]
    [string]$TSVarName

    # TS variable value
    [DscProperty()]
    [string]$TSVarValue

    # OS name for OS features
    [DscProperty()]
    [string]$OSName

    # OS features
    [DscProperty()]
    [string]$OSFeatures

    # Command line for 'Run Command line' step
    [DscProperty()]
    [string]$Command

    # Start directory for 'Run Command line' step
    [DscProperty()]
    [string]$StartIn

    # Command line for 'Run PowerShell Script' step
    [DscProperty()]
    [string]$PSCommand

    # Parameters to Pass to PS Script
    [DscProperty()]
    [string]$PSParameters

    # Selection profile for 'Apply Patches' step
    [DscProperty()]
    [string]$SelectionProfile

    [DscProperty(Mandatory)]
    [string]$PSDriveName

    [DscProperty(Mandatory)]
    [string]$PSDrivePath

    [void] Set()
    {
        $TS = $this.LoadTaskSequence()

        # Set node:
        # $group     - 1st level
        # $AddGroup  - Group to add
        # $Step      - Step (or Group) to add
        # $AfterStep - Insert after this step (may be null)
        $group = $TS.sequence.group | Where-Object {$_.Name -eq $this.GroupName}
        if ($this.Type -eq "Group") {
            $step = $group.group | Where-Object {$_.Name -eq $this.Name}
        }
        else {
            $step = $group.step | Where-Object {$_.Name -eq $this.Name}
        }

        if ($this.SubGroup) {
            $AddGroup = $group.group | Where-Object {$_.name -eq $this.SubGroup}
            $AfterStep = $addGroup.step | Where-Object {$_.Name -eq $this.AddAfter}
        }
        else {
            $addGroup = $group
            $AfterStep = $group.step | Where-Object {$_.Name -eq $this.AddAfter}
        }

        if ($step) {
            # Change existing step or group
            if ($this.Disable -ne "") {
                $step.disable = $this.Disable
            }
            if ($this.NewName -ne "") {
                $step.Name = $this.NewName
            }
            if ($this.SelectionProfile -ne "") {
                $step.defaultVarList.variable.'#text' = $this.SelectionProfile
            }
        }
        else {
            # Create new step or group
            if ($this.Type -eq "Group") {
                $newStep = $TS.CreateElement("group")
                $newStep.SetAttribute("expand", "true")
            }
            else {
                $newStep = $TS.CreateElement("step")
            }

            # Set common attributes
            $newStep.SetAttribute("name", $this.Name)
            if ($this.Disable -ne "") {
                $newStep.SetAttribute("disable", $this.Disable)
            }
            else {
                $newStep.SetAttribute("disable", "false")
            }
            $newStep.SetAttribute("continueOnError", "false")
            if ($this.Description -ne "") {
                $newStep.SetAttribute("description", $this.Description)
            }
            else {
                $newStep.SetAttribute("description", "")
            }

            # Create new step
            switch ($this.Type) {
                "Set Task Sequence Variable" {
                    $this.SetTaskSequenceVariable($TS, $newStep)
                }
                "Install Roles and Features" {
                    $this.InstallRolesAndFeatures($TS, $newStep)
                }
                "Install Application" {
                    $this.AddApplication($TS, $newStep)
                }
                "Run Command Line" {
                    $this.RunCommandLine($TS, $newStep)
                }
                "Run PowerShell Script" {
                    $this.RunPowerShellScript($TS, $newStep)
                }
                "Restart Computer" {
                    $this.RestartComputer($TS, $newStep)
                }
            }

            # Insert new step into TS
            if ($AfterStep) {
                $AddGroup.InsertAfter($newStep, $AfterStep) | Out-Null
            }
            else {
                $AddGroup.AppendChild($newStep) | Out-Null
            }
        }

        $TS.Save($this.TSFile)
    }

    [bool] Test()
    {
        $TS = $this.LoadTaskSequence()
        $present = $false

        $group = $TS.sequence.group | Where-Object {$_.Name -eq $this.GroupName}
        if ($this.Type -eq "Group") {
            $step = $group.group | Where-Object {$_.Name -eq $this.Name}
        }
        else {
            $step = $group.step | Where-Object {$_.Name -eq $this.Name}
        }

        if (!$this.AddAfter) {
            if ($step) {
                if ($this.Disable -eq "true") {
                    $present = ($step.disable -eq $this.Disable)
                }
                if (!$present) {
                    if ($this.SelectionProfile -ne "") {
                        $present = ($step.defaultVarList.variable.'#text' -eq $this.SelectionProfile)
                    }
                    if ($step.Name -eq "Set Product Key") {
                        $present = ($step.defaultVarList.variable[1].'#text' -eq $this.TSVarValue)
                    }
                    if ($step.Name -like "Windows Update (*-Application Installation)") {
                        $present = ($step.disable -eq $this.disable)
                    }
                }
            }
            else {
                if ($this.NewName -ne "") {
                    # For rename "Custom Tasks" group only
                    $present = ( ($group.group | Where-Object {$_.Name -eq $this.NewName}) )
                }
                elseif ($this.SubGroup) {
                    $addGroup = $group.group | Where-Object {$_.name -eq $this.SubGroup}
                    $present = ( ($addGroup.step | Where-Object {$_.Name -eq $this.Name}) )
                }
            }
        }
        else {
            if ($this.Type -eq "Group") {
                $present = ( ($group.group | Where-Object {$_.Name -eq $this.Name}) )
            }
            else {
                $AddGroup = $group
                if ($this.SubGroup) {
                    $AddGroup = $group.group | Where-Object {$_.name -eq $this.SubGroup}
                }
                $present = ( ($addGroup.step | Where-Object {$_.Name -eq $this.Name}) )
            }
        }

        return $present
    }

    [cMDTBuildTaskSequenceCustomize] Get()
    {
        return $this
    }

    [xml] LoadTaskSequence()
    {
        $tsPath = $this.TSFile
        $xml = [xml](Get-Content $tsPath)
        return $xml
    }

    [void] SetTaskSequenceVariable($TS, $Step)
    {
        $Step.SetAttribute("type", "SMS_TaskSequence_SetVariableAction")
        $Step.SetAttribute("successCodeList", "0 3010")

        $varList = $TS.CreateElement("defaultVarList")
        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "VariableName")
        $varName.SetAttribute("property", "VariableName")
        $varName.AppendChild($TS.CreateTextNode($this.TSVarName)) | Out-Null
        $varList.AppendChild($varName) | Out-Null

        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "VariableValue")
        $varName.SetAttribute("property", "VariableValue")
        $varName.AppendChild($TS.CreateTextNode($this.TSVarValue)) | Out-Null
        $varList.AppendChild($varName) | Out-Null

        $action = $TS.CreateElement("action")
        $action.AppendChild($TS.CreateTextNode('cscript.exe "%SCRIPTROOT%\ZTISetVariable.wsf"')) | Out-Null

        $Step.AppendChild($varList) | Out-Null
        $Step.AppendChild($action) | Out-Null
    }

    [void] InstallRolesAndFeatures($TS, $Step)
    {
        $OSIndex = @{
            "Windows 7"       = 4
            "Windows 8.1"     = 10
            "Windows 2012 R2" = 11
            "Windows 10"      = 13
            "Windows 2016"    = 14
        }

        $Step.SetAttribute("successCodeList", "0 3010")
        $Step.SetAttribute("type", "BDD_InstallRoles")
        $Step.SetAttribute("runIn", "WinPEandFullOS")

        $varList = $TS.CreateElement("defaultVarList")
        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "OSRoleIndex")
        $varName.SetAttribute("property", "OSRoleIndex")
        $varName.AppendChild($TS.CreateTextNode($OSIndex.$($this.OSName))) | Out-Null
        $varList.AppendChild($varName) | Out-Null

        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "OSRoles")
        $varName.SetAttribute("property", "OSRoles")
        $varList.AppendChild($varName) | Out-Null

        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "OSRoleServices")
        $varName.SetAttribute("property", "OSRoleServices")
        $varList.AppendChild($varName) | Out-Null

        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "OSFeatures")
        $varName.SetAttribute("property", "OSFeatures")
        $varName.AppendChild($TS.CreateTextNode($this.OSFeatures)) | Out-Null
        $varList.AppendChild($varName) | Out-Null

        $action = $TS.CreateElement("action")
        $action.AppendChild($TS.CreateTextNode('cscript.exe "%SCRIPTROOT%\ZTIOSRole.wsf"')) | Out-Null

        $Step.AppendChild($varList) | Out-Null
        $Step.AppendChild($action) | Out-Null
    }

    [void] AddApplication($TS, $Step)
    {
        $Step.SetAttribute("successCodeList", "0 3010")
        $Step.SetAttribute("type", "BDD_InstallApplication")
        $Step.SetAttribute("runIn", "WinPEandFullOS")

        $varList = $TS.CreateElement("defaultVarList")
        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "ApplicationGUID")
        $varName.SetAttribute("property", "ApplicationGUID")

        # Get Application GUID
        Import-MDTModule
        New-PSDrive -Name $this.PSDriveName -PSProvider "MDTProvider" -Root $this.PSDrivePath -Verbose:$false | Out-Null
        $App = Get-ChildItem -Path "$($this.PSDriveName):\Applications" -Recurse | Where-Object { $_.Name -eq  $this.Name }

        $varName.AppendChild($TS.CreateTextNode($($App.guid))) | Out-Null
        $varList.AppendChild($varName) | Out-Null

        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "ApplicationSuccessCodes")
        $varName.SetAttribute("property", "ApplicationSuccessCodes")
        $varName.AppendChild($TS.CreateTextNode("0 3010")) | Out-Null
        $varList.AppendChild($varName) | Out-Null

        $action = $TS.CreateElement("action")
        $action.AppendChild($TS.CreateTextNode('cscript.exe "%SCRIPTROOT%\ZTIApplications.wsf"')) | Out-Null

        $Step.AppendChild($varList) | Out-Null
        $Step.AppendChild($action) | Out-Null
    }

    [void] RunCommandLine($TS, $Step)
    {
        $Step.SetAttribute("startIn", $this.StartIn)
        $Step.SetAttribute("successCodeList", "0 3010")
        $Step.SetAttribute("type", "SMS_TaskSequence_RunCommandLineAction")
        $Step.SetAttribute("runIn", "WinPEandFullOS")

        $varList = $TS.CreateElement("defaultVarList")
        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "PackageID")
        $varName.SetAttribute("property", "PackageID")
        $varList.AppendChild($varName) | Out-Null

        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "RunAsUser")
        $varName.SetAttribute("property", "RunAsUser")
        $varName.AppendChild($TS.CreateTextNode("false")) | Out-Null
        $varList.AppendChild($varName) | Out-Null

        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "SMSTSRunCommandLineUserName")
        $varName.SetAttribute("property", "SMSTSRunCommandLineUserName")
        $varList.AppendChild($varName) | Out-Null

        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "SMSTSRunCommandLineUserPassword")
        $varName.SetAttribute("property", "SMSTSRunCommandLineUserPassword")
        $varList.AppendChild($varName) | Out-Null

        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "LoadProfile")
        $varName.SetAttribute("property", "LoadProfile")
        $varName.AppendChild($TS.CreateTextNode("false")) | Out-Null
        $varList.AppendChild($varName) | Out-Null

        $action = $TS.CreateElement("action")
        $action.AppendChild($TS.CreateTextNode($this.Command)) | Out-Null

        $Step.AppendChild($varList) | Out-Null
        $Step.AppendChild($action) | Out-Null
    }

[void] RunPowerShellScript($TS, $Step) {
        $Step.SetAttribute("successCodeList", "0 3010")
        $Step.SetAttribute("type", "BDD_RunPowerShellAction")

        $varList = $TS.CreateElement("defaultVarList")

        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "ScriptName")
        $varName.SetAttribute("property", "ScriptName")
        $varName.AppendChild($TS.CreateTextNode($this.PSCommand)) | Out-Null
        $varList.AppendChild($varName) | Out-Null

        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "Parameters")
        $varName.SetAttribute("property", "Parameters")
        $varName.AppendChild($TS.CreateTextNode($this.PSParameters)) | Out-Null
        $varList.AppendChild($varName) | Out-Null

        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "PackageID")
        $varName.SetAttribute("property", "PackageID")
        $varList.AppendChild($varName) | Out-Null

        $action = $TS.CreateElement("action")
        $action.AppendChild($TS.CreateTextNode('cscript.exe "%SCRIPTROOT%\ZTIPowerShell.wsf"')) | Out-Null

        $Step.AppendChild($varList) | Out-Null
        $Step.AppendChild($action) | Out-Null

        $condition = $TS.CreateElement("condition")        

        $varList2 = $TS.CreateElement("expression")
        $varList2.SetAttribute("type", "SMS_TaskSequence_VariableConditionExpression")

        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "Variable")
        $varName.AppendChild($TS.CreateTextNode($this.TSVarName)) | Out-Null
        $varList2.AppendChild($varName) | Out-Null
        
        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "Operator")
        $varName.AppendChild($TS.CreateTextNode("equals")) | Out-Null
        $varList2.AppendChild($varName) | Out-Null
        
        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "Value")
        $varName.AppendChild($TS.CreateTextNode($this.TSVarValue)) | Out-Null
        $varList2.AppendChild($varName) | Out-Null
        $condition.AppendChild($varList2) | Out-Null
        
        $Step.AppendChild($condition) | Out-Null
    }


    [void] RestartComputer($TS, $Step)
    {
        $Step.SetAttribute("successCodeList", "0 3010")
        $Step.SetAttribute("type", "SMS_TaskSequence_RebootAction")
        $Step.SetAttribute("runIn", "WinPEandFullOS")

        $varList = $TS.CreateElement("defaultVarList")
        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "Message")
        $varName.SetAttribute("property", "Message")
        $varList.AppendChild($varName) | Out-Null

        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "MessageTimeout")
        $varName.SetAttribute("property", "MessageTimeout")
        $varName.AppendChild($TS.CreateTextNode("60")) | Out-Null
        $varList.AppendChild($varName) | Out-Null

        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "Target")
        $varName.SetAttribute("property", "Target")
        $varList.AppendChild($varName) | Out-Null

        $action = $TS.CreateElement("action")
        $action.AppendChild($TS.CreateTextNode("smsboot.exe /target:WinPE")) | Out-Null

        $Step.AppendChild($varList) | Out-Null
        $Step.AppendChild($action) | Out-Null
    }
}

