# 
#  File:    C:\)))_Scripts\Toolkit-Launcher.ps1
#  Purpose: Menu-driven launcher for technician scripts  
#
# =================== ==================== =====================
#
<#
    File:    C:\)))_Scripts\Toolkit-Launcher.ps1
    Purpose: Menu-driven launcher for technician scripts
#>

$base = "C:\)))_Scripts"

$items = @(
    @{ Id = 1; Name = "Run Startup Audit (normal)";      Cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$base\Startup-Audit.ps1`"" },
    @{ Id = 2; Name = "Run Startup Audit (CriticalOnly)";Cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$base\Startup-Audit.ps1`" -CriticalOnly" },
    @{ Id = 3; Name = "Diff Viewer (console)";           Cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$base\Startup-Audit-DiffViewer.ps1`"" },
    @{ Id = 4; Name = "Diff Viewer (GUI)";               Cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$base\Startup-Audit-DiffGUI.ps1`"" },
    @{ Id = 5; Name = "Diff Viewer (GUI, latest two)";   Cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$base\Startup-Audit-DiffGUI.ps1`" -AutoLatest" }
    # || more
)

while ($true) {
    Clear-Host
    Write-Host "==============================================="
    Write-Host " Technician Toolkit Launcher"
    Write-Host " Script: C:\)))_Scripts\Toolkit-Launcher.ps1"
    Write-Host "==============================================="
    Write-Host ""

    foreach ($i in $items) {
        Write-Host (" {0}. {1}" -f $i.Id, $i.Name)
    }
    Write-Host " 0. Exit"
    Write-Host ""
    $choice = Read-Host "Select an option"

    if ($choice -eq '0') { break }

    $selected = $items | Where-Object { $_.Id -eq [int]$choice }
    if ($null -eq $selected) {
        Write-Host "Invalid selection."
        pause
        continue
    }

    Clear-Host
    Write-Host "Running: $($selected.Name)"
    Write-Host "Command: $($selected.Cmd)"
    Write-Host "-----------------------------------------------"
    cmd.exe /c $selected.Cmd
    Write-Host ""
    Write-Host "===== End of List ====="
    pause
}
