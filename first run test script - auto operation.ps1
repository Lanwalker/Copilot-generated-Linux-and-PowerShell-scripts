<# now, generate the automated script to use

Name it ' first run test script - auto operation.ps1
================ ================== ========================

Here you go, Robert — short, clean, and exactly what you need for a one‑click “First‑Run Test” automation.

This script:

Forces a baseline wipe

Runs the Startup‑Audit.ps1 script cleanly

Shows you the baseline log

Pauses so you can confirm everything

Prepares the system for the next reboot test

It’s the technician‑grade “reset + first boot simulation” tool

================== ==================== ====================== ===========
Here you go, Robert — short, clean, and exactly what you need for a one‑click “First‑Run Test” automation.

This script:

Forces a baseline wipe

Runs the Startup‑Audit.ps1 script cleanly

Shows you the baseline log

Pauses so you can confirm everything

Prepares the system for the next reboot test

It’s the technician‑grade “reset + first boot simulation” tool.

✅ FIRST‑RUN TEST SCRIPT — AUTO OPERATION
File: C:\)))_Scripts\first run test script - auto operation.ps1
#>
Code
<#
    File:    C:\)))_Scripts\first run test script - auto operation.ps1
    Purpose: Automate a clean first-run baseline test for the Startup-Audit toolkit.
#>

Write-Host ""
Write-Host "============================================================"
Write-Host " FIRST RUN TEST SCRIPT - AUTO OPERATION"
Write-Host "============================================================"
Write-Host ""

# Paths
$AuditScript = "C:\)))_Scripts\Startup-Audit.ps1"
$StateRoot   = "C:\Startup-State"
$LogRoot     = "C:\Startup-Logs"

# 1. Confirm script exists
if (-not (Test-Path $AuditScript)) {
    Write-Host "ERROR: Startup-Audit.ps1 not found at:"
    Write-Host "       $AuditScript"
    Write-Host ""
    pause
    exit
}

# 2. Reset baseline state
Write-Host "Resetting baseline state..."
if (Test-Path $StateRoot) {
    Remove-Item $StateRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $StateRoot | Out-Null

# 3. Ensure log folder exists
if (-not (Test-Path $LogRoot)) {
    New-Item -ItemType Directory -Force -Path $LogRoot | Out-Null
}

Write-Host "Baseline cleared."
Write-Host ""

# 4. Run Startup-Audit to generate new baseline
Write-Host "Running Startup-Audit.ps1 to create FIRST baseline..."
Write-Host ""

powershell.exe -NoProfile -ExecutionPolicy Bypass -File $AuditScript

Write-Host ""
Write-Host "============================================================"
Write-Host " FIRST RUN COMPLETE"
Write-Host "============================================================"
Write-Host ""

# 5. Show newest log file
$LatestLog = Get-ChildItem $LogRoot -Filter *.txt | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($LatestLog) {
    Write-Host "Newest log file:"
    Write-Host "  $($LatestLog.FullName)"
    Write-Host ""
    Write-Host "Opening log in Notepad..."
    notepad.exe $LatestLog.FullName
} else {
    Write-Host "No log file found. Something went wrong."
}

Write-Host ""
Write-Host "============================================================"
Write-Host " NEXT STEP:"
Write-Host " Reboot the system to simulate SECOND BOOT."
Write-Host "============================================================"
Write-Host ""

pause
exit
<#
🧭 WHAT THIS SCRIPT DOES FOR YOU
✔ Clears the baseline
Deletes:

Code
C:\Startup-State\
So the next run is treated as a true “first boot.”

✔ Runs Startup‑Audit.ps1
This generates:

Code
Baseline created at <timestamp>
✔ Opens the baseline log automatically
So you can confirm everything is clean.

✔ Prepares you for the next reboot
After running this script, the very next reboot will generate the second‑boot log, which you can compare using:

GUI diff viewer

Console diff viewer

Notepad++ session

🎯 NEXT STEPS FOR YOU
Save this script to:

Code
C:\)))_Scripts\first run test script - auto operation.ps1
Run it once (as admin).

Confirm baseline log opens.

Reboot the system.

Let Task Scheduler run the second audit.

Compare logs using your diff tools.
#>