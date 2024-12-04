@echo off
:: Enable error handling
setlocal enabledelayedexpansion

set "sub_folder=%~1"

:: Define Kuka Paths
echo Defining Kuka paths...
set share1=\\192.168.10.18\r1
set share2=\\192.168.10.28\r1
set username=kukauser
set password=68kuka1secpw59

:: Create the new subfolders
echo Creating primary subfolder...
mkdir "%sub_folder%\robo\primary"
if errorlevel 1 (
    echo Failed to create primary subfolder.
    exit /b 1
)
echo Subfolder created successfully: %sub_folder%\robo\primary

echo Creating secondary subfolder...
mkdir "%sub_folder%\robo\secondary"
if errorlevel 1 (
    echo Failed to create secondary subfolder.
    exit /b 1
)
echo Subfolder created successfully: %sub_folder%\robo\secondary

:: Use PowerShell to copy files without mapping drives
echo Starting file copy operations...

:: PRIMARY Copy robo cal files from controller to destination
echo Copying files from primary controller...
powershell -Command "$password = ConvertTo-SecureString '%password%' -AsPlainText -Force; $credential = New-Object System.Management.Automation.PSCredential('%username%', $password); Copy-Item -Path '%share1%\Program\Machine Specific\cal_bases_and_tools.src' -Destination '%sub_folder%\robo\primary\cal_bases_and_tools.src' -Credential $credential"
if errorlevel 1 (
    echo Failed to copy cal_bases_and_tools.src from primary controller.
    pause
) else (
    echo cal_bases_and_tools.src copied successfully from primary controller.
)

powershell -Command "$password = ConvertTo-SecureString '%password%' -AsPlainText -Force; $credential = New-Object System.Management.Automation.PSCredential('%username%', $password); Copy-Item -Path '%share1%\Program\Machine Specific\cal_bases_and_tools.dat' -Destination '%sub_folder%\robo\primary\cal_bases_and_tools.dat' -Credential $credential"
if errorlevel 1 (
    echo Failed to copy cal_bases_and_tools.dat from primary controller.
    pause
) else (
    echo cal_bases_and_tools.dat copied successfully from primary controller.
)

:: SECONDARY Copy robo cal files from controller to destination
echo Copying files from secondary controller...
powershell -Command "$password = ConvertTo-SecureString '%password%' -AsPlainText -Force; $credential = New-Object System.Management.Automation.PSCredential('%username%', $password); Copy-Item -Path '%share2%\Program\Machine Specific\cal_bases_and_tools.src' -Destination '%sub_folder%\robo\secondary\cal_bases_and_tools.src' -Credential $credential"
if errorlevel 1 (
    echo Failed to copy cal_bases_and_tools.src from secondary controller.
    pause
) else (
    echo cal_bases_and_tools.src copied successfully from secondary controller.
)

powershell -Command "$password = ConvertTo-SecureString '%password%' -AsPlainText -Force; $credential = New-Object System.Management.Automation.PSCredential('%username%', $password); Copy-Item -Path '%share2%\Program\Machine Specific\cal_bases_and_tools.dat' -Destination '%sub_folder%\robo\secondary\cal_bases_and_tools.dat' -Credential $credential"
if errorlevel 1 (
    echo Failed to copy cal_bases_and_tools.dat from secondary controller.
    pause
) else (
    echo cal_bases_and_tools.dat copied successfully from secondary controller.
)

:end
echo Script completed.
pause
exit /b 0
