
## save as - C:\)))_Scripts\Startup-Audit-DiffGUI.ps1
#
# Yes, many will want a GUI version.
# Really, I prefer my Notepad++ for the Windows environment for the tools it has bult-in and Notepad-plus-plus as a Linux compatible # version, if that is apossible solution.
# 
# -------------------------------------------
# 
# also generate:
# 
# A GUI diff viewer (WinForms or WPF)
# 
# A “compare latest two logs automatically” mode
# 
# A wrapper batch file so you can double‑click instead of typing parameters
# 
# A menu-driven toolkit launcher for all your scripts
#
# ================= ================= ================ ================= ==============
#

<#
    File:    C:\)))_Scripts\Startup-Audit-DiffGUI.ps1
    Purpose: GUI diff viewer for Startup-Audit logs (with Notepad++ support)
#>

param(
    [switch]$AutoLatest  # If set, auto-loads latest two logs
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$LogRoot = "C:\Startup-Logs"

function Get-LatestTwoLogs {
    if (-not (Test-Path $LogRoot)) { return @() }
    Get-ChildItem $LogRoot -Filter "*.txt" | Sort-Object LastWriteTime -Descending | Select-Object -First 2
}

function Show-Diff {
    param(
        [string]$Log1,
        [string]$Log2,
        [System.Windows.Forms.TextBox]$OutputBox
    )

    if (-not (Test-Path $Log1) -or -not (Test-Path $Log2)) {
        $OutputBox.Text = "One or both log files do not exist.`r`nLog1: $Log1`r`nLog2: $Log2"
        return
    }

    $L1 = Get-Content $Log1
    $L2 = Get-Content $Log2

    $Diff = Compare-Object -ReferenceObject $L1 -DifferenceObject $L2 -IncludeEqual:$false

    if ($Diff) {
        $text = "Differences between:`r`n$Log1`r`n$Log2`r`n`r`n"
        $text += ($Diff | Out-String)
        $text += "`r`n===== End of List ====="
        $OutputBox.Text = $text
    } else {
        $OutputBox.Text = "No differences detected between:`r`n$Log1`r`n$Log2`r`n`r`n===== End of List ====="
    }
}

function Get-NotepadPPPath {
    $paths = @(
        "C:\Program Files\Notepad++\notepad++.exe",
        "C:\Program Files (x86)\Notepad++\notepad++.exe"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) { return $p }
    }
    return $null
}

# --- Form ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "Startup-Audit Diff Viewer"
$form.Size = New-Object System.Drawing.Size(1000,700)
$form.StartPosition = "CenterScreen"

# Labels / textboxes for file paths
$lbl1 = New-Object System.Windows.Forms.Label
$lbl1.Text = "Log 1:"
$lbl1.Location = New-Object System.Drawing.Point(10,10)
$lbl1.AutoSize = $true
$form.Controls.Add($lbl1)

$txt1 = New-Object System.Windows.Forms.TextBox
$txt1.Location = New-Object System.Drawing.Point(60,8)
$txt1.Size = New-Object System.Drawing.Size(800,20)
$form.Controls.Add($txt1)

$btnBrowse1 = New-Object System.Windows.Forms.Button
$btnBrowse1.Text = "..."
$btnBrowse1.Location = New-Object System.Drawing.Point(870,7)
$btnBrowse1.Size = New-Object System.Drawing.Size(30,22)
$form.Controls.Add($btnBrowse1)

$lbl2 = New-Object System.Windows.Forms.Label
$lbl2.Text = "Log 2:"
$lbl2.Location = New-Object System.Drawing.Point(10,40)
$lbl2.AutoSize = $true
$form.Controls.Add($lbl2)

$txt2 = New-Object System.Windows.Forms.TextBox
$txt2.Location = New-Object System.Drawing.Point(60,38)
$txt2.Size = New-Object System.Drawing.Size(800,20)
$form.Controls.Add($txt2)

$btnBrowse2 = New-Object System.Windows.Forms.Button
$btnBrowse2.Text = "..."
$btnBrowse2.Location = New-Object System.Drawing.Point(870,37)
$btnBrowse2.Size = New-Object System.Drawing.Size(30,22)
$form.Controls.Add($btnBrowse2)

# Buttons
$btnCompare = New-Object System.Windows.Forms.Button
$btnCompare.Text = "Compare"
$btnCompare.Location = New-Object System.Drawing.Point(10,70)
$btnCompare.Size = New-Object System.Drawing.Size(100,25)
$form.Controls.Add($btnCompare)

$btnLatest = New-Object System.Windows.Forms.Button
$btnLatest.Text = "Compare Latest Two"
$btnLatest.Location = New-Object System.Drawing.Point(120,70)
$btnLatest.Size = New-Object System.Drawing.Size(150,25)
$form.Controls.Add($btnLatest)

$btnOpenNPP = New-Object System.Windows.Forms.Button
$btnOpenNPP.Text = "Open Both in Notepad++"
$btnOpenNPP.Location = New-Object System.Drawing.Point(280,70)
$btnOpenNPP.Size = New-Object System.Drawing.Size(190,25)
$form.Controls.Add($btnOpenNPP)

$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Text = "Close"
$btnClose.Location = New-Object System.Drawing.Point(880,70)
$btnClose.Size = New-Object System.Drawing.Size(80,25)
$form.Controls.Add($btnClose)

# Output textbox
$txtOutput = New-Object System.Windows.Forms.TextBox
$txtOutput.Location = New-Object System.Drawing.Point(10,110)
$txtOutput.Size = New-Object System.Drawing.Size(950,520)
$txtOutput.Multiline = $true
$txtOutput.ScrollBars = "Both"
$txtOutput.Font = New-Object System.Drawing.Font("Consolas",9)
$form.Controls.Add($txtOutput)

# File dialogs
$ofd = New-Object System.Windows.Forms.OpenFileDialog
$ofd.InitialDirectory = $LogRoot
$ofd.Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*"

$btnBrowse1.Add_Click({
    if ($ofd.ShowDialog() -eq "OK") {
        $txt1.Text = $ofd.FileName
    }
})

$btnBrowse2.Add_Click({
    if ($ofd.ShowDialog() -eq "OK") {
        $txt2.Text = $ofd.FileName
    }
})

$btnCompare.Add_Click({
    Show-Diff -Log1 $txt1.Text -Log2 $txt2.Text -OutputBox $txtOutput
})

$btnLatest.Add_Click({
    $logs = Get-LatestTwoLogs
    if ($logs.Count -lt 2) {
        $txtOutput.Text = "Not enough logs found in $LogRoot"
    } else {
        $txt1.Text = $logs[1].FullName
        $txt2.Text = $logs[0].FullName
        Show-Diff -Log1 $txt1.Text -Log2 $txt2.Text -OutputBox $txtOutput
    }
})

$btnOpenNPP.Add_Click({
    $npp = Get-NotepadPPPath
    if (-not $npp) {
        [System.Windows.Forms.MessageBox]::Show("Notepad++ not found. Install it or adjust the script paths.","Notepad++","OK","Information") | Out-Null
        return
    }
    if (Test-Path $txt1.Text) { Start-Process -FilePath $npp -ArgumentList "`"$($txt1.Text)`"" }
    if (Test-Path $txt2.Text) { Start-Process -FilePath $npp -ArgumentList "`"$($txt2.Text)`"" }
})

$btnClose.Add_Click({
    $form.Close()
})

# AutoLatest mode
if ($AutoLatest) {
    $logs = Get-LatestTwoLogs
    if ($logs.Count -ge 2) {
        $txt1.Text = $logs[1].FullName
        $txt2.Text = $logs[0].FullName
        Show-Diff -Log1 $txt1.Text -Log2 $txt2.Text -OutputBox $txtOutput
    } else {
        $txtOutput.Text = "Not enough logs found in $LogRoot"
    }
}

[void]$form.ShowDialog()
