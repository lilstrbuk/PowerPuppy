@echo off
:: Enable error handling
setlocal enabledelayedexpansion

set "sub_folder=%~1"

:: Call the PowerShell script to copy the most recent files
powershell -ExecutionPolicy Bypass -File "C:\Puppy\CopyRecentFiles.ps1" -source "C:\OmniSharp\Config Backups" -destination "%sub_folder%\Config Backups" -limit 10
if errorlevel 1 (
    echo Error: Failed to copy recent files from Config Backups.
    exit /b 1
)

powershell -ExecutionPolicy Bypass -File "C:\Puppy\CopyRecentFiles.ps1" -source "C:\OmniSharp\DATA\Gripper Cal Force Data\Fail" -destination "%sub_folder%\DATA\Gripper Cal Force Data\Fail" -limit 10
if errorlevel 1 (
    echo Error: Failed to copy recent files from Gripper Cal Force Data\Fail.
    exit /b 1
)

powershell -ExecutionPolicy Bypass -File "C:\Puppy\CopyRecentFiles.ps1" -source "C:\OmniSharp\DATA\Gripper Cal Force Data\Pass" -destination "%sub_folder%\DATA\Gripper Cal Force Data\Pass" -limit 10
if errorlevel 1 (
    echo Error: Failed to copy recent files from Gripper Cal Force Data\Pass.
    exit /b 1
)

:: Copy all contents of NNET
xcopy "C:\OmniSharp\DATA\NNET" "%sub_folder%\DATA\NNET" /E /I
if errorlevel 0 (
    echo NNET copied successfully.
) else (
    echo Failed to copy NNET.
)

:: Copy all contents of Vision Templates
xcopy "C:\OmniSharp\DATA\Vision Templates" "%sub_folder%\DATA\Vision Templates" /E /I
if errorlevel 0 (
    echo Vision Templates copied successfully.
) else (
    echo Failed to copy Vision Templates.
)

:end
exit /b 0
