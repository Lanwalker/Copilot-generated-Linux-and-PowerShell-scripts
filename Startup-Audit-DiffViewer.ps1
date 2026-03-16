#
# save as C:\)))_Scripts\Diff_view.ps1
# save as C:\)))_Scripts\Startup-Audit-DiffViewer.ps1 
#
# Using the diff viewer
# Manual compare of two logs:

<#
    File:    C:\)))_Scripts\Startup-Audit-DiffViewer.ps1
    Purpose: Stand-alone diff viewer for Startup-Audit logs
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Log1,

    [Parameter(Mandatory=$true)]
    [string]$Log2
)

Write-Host ""
Write-Host "============================================================"
Write-Host " Startup-Audit Diff Viewer"
Write-Host " Script: C:\)))_Scripts\Startup-Audit-DiffViewer.ps1"
Write-Host "============================================================"
Write-Host ""

# Validate files
if (-not (Test-Path $Log1)) {
    Write-Host "ERROR: Log1 not found: $Log1"
    Write-Host ""
    pause
    exit
}

if (-not (Test-Path $Log2)) {
    Write-Host "ERROR: Log2 not found: $Log2"
    Write-Host ""
    pause
    exit
}

Write-Host "Comparing:"
Write-Host "  $Log1"
Write-Host "  $Log2"
Write-Host ""

# Load logs
$L1 = Get-Content $Log1
$L2 = Get-Content $Log2

# Perform diff
$Diff = Compare-Object -ReferenceObject $L1 -DifferenceObject $L2 -IncludeEqual:$false

if ($Diff) {
    Write-Host "===== Differences Found ====="
    Write-Host ""

    # Paging-friendly output
    $Diff | Out-String | more

    Write-Host ""
    Write-Host "===== End of List ====="
} else {
    Write-Host "No differences detected."
    Write-Host ""
    Write-Host "===== End of List ====="
}

Write-Host ""
pause
exit

