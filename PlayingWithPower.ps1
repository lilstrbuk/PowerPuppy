# ===============================
# PlayingWithPower.ps1
# ===============================
<#
.SYNOPSIS
    PowerShell script to automate file copying and SharePoint upload based on configuration.

.DESCRIPTION
    This script performs the following tasks:
    - Runs preflight checks.
    - Reads configuration from a YAML file.
    - Determines if today is a "Big Day".
    - Creates a uniquely named subfolder for backups.
    - Copies specified files from OmniSharp to the backup folder.
    - Executes additional scripts on "Big Days".
    - Uploads the backup to SharePoint.

.PARAMETER MainFolder
    The main directory path where all operations will be performed (default: C:\Puppy).

.EXAMPLE
    .\PlayingWithPower.ps1 -MainFolder "C:\Puppy"
#>

Param (
    [Parameter(Mandatory = $false)]
    [string]$MainFolder = "C:\Puppy"
)

# -------------------------------
# Function Definitions
# -------------------------------

# Function to handle errors
function Handle-Error {
    param (
        [string]$ErrorMessage
    )
    Write-Error $ErrorMessage
    exit 1
}

# Function to execute scripts with logging
function Execute-ScriptWithLogging {
    param (
        [string]$ScriptPath,
        [hashtable]$Arguments
    )
    try {
        & pwsh.exe -ExecutionPolicy Bypass -File $ScriptPath @Arguments
        if ($LASTEXITCODE -ne 0) {
            Handle-Error "Script '$ScriptPath' failed with exit code $LASTEXITCODE."
        }
    }
    catch {
        Handle-Error "Error executing script '$ScriptPath': $_"
    }
}

# Function to check if today is a "Big Day"
function Is-BigDay {
    param (
        [string[]]$BigDays
    )
    $today = (Get-Date).DayOfWeek.ToString().Substring(0,3)
    return $BigDays -contains $today
}

# Function to create a unique subfolder
function Create-UniqueSubfolder {
    param (
        [string]$BasePath,
        [string]$PlantName,
        [string]$DateFormat,
        [bool]$IsBigDay
    )
    
    if ($IsBigDay) {
        $subFolderBase = "$BasePath\Retrieved\$DateFormat $PlantName Big Backup"
    }
    else {
        $subFolderBase = "$BasePath\Retrieved\$DateFormat $PlantName Backup"
    }

    $subFolder = $subFolderBase
    $count = 1
    while (Test-Path -Path $subFolder) {
        $subFolder = "$subFolderBase $count"
        $count++
    }

    try {
        New-Item -Path $subFolder -ItemType Directory -Force | Out-Null
        Write-Host "Subfolder created successfully: $subFolder"
    }
    catch {
        Handle-Error "Failed to create subfolder: $_"
    }

    return $subFolder
}

# Function to copy files
function Copy-Files {
    param (
        [string]$SourceBasePath,
        [string[]]$Files,
        [string]$DestinationBasePath
    )

    foreach ($file in $Files) {
        $sourcePath = Join-Path -Path $SourceBasePath -ChildPath $file
        $destinationPath = Join-Path -Path $DestinationBasePath -ChildPath $file

        # Ensure the destination directory exists
        $destDir = Split-Path -Path $destinationPath -Parent
        if (-not (Test-Path -Path $destDir)) {
            try {
                New-Item -Path $destDir -ItemType Directory -Force | Out-Null
            }
            catch {
                Handle-Error "Failed to create directory: $destDir. Error: $_"
            }
        }

        try {
            Copy-Item -Path $sourcePath -Destination $destinationPath -Recurse -Force -ErrorAction Stop
            Write-Output "$file copied successfully."
        }
        catch {
            Write-Warning "Failed to copy $file. Error: $_"
        }
    }
}

# -------------------------------
# Begin Script Execution
# -------------------------------

# Run Preflight Check
$PreflightCheckScript = Join-Path -Path $MainFolder -ChildPath "PreflightCheck.ps1"
if (-not (Test-Path -Path $PreflightCheckScript)) {
    Handle-Error "PreflightCheck.ps1 not found at $PreflightCheckScript"
}

try {
    & pwsh.exe -ExecutionPolicy Bypass -File $PreflightCheckScript
    if ($LASTEXITCODE -ne 0) {
        Handle-Error "PreflightCheck.ps1 failed with exit code $LASTEXITCODE"
    }
}
catch {
    Handle-Error "Error: PreflightCheck.ps1 failed. Error: $_"
}

# Check Config File (doggo.yaml)
$yamlFile = Join-Path -Path $MainFolder -ChildPath "doggo.yaml"
if (-not (Test-Path -Path $yamlFile)) {
    Handle-Error "BIG BOOBOO: Configuration file does not exist at $yamlFile. Create one using CreateConfig.ps1"
}

# Parse YAML Configuration
try {
    # Using Get-Content to read the YAML file and pipe it to ConvertFrom-Yaml
    $config = Get-Content -Path $yamlFile -Raw | ConvertFrom-Yaml
    Write-Output "YAML Parsing Successful. Configuration Loaded:"
    $config | Format-List
}
catch {
    Handle-Error "Failed to parse YAML file. Error: $_"
}

# Verify Required Configuration Entries
$requiredKeys = @("PlantName", "SharePointSiteURL", "SharePointFolderPath", "PrimaryKRC", "SecondaryKRC", "KukaUser", "KukaPass", "BigDay", "OmnisharpPath", "FilesToCopy")

# Debugging: Output the keys present in the $config object
Write-Output "Keys present in the configuration:"
$config.GetEnumerator() | ForEach-Object { Write-Output $_.Key }

foreach ($key in $requiredKeys) {
    if (-not $config.PSObject.Properties.Name -contains $key) {
        Handle-Error "$key not found in YAML configuration."
    }
    else {
        Write-Output "$key found: $($config.$key)"
    }
}

# Determine if Today is a Big Day
$isBigDay = Is-BigDay -BigDays $config.BigDay
Write-Output "Is today a Big Day? $isBigDay"

# Get Current Date in MMDDYY Format
$dateFormat = (Get-Date).ToString("MMddyy")

# Create Unique Subfolder
$subFolder = Create-UniqueSubfolder -BasePath $MainFolder `
                                     -PlantName $config.PlantName `
                                     -DateFormat $dateFormat `
                                     -IsBigDay $isBigDay
Write-Output "Subfolder path: $subFolder"

# Copy Files from OmniSharp
$SourceBasePath = $config.OmnisharpPath
$DestinationBasePath = $subFolder

Copy-Files -SourceBasePath $SourceBasePath `
           -Files $config.FilesToCopy `
           -DestinationBasePath $DestinationBasePath

# If Big Day, Execute Additional Scripts
if ($isBigDay) {
    $litterScript = Join-Path -Path $MainFolder -ChildPath "Litter.ps1"
    $roboPuppyScript = "C:\Puppy\RoboPuppy.ps1"

    # Execute Litter.ps1
    Write-Output "Executing Litter.ps1..."
    Execute-ScriptWithLogging -ScriptPath $litterScript -Arguments @{ SubFolder = $subFolder }

    # Execute RoboPuppy.ps1 with parameters
    Write-Output "Executing RoboPuppy.ps1..."
    $roboPuppyArgs = @{
        PrimaryKRC   = $config.PrimaryKRC
        SecondaryKRC = $config.SecondaryKRC
        KukaUser     = $config.KukaUser
        KukaPass     = $config.KukaPass
        SubFolder    = $subFolder
    }
    Execute-ScriptWithLogging -ScriptPath $roboPuppyScript -Arguments $roboPuppyArgs
}

# Upload to SharePoint using SharingIsCaring.ps1
$sharingScript = "C:\Puppy\SharingIsCaring.ps1"
$sharePointArgs = @{
    PlantName            = $config.PlantName
    SharePointSiteURL    = $config.SharePointSiteURL
    SharePointFolderPath = $config.SharePointFolderPath
    FolderToUpload       = $subFolder
}

Write-Output "Uploading to SharePoint using SharingIsCaring.ps1..."
Execute-ScriptWithLogging -ScriptPath $sharingScript -Arguments $sharePointArgs

# Check and exit based on the last script's exit code
if ($LASTEXITCODE -ne 0) {
    Write-Warning "SharingIsCaring.ps1 might have failed with exit code $LASTEXITCODE."
    exit 1
}
else {
    Write-Output "SharingIsCaring.ps1 completed successfully."
}

Write-Output "End of process."
exit 0