<#
# save as a PowerShell System Script- C:\)))_Scripts\Startup-Audit.ps1

==================================================

Copilot : Note: I changed the initial folder location to bring the folder to the top of the folder lists using this format.

C:\)))_Scripts\Startup-Audit.ps1

Modify the scripts generated to use that name and also start putting the file names and paths in the information at the top of every script generated from now on.

And YES... add the extra ' tools ' in the following list as needed and if possible, try to generate this as a single script to keep thingssimple andeasy to implement.

---------------------------------------

also generate:
A Task Scheduler XML to auto‑run this script at startup

A diff viewer script to compare logs

A “critical changes only” mode

A registry snapshot module

A driver rollback detector

A firmware change alert

Just tell me what level of paranoia you want baked in.

-------------------------------------------

==================================================

# =====================================================================
#  Startup Change Tracker - Technician Grade
#  Creates a baseline on first run, then logs all differences on each boot
#  Output: C:\Startup-Logs\YYYY-MM-DD_HH-MM-SS.txt
# =====================================================================





=======================================================

Got it—that folder naming trick is very you, and I’ll honor it from here on out.

Below is a single, consolidated, technician‑grade script plus the Task Scheduler XML.
I’ll also bake in:

Critical‑only mode

Registry snapshot module

Driver rollback detector

Firmware change alert

Built‑in diff viewer

🧾 Main script
Path / name (as requested):  
C:\)))_Scripts\Startup-Audit.ps1

powershell
<#
    File:    C:\)))_Scripts\Startup-Audit.ps1
    Purpose: Technician-grade startup change tracker, diff viewer, and alert system
#>

param(
    [switch]$CriticalOnly,   # Only log critical changes (BIOS, drivers, updates, startup, services, registry run keys)
    [switch]$ViewDiff,       # Manual diff mode between two log files
    [string]$Log1,
    [string]$Log2
)

# ----------------- Paths -----------------
$LogRoot   = "C:\Startup-Logs"
$StateRoot = "C:\Startup-State"
$RegStateRoot = Join-Path $StateRoot "Registry"
$Timestamp = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")
$LogFile   = Join-Path $LogRoot "$Timestamp.txt"

# ----------------- Ensure folders -----------------
New-Item -ItemType Directory -Force -Path $LogRoot     | Out-Null
New-Item -ItemType Directory -Force -Path $StateRoot   | Out-Null
New-Item -ItemType Directory -Force -Path $RegStateRoot | Out-Null

# ----------------- Helper: Save / Load -----------------
function Save-State {
    param($Name, $Data)
    $Path = Join-Path $StateRoot "$Name.txt"
    $Data | Out-File -Encoding UTF8 -FilePath $Path
}

function Load-State {
    param($Name)
    $Path = Join-Path $StateRoot "$Name.txt"
    if (Test-Path $Path) { return Get-Content $Path }
    return @()
}

function Save-RegState {
    param($Name, $Data)
    $Path = Join-Path $RegStateRoot "$Name.txt"
    $Data | Out-File -Encoding UTF8 -FilePath $Path
}

function Load-RegState {
    param($Name)
    $Path = Join-Path $RegStateRoot "$Name.txt"
    if (Test-Path $Path) { return Get-Content $Path }
    return @()
}

function Compare-Section {
    param(
        [string]$Name,
        [array]$Old,
        [array]$New,
        [switch]$Critical
    )

    if ($CriticalOnly -and -not $Critical) {
        return
    }

    $Diff = Compare-Object -ReferenceObject $Old -DifferenceObject $New

    if ($Diff) {
        Add-Content $LogFile "===== $Name CHANGES ====="
        $Diff | Out-String | Add-Content $LogFile
        Add-Content $LogFile ""
    }
}

# ----------------- Manual diff viewer mode -----------------
if ($ViewDiff) {
    if (-not (Test-Path $Log1) -or -not (Test-Path $Log2)) {
        Write-Host "Both -Log1 and -Log2 must be valid file paths."
        exit 1
    }

    $L1 = Get-Content $Log1
    $L2 = Get-Content $Log2

    Write-Host "Comparing:"
    Write-Host "  $Log1"
    Write-Host "  $Log2"
    Write-Host ""

    $Diff = Compare-Object -ReferenceObject $L1 -DifferenceObject $L2 -IncludeEqual:$false
    $Diff | Out-String | Write-Host
    exit 0
}

# ----------------- Collect current system state -----------------
$Current = @{}

# Installed apps
$Current["InstalledApps"] = Get-Package |
    Sort-Object Name |
    ForEach-Object { "$($_.Name) $($_.Version)" }

# Drivers
$Current["Drivers"] = Get-WmiObject Win32_PnPSignedDriver |
    Sort-Object DeviceName |
    ForEach-Object { "$($_.DeviceName) $($_.DriverVersion)" }

# Services
$Current["Services"] = Get-Service |
    Sort-Object Name |
    ForEach-Object { "$($_.Name) $($_.Status)" }

# Startup tasks
$Current["StartupTasks"] = Get-CimInstance Win32_StartupCommand |
    Sort-Object Name |
    ForEach-Object { "$($_.Name) $($_.Command)" }

# Scheduled tasks
$Current["ScheduledTasks"] = Get-ScheduledTask |
    Sort-Object TaskName |
    ForEach-Object { "$($_.TaskName) $($_.State)" }

# Windows features
$Current["WindowsFeatures"] = Get-WindowsOptionalFeature -Online |
    Sort-Object FeatureName |
    ForEach-Object { "$($_.FeatureName) $($_.State)" }

# Updates (KBs)
$Current["Updates"] = Get-WmiObject Win32_QuickFixEngineering |
    Sort-Object HotFixID |
    ForEach-Object { "$($_.HotFixID) $($_.InstalledOn)" }

# BIOS / firmware
$Current["BIOS"] = Get-WmiObject Win32_BIOS |
    ForEach-Object { "$($_.Manufacturer) $($_.SMBIOSBIOSVersion)" }

# ----------------- Registry snapshot (Run keys, services, drivers) -----------------
function Get-RegistrySnapshot {
    $Snapshot = @()

    # Run keys (user + machine)
    $runPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    )

    foreach ($path in $runPaths) {
        if (Test-Path $path) {
            Get-ItemProperty $path | ForEach-Object {
                $_.PSObject.Properties |
                    Where-Object { $_.Name -ne "PSPath" -and $_.Name -ne "PSParentPath" -and $_.Name -ne "PSChildName" -and $_.Name -ne "PSDrive" -and $_.Name -ne "PSProvider" } |
                    ForEach-Object {
                        $Snapshot += "RUN $path $($_.Name) = $($_.Value)"
                    }
            }
        }
    }

    # Services (from registry)
    $svcPath = "HKLM:\SYSTEM\CurrentControlSet\Services"
    if (Test-Path $svcPath) {
        Get-ChildItem $svcPath | ForEach-Object {
            $name = $_.PSChildName
            $image = (Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue).ImagePath
            $start = (Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue).Start
            $Snapshot += "SERVICE $name Start=$start ImagePath=$image"
        }
    }

    # Drivers (from registry)
    $drvPath = "HKLM:\SYSTEM\CurrentControlSet\Services"
    if (Test-Path $drvPath) {
        Get-ChildItem $drvPath | ForEach-Object {
            $type = (Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue).Type
            if ($type -eq 1 -or $type -eq 2) { # kernel / file system drivers
                $name = $_.PSChildName
                $image = (Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue).ImagePath
                $Snapshot += "DRIVERREG $name ImagePath=$image"
            }
        }
    }

    return $Snapshot
}

$CurrentReg = Get-RegistrySnapshot

# ----------------- Baseline detection -----------------
$BaselineExists = Test-Path (Join-Path $StateRoot "InstalledApps.txt")

if (-not $BaselineExists) {
    foreach ($Key in $Current.Keys) {
        Save-State -Name $Key -Data $Current[$Key]
    }
    Save-RegState -Name "RegistrySnapshot" -Data $CurrentReg

    "Baseline created at $Timestamp" | Out-File $LogFile
    exit 0
}

# ----------------- Start log -----------------
Add-Content $LogFile "Startup Audit Log - $Timestamp"
Add-Content $LogFile "Script: C:\)))_Scripts\Startup-Audit.ps1"
Add-Content $LogFile "Mode: $(if ($CriticalOnly) {'CriticalOnly'} else {'Full'})"
Add-Content $LogFile "===================================================="
Add-Content $LogFile ""

# ----------------- Compare sections -----------------
foreach ($Key in $Current.Keys) {
    $Old = Load-State -Name $Key
    $New = $Current[$Key]

    $isCritical = $false
    if ($Key -in @("BIOS","Drivers","Updates","StartupTasks","Services","WindowsFeatures")) {
        $isCritical = $true
    }

    Compare-Section -Name $Key -Old $Old -New $New -Critical:$isCritical
}

# ----------------- Registry diff (critical) -----------------
$OldReg = Load-RegState -Name "RegistrySnapshot"
$DiffReg = Compare-Object -ReferenceObject $OldReg -DifferenceObject $CurrentReg

if ($DiffReg -and (-not $CriticalOnly -or $CriticalOnly)) {
    Add-Content $LogFile "===== REGISTRY SNAPSHOT CHANGES (RUN / SERVICES / DRIVERS) ====="
    $DiffReg | Out-String | Add-Content $LogFile
    Add-Content $LogFile ""
}

# ----------------- Driver rollback detector -----------------
$OldDrivers = Load-State -Name "Drivers"
$NewDrivers = $Current["Drivers"]

$DriverMapOld = @{}
foreach ($line in $OldDrivers) {
    if ($line -match "^(.*)\s+([\d\.]+)$") {
        $DriverMapOld[$matches[1]] = $matches[2]
    }
}

$DriverMapNew = @{}
foreach ($line in $NewDrivers) {
    if ($line -match "^(.*)\s+([\d\.]+)$") {
        $DriverMapNew[$matches[1]] = $matches[2]
    }
}

$RollbackDrivers = @()
foreach ($name in $DriverMapOld.Keys) {
    if ($DriverMapNew.ContainsKey($name)) {
        try {
            $oldVer = [version]$DriverMapOld[$name]
            $newVer = [version]$DriverMapNew[$name]
            if ($newVer -lt $oldVer) {
                $RollbackDrivers += "$name $oldVer -> $newVer"
            }
        } catch {
            # ignore parse errors
        }
    }
}

if ($RollbackDrivers.Count -gt 0) {
    Add-Content $LogFile "===== DRIVER ROLLBACK DETECTED ====="
    $RollbackDrivers | Out-String | Add-Content $LogFile
    Add-Content $LogFile ""
}

# ----------------- Firmware / BIOS change alert -----------------
$OldBIOS = Load-State -Name "BIOS"
$NewBIOS = $Current["BIOS"]

if ($OldBIOS -ne $NewBIOS) {
    Add-Content $LogFile "===== BIOS / FIRMWARE CHANGE DETECTED ====="
    Add-Content $LogFile "Previous: $($OldBIOS -join '; ')"
    Add-Content $LogFile "Current : $($NewBIOS -join '; ')"
    Add-Content $LogFile ""

    # crude rollback detection if version looks like a version string
    try {
        $oldVerStr = ($OldBIOS -join ' ') -replace '.*\s',''
        $newVerStr = ($NewBIOS -join ' ') -replace '.*\s',''
        $oldVer = [version]$oldVerStr
        $newVer = [version]$newVerStr
        if ($newVer -lt $oldVer) {
            Add-Content $LogFile "WARNING: BIOS / firmware version appears LOWER than previous (possible rollback)."
            Add-Content $LogFile ""
        }
    } catch {
        # ignore parse errors
    }
}

# ----------------- Update baseline -----------------
foreach ($Key in $Current.Keys) {
    Save-State -Name $Key -Data $Current[$Key]
}
Save-RegState -Name "RegistrySnapshot" -Data $CurrentReg

Add-Content $LogFile "Audit complete."
⏱ Task Scheduler XML
Save as: C:\)))_Scripts\Startup-Audit-Task.xml  
(Then import in Task Scheduler.)

This runs the script at logon with highest privileges, in CriticalOnly mode:

xml
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>Startup Audit - Technician Grade (C:\)))_Scripts\Startup-Audit.ps1)</Description>
    <Author>LocalAdmin</Author>
  </RegistrationInfo>
  <Triggers>
    <LogonTrigger>
      <Enabled>true</Enabled>
    </LogonTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <RunLevel>HighestAvailable</RunLevel>
      <LogonType>InteractiveToken</LogonType>
      <UserId>S-1-5-32-544</UserId>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>false</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT1H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-NoProfile -ExecutionPolicy Bypass -File "C:\)))_Scripts\Startup-Audit.ps1" -CriticalOnly</Arguments>
      <WorkingDirectory>C:\)))_Scripts</WorkingDirectory>
    </Exec>
  </Actions>
</Task>
🔍 Using the diff viewer
Manual compare of two logs:

powershell
powershell.exe -NoProfile -File "C:\)))_Scripts\Startup-Audit.ps1" -ViewDiff -Log1 "C:\Startup-Logs\2026-03-13_10-00-00.txt" -Log2 "C:\Startup-Logs\2026-03-14_10-00-05.txt"
If you want a separate tiny wrapper script just for diff viewing with its own header, I can spin that next—using the same filename/path header convention you just set.