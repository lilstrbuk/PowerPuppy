@echo off
:: Enable error handling
setlocal enabledelayedexpansion

:: Set the main folder path
set mainFolder=C:\Puppy

:: Call PreflightCheck.bat and check for errors
call "%mainFolder%\PreflightCheck.bat"
if errorlevel 1 (
    echo Error: PreflightCheck.bat failed.
    exit /b 1
) else (
    echo Set up passed.
)

:: Check if the doggo.yaml exists, if not, create it by calling CreateConfig.bat
if not exist "%mainFolder%\doggo.yaml" (
    echo BIG BOOBOO: Configuration file does not exist. Create one using the CreateConfig.bat
    exit /b 1
) else (
    echo Config file exists.
    set "yamlFile=%mainFolder%\doggo.yaml"
)

:: Read and parse the YAML file
for /f "usebackq tokens=1* delims=:" %%A in (%yamlFile%) do (
    set "key=%%A"
    set "value=%%B"
    set "key=!key: =!"
    set "value=!value:~1!"

    :: Handle values that may contain colons (e.g., URLs)
    if "!value:~0,8!" == "https://" (
        set "value=https://!value:~8!"
    )

    set "!key!=!value!"
)

:: Verify all entries are found and create an array
set varNames=PlantName SharePointSiteURL SharePointFolderPath PrimaryKRC SecondaryKRC KukaUser KukaPass BigDay

:: Loop through each variable name and check if it's defined
for %%v in (%varNames%) do (
    if defined %%v (
        echo %%v found: !%%v!
    ) else (
        echo %%v not found
    )
)

:: Convert BigDay to uppercase for comparison and split by comma
set "BigDay=%BigDay:~1,-1%"
set "BigDay=!BigDay:,=,!"

:: Check if today is a "Big Day"
set "isBigDay=false"
for %%d in (!BigDay!) do (
    if /i "%%d" == "%date:~0,3%" (
        set "isBigDay=true"
    )
)

:: Get the date in MMDDYY format and set subfolder name 
for /f "tokens=2 delims==." %%i in ('wmic os get localdatetime /value') do set "datetime=%%i"
set "date_format=%datetime:~4,2%%datetime:~6,2%%datetime:~2,2%"

:: Set subfolder name, add "Big" before "Backup" if it's a Big Day
if "%isBigDay%" == "true" (
    set "sub_folder_base=%mainFolder%\Retrieved\%date_format% %PlantName% Big Backup"
) else (
    set "sub_folder_base=%mainFolder%\Retrieved\%date_format% %PlantName% Backup"
)

set "sub_folder=%sub_folder_base%"
set count=1

:: Check if the subfolder already exists, and if it does, create a new one with unique number
:check_folder
if exist "%sub_folder%" (
    set /a count+=1
    set "sub_folder=%sub_folder_base% %count%"
    goto :check_folder
)

:: Create the new subfolder
mkdir "%sub_folder%"
if errorlevel 0 (
    echo Subfolder created successfully: %sub_folder%
) else (
    echo Failed to create subfolder.
    exit /b 1
)

:: Copy files and verify
mkdir "%sub_folder%\Runtime Data\LOGS"
copy "C:\OmniSharp\Runtime Data\LOGS\knife_counts.olog" "%sub_folder%\Runtime Data\LOGS\knife_counts.olog"
if errorlevel 0 (
    echo knife_counts.olog copied successfully.
) else (
    echo Failed to copy knife_counts.olog.
)

copy "C:\OmniSharp\Runtime Data\knivesperhour.csv" "%sub_folder%\Runtime Data\knivesperhour.csv"
if errorlevel 0 (
    echo knivesperhour.csv copied successfully.
) else (
    echo Failed to copy knivesperhour.csv.
)

copy "C:\OmniSharp\Grind_Everything.txt" "%sub_folder%\Grind_Everything.txt"
if errorlevel 0 (
    echo Grind_Everything.txt copied successfully.
) else (
    echo Failed to copy Grind_Everything.txt.
)

copy "C:\OmniSharp\users.ouf" "%sub_folder%\users.ouf"
if errorlevel 0 (
    echo users.ouf copied successfully.
) else (
    echo Failed to copy users.ouf.
)

:: If today is a Big Day, run Litter.bat and RoboPuppy.bat to get more files for "Big" backup
if "%isBigDay%" == "true" (
    call "%mainFolder%\Litter.bat" "%sub_folder%"
    "C:\Puppy\PowerShell-7\pwsh.exe" -ExecutionPolicy Bypass -File "C:\Puppy\RoboPuppy.ps1" -PrimaryKRC "%PrimaryKRC%" -SecondaryKRC "%SecondaryKRC%" -KukaUser "%KukaUser%" -KukaPass "%KukaPass%" -SubFolder "%sub_folder%"
)

:: Call the script to upload to SharePoint
"C:\Puppy\PowerShell-7\pwsh.exe" -ExecutionPolicy Bypass -File "C:\Puppy\SharingIsCaring.ps1" -PlantName "%PlantName%" -SharePointSiteURL "%SharePointSiteURL%" -SharePointFolderPath "%SharePointFolderPath%" -FolderToUpload "%sub_folder%"

:: Check if the script returned an error
if errorlevel 0 (
    echo SharingIsCaring.ps1 completed successfully.
    exit /b 1
) else (
    echo SharingIsCaring.ps1 might have failed.
)

echo End of process.
exit
