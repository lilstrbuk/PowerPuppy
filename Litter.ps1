# ===============================
# Litter.ps1
# ===============================

param (
    [Parameter(Mandatory = $true)]
    [string]$SubFolder
)

try {
    # Copy recent files from Config Backups
    Write-Output "Copying recent files from Config Backups..."
    & pwsh.exe -ExecutionPolicy Bypass -File "C:\Puppy\CopyRecentFiles.ps1" `
        -source "C:\OmniSharp\Config Backups" `
        -destination "$SubFolder\Config Backups" `
        -limit 10
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error: Failed to copy recent files from Config Backups."
        exit 1
    }

    # Copy recent files from Gripper Cal Force Data\Fail
    Write-Output "Copying recent files from Gripper Cal Force Data\Fail..."
    & pwsh.exe -ExecutionPolicy Bypass -File "C:\Puppy\CopyRecentFiles.ps1" `
        -source "C:\OmniSharp\DATA\Gripper Cal Force Data\Fail" `
        -destination "$SubFolder\DATA\Gripper Cal Force Data\Fail" `
        -limit 10
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error: Failed to copy recent files from Gripper Cal Force Data\Fail."
        exit 1
    }

    # Copy recent files from Gripper Cal Force Data\Pass
    Write-Output "Copying recent files from Gripper Cal Force Data\Pass..."
    & pwsh.exe -ExecutionPolicy Bypass -File "C:\Puppy\CopyRecentFiles.ps1" `
        -source "C:\OmniSharp\DATA\Gripper Cal Force Data\Pass" `
        -destination "$SubFolder\DATA\Gripper Cal Force Data\Pass" `
        -limit 10
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error: Failed to copy recent files from Gripper Cal Force Data\Pass."
        exit 1
    }

    # Copy all contents of NNET
    Write-Output "Copying all contents of NNET..."
    $sourceNNET = "C:\OmniSharp\DATA\NNET"
    $destinationNNET = "$SubFolder\DATA\NNET"
    Copy-Item -Path $sourceNNET -Destination $destinationNNET -Recurse -Force
    if ($?) {
        Write-Output "NNET copied successfully."
    }
    else {
        Write-Warning "Failed to copy NNET."
    }

    # Copy all contents of Vision Templates
    Write-Output "Copying all contents of Vision Templates..."
    $sourceVision = "C:\OmniSharp\DATA\Vision Templates"
    $destinationVision = "$SubFolder\DATA\Vision Templates"
    Copy-Item -Path $sourceVision -Destination $destinationVision -Recurse -Force
    if ($?) {
        Write-Output "Vision Templates copied successfully."
    }
    else {
        Write-Warning "Failed to copy Vision Templates."
    }

    Write-Output "Litter.ps1 completed successfully."
    exit 0
}
catch {
    Write-Error "An unexpected error occurred: $_"
    exit 1
}