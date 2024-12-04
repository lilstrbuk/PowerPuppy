@echo off
:: Enable error handling
setlocal enabledelayedexpansion

set "sub_folder=%~1"

:: Create the new subfolders
mkdir "%sub_folder%\robo\primary"
if errorlevel 0 (
    echo Subfolder created successfully: %sub_folder%\robo\primary
) else (
    echo Failed to create subfolder.
    exit /b 1
)

mkdir "%sub_folder%\robo\secondary"
if errorlevel 0 (
    echo Subfolder created successfully: %sub_folder%\robo\secondary
) else (
    echo Failed to create subfolder.
    exit /b 1
)

:: Define Kuka Paths and credentials
:definePaths
set share1=\\192.168.10.18\r1
set share2=\\192.168.10.28\r1
set username=kukauser
set password=68kuka1secpw59
set attempts=0

:: Map the network drives with credentials
:mapDrives
set /a attempts+=1
if %attempts% GTR 2 (
    echo Error: Exceeded maximum number of attempts to map network drives.
    goto afterKuka
)

rem Mapping Z: Drive
net use Z: %share1% /user:%username% %password%
if errorlevel 1 (
    echo Failed to map primary robot with credentials. Checking if drive Z: is already mounted...
    
    if exist Z:\ (
        echo Drive Z: is already mounted.
    ) else (
        echo Attempting to map drive Z: without credentials...
        net use Z: %share1%
        if errorlevel 1 (
            echo Error: Failed to map primary robot without credentials.
            goto kukaerrorHandler
        )
    )
)

rem Mapping Y: Drive
net use Y: %share2% /user:%username% %password%
if errorlevel 1 (
    echo Failed to map secondary robot with credentials. Checking if drive Y: is already mounted...
    
    if exist Y:\ (
        echo Drive Y: is already mounted.
    ) else (
        echo Attempting to map drive Y: without credentials...
        net use Y: %share2%
        if errorlevel 1 (
            echo Error: Failed to map secondary robot without credentials.
            goto kukaerrorHandler
        )
    )
)

goto afterKuka

:kukaerrorHandler
echo An error occurred while mapping network drives.
echo Attempting to delete the network drives...

:: Attempt to delete the network drives
net use Z: /delete
net use Y: /delete

:: Retry mapping the network drives
goto mapDrives

:afterKuka
:: Copy files from network paths to destination
copy "Z:\Program\Machine Specific\cal_bases_and_tools.src" "%sub_folder%\robo\primary\cal_bases_and_tools.src"
if errorlevel 0 (
    echo cal_bases_and_tools.src copied successfully from primary controller.
) else (
    echo Failed to copy cal_bases_and_tools.src from primary controller.
)

copy "Y:\Program\Machine Specific\cal_bases_and_tools.src" "%sub_folder%\robo\secondary\cal_bases_and_tools.src"
if errorlevel 0 (
    echo cal_bases_and_tools.src copied successfully from secondary controller.
) else (
    echo Failed to copy cal_bases_and_tools.src from secondary controller.
)

:: Disconnect the mapped network drives
net use Z: /delete
net use Y: /delete

:end
exit /b 0