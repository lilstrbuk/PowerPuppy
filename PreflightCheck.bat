@echo off

:: Check if the PowerShell 7 executable exists
IF EXIST "C:\Puppy\PowerShell-7\pwsh.exe" (
    echo PowerShell 7 is already unzipped.
) ELSE (
    echo PowerShell 7 is not unzipped.
    echo Unzipping PowerShell 7...
    powershell -Command "Expand-Archive -Path 'C:\Puppy\PowerShell-7.4.2-win-x64.zip' -DestinationPath 'C:\Puppy\PowerShell-7'"
    IF EXIST "C:\Puppy\PowerShell-7\pwsh.exe" (
        echo PowerShell 7 has been successfully unzipped.
    ) ELSE (
        echo Failed to unzip PowerShell 7.
        goto :end
    )
)

:: Check if the PnP.PowerShell module is installed
echo Checking for PnP.PowerShell module...
"C:\Puppy\PowerShell-7\pwsh.exe" -Command "if (Get-Module -ListAvailable -Name 'PnP.PowerShell') { exit 0 } else { exit 1 }"
IF %ERRORLEVEL% EQU 0 (
    echo PnP.PowerShell module is installed.
) ELSE (
    echo PnP.PowerShell module is not installed.
    echo Installing PnP.PowerShell module...
    "C:\Puppy\PowerShell-7\pwsh.exe" -Command "Install-Module -Name PnP.PowerShell -RequiredVersion 2.12.0 -Scope CurrentUser -Force"
    "C:\Puppy\PowerShell-7\pwsh.exe" -Command "if (Get-Module -ListAvailable -Name 'PnP.PowerShell') { exit 0 } else { exit 1 }"
    
    IF %ERRORLEVEL% EQU 0 (
        echo PnP.PowerShell module has been successfully installed.
    ) ELSE (
        echo Failed to install PnP.PowerShell module.
    )
)

:end
exit /b 0

