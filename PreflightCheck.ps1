# PreflightCheck.ps1
<#
.SYNOPSIS
    Performs preflight checks to ensure required components and modules are available.

.DESCRIPTION
    This script checks if PowerShell 7 is unzipped in the specified directory.
    If not, it unzips the PowerShell 7 archive. It also verifies if the
    PnP.PowerShell module is installed, and installs it if necessary.

.NOTES
    - Author: Your Name
    - Date: YYYY-MM-DD
    - Version: 1.2
#>

# Parameters
Param (
    [Parameter(Mandatory = $false)]
    [string]$PowerShellInstallPath = "C:\Puppy\PowerShell-7",
    
    [Parameter(Mandatory = $false)]
    [string]$PowerShellZipPath = "C:\Puppy\PowerShell-7.4.2-win-x64.zip",
    
    [Parameter(Mandatory = $false)]
    [string]$PowerShellExe = "C:\Puppy\PowerShell-7\pwsh.exe",
    
    [Parameter(Mandatory = $false)]
    [string[]]$RequiredModules = @(
        "PnP.PowerShell,2.12.0"
    )
)

# Function: Handle-Error
function Handle-Error {
    param (
        [string]$Message,
        [int]$ExitCode = 1
    )
    Write-Error $Message
    exit $ExitCode
}

# Function: Expand-PowerShellArchive
function Expand-PowerShellArchive {
    param (
        [string]$ArchivePath,
        [string]$DestinationPath
    )
    Write-Output "Unzipping PowerShell 7..."
    try {
        Expand-Archive -Path $ArchivePath -DestinationPath $DestinationPath -Force -ErrorAction Stop
        Write-Output "PowerShell 7 has been successfully unzipped to '$DestinationPath'."
    }
    catch {
        Handle-Error "Failed to unzip PowerShell 7. Error: $_"
    }
}

# Function: Check-Module
function Check-Module {
    param (
        [string]$ModuleName,
        [string]$ModuleVersion = ""
    )
    Write-Output "Checking for '$ModuleName' module..."
    $module = Get-Module -ListAvailable -Name $ModuleName
    if ($module) {
        if ($ModuleVersion) {
            # Check if the required version is installed
            $installedVersion = ($module | Sort-Object Version -Descending | Select-Object -First 1).Version
            if ($installedVersion -ge [Version]$ModuleVersion) {
                Write-Output "'$ModuleName' module version $installedVersion is already installed."
                return
            }
            else {
                Write-Output "'$ModuleName' module version is lower than required ($ModuleVersion)."
            }
        }
        else {
            Write-Output "'$ModuleName' module is already installed."
            return
        }
    }
    else {
        Write-Output "'$ModuleName' module is not installed."
    }

    # Install or Update the module
    Install-Module -Name $ModuleName -RequiredVersion $ModuleVersion -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
    # Verify installation
    $postInstallModule = Get-Module -ListAvailable -Name $ModuleName
    if ($postInstallModule) {
        if ($ModuleVersion) {
            $installedVersion = ($postInstallModule | Sort-Object Version -Descending | Select-Object -First 1).Version
            if ($installedVersion -ge [Version]$ModuleVersion) {
                Write-Output "'$ModuleName' module version $installedVersion has been successfully installed."
            }
            else {
                Handle-Error "Failed to install '$ModuleName' module version $ModuleVersion or higher."
            }
        }
        else {
            Write-Output "'$ModuleName' module has been successfully installed."
        }
    }
    else {
        Handle-Error "Failed to install '$ModuleName' module."
    }
}

# Main Script Execution

# 1. Check PowerShell Version
$requiredPSVersion = [Version]"7.3.0"
$currentPSVersion = $PSVersionTable.PSVersion

if ($currentPSVersion -lt $requiredPSVersion) {
    Write-Output "Current PowerShell version: $currentPSVersion"
    Write-Output "Required PowerShell version: $requiredPSVersion"
    Write-Output "PowerShell 7.3 or later is required. Proceeding to check installation..."
} else {
    Write-Output "PowerShell version $currentPSVersion meets the requirement."
}

# 2. Check if PowerShell 7 is unzipped
if (Test-Path -Path $PowerShellExe) {
    Write-Output "PowerShell 7 is already unzipped at '$PowerShellExe'."
}
else {
    Write-Output "PowerShell 7 is not unzipped."
    # Verify that the zip archive exists before attempting to unzip
    if (Test-Path -Path $PowerShellZipPath) {
        Expand-PowerShellArchive -ArchivePath $PowerShellZipPath -DestinationPath $PowerShellInstallPath
        # Re-check if pwsh.exe exists after extraction
        if (Test-Path -Path $PowerShellExe) {
            Write-Output "PowerShell 7 has been successfully unzipped."
        }
        else {
            Handle-Error "Failed to unzip PowerShell 7. 'pwsh.exe' not found in '$PowerShellInstallPath'."
        }
    }
    else {
        Handle-Error "PowerShell zip archive not found at '$PowerShellZipPath'. Please ensure the archive exists."
    }
}

# 3. Check and Install Required Modules
foreach ($moduleInfo in $RequiredModules) {
    # Parse module name and version
    if ($moduleInfo -match "^(?<Name>[^,]+?)(?:,(?<Version>.+))?$") {
        $moduleName = $matches['Name']
        $moduleVersion = $matches['Version']
    }
    else {
        Handle-Error "Invalid module specification: '$moduleInfo'. Expected format 'ModuleName,Version' or 'ModuleName'."
    }

    Check-Module -ModuleName $moduleName -ModuleVersion $moduleVersion
}

# End of Script
Write-Output "Preflight checks completed successfully."
exit 0