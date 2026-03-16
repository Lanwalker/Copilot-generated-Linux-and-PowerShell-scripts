#
# If you want it to always auto‑compare the latest two logs:
# 
@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\)))_Scripts\Startup-Audit-DiffGUI.ps1" -AutoLatest
pause
