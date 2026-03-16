#
# save as C:\)))_Scripts\Diff_view.ps1
# C:\)))_Scripts\Startup-Audit-DiffViewer.ps1 
#
# Using the diff viewer
# Manual compare of two logs:

powershell.exe -NoProfile -File "C:\)))_Scripts\Startup-Audit.ps1" -ViewDiff -Log1 "C:\Startup-Logs\2026-03-13_10-00-00.txt" -Log2 "C:\Startup-Logs\2026-03-14_10-00-05.txt"
