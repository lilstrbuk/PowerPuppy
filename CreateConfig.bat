@echo off
:: Set the configuration file path
set configFile=C:\Puppy\doggo.yaml

:: Check if the configuration file already exists
if exist "%configFile%" (
    echo Configuration file already exists.
    exit /b 0
)

:: Create the configuration file and populate it with default values
echo PlantName: Plant Name>> "%configFile%"
echo ### Don't touch below this. ###>> "%configFile%"
echo SharePointSiteURL: https://omnisharp.sharepoint.com/>> "%configFile%"
echo SharePointFolderPath: KSM Backups>> "%configFile%"

echo Configuration file created and populated.
exit /b 0
