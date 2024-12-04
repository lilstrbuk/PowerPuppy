# PowerShell script to copy files from Kuka controllers
param (
    [Parameter(Mandatory = $true)]
    [string]$PrimaryKRC,

    [Parameter(Mandatory = $true)]
    [string]$SecondaryKRC,

    [Parameter(Mandatory = $true)]
    [string]$KukaUser,

    [Parameter(Mandatory = $true)]
    [string]$KukaPass,

    [Parameter(Mandatory = $true)]
    [string]$SubFolder
)

# Function to handle errors
function Handle-Error {
    param (
        [string]$Message
    )
    Write-Error $Message
    exit 1
}

# Function to copy files from a controller
function Copy-Files {
    param (
        [string]$DriveName,
        [string]$SourceRoot,
        [string]$DestinationPath
    )

    try {
        # Remove existing PSDrive if it exists
        if (Get-PSDrive -Name $DriveName -ErrorAction SilentlyContinue) {
            Remove-PSDrive -Name $DriveName -Force
            Write-Output "Existing PSDrive '$DriveName' removed."
        }

        # Disconnect existing network connections to the server if any
        Write-Output "Disconnecting any existing connections to '$SourceRoot'..."
        $smbMappings = Get-SmbMapping -RemotePath $SourceRoot -ErrorAction SilentlyContinue
        if ($smbMappings) {
            $smbMappings | Remove-SmbMapping -Force -ErrorAction SilentlyContinue
            Write-Output "Disconnected existing SMB mappings to '$SourceRoot'."
        } else {
            Write-Output "No existing SMB mappings to '$SourceRoot' found."
        }

        # Establish PSDrive
        Write-Output "Establishing PSDrive '$DriveName' to '$SourceRoot'..."
        New-PSDrive -Name $DriveName -PSProvider FileSystem -Root $SourceRoot -Credential $KukaCredentials -ErrorAction Stop
        Write-Output "PSDrive '$DriveName' established successfully."

        # Copy files from the source to the destination
        Write-Output "Copying files from '$SourceRoot' to '$DestinationPath'..."
        Copy-Item -Path "$($DriveName):\*" -Destination $DestinationPath -Recurse -Force
        Write-Output "Files copied successfully from '$SourceRoot' to '$DestinationPath'."
    }
    catch {
        Handle-Error $_.Exception.Message
    }
}

# Create the new subfolders
Write-Output "Creating primary subfolder..."
$PrimaryPath = Join-Path -Path $SubFolder -ChildPath "robo\primary"
try {
    if (-not (Test-Path -Path $PrimaryPath)) {
        New-Item -ItemType Directory -Path $PrimaryPath -Force | Out-Null
        Write-Output "Subfolder created successfully: $PrimaryPath"
    } else {
        Write-Output "Primary subfolder already exists: $PrimaryPath"
    }
} catch {
    Handle-Error "Failed to create primary subfolder: $_"
}

Write-Output "Creating secondary subfolder..."
$SecondaryPath = Join-Path -Path $SubFolder -ChildPath "robo\secondary"
try {
    if (-not (Test-Path -Path $SecondaryPath)) {
        New-Item -ItemType Directory -Path $SecondaryPath -Force | Out-Null
        Write-Output "Subfolder created successfully: $SecondaryPath"
    } else {
        Write-Output "Secondary subfolder already exists: $SecondaryPath"
    }
} catch {
    Handle-Error "Failed to create secondary subfolder: $_"
}

# Set up PowerShell Credential object
Write-Output "Setting up credentials for KRCs..."
try {
    $SecurePassword = ConvertTo-SecureString $KukaPass -AsPlainText -Force
    $KukaCredentials = New-Object System.Management.Automation.PSCredential($KukaUser, $SecurePassword)
} catch {
    Handle-Error "Failed to create PSCredential object: $_"
}

# PRIMARY: Copy robo cal files from primary controller
Copy-Files -DriveName "PrimaryTempDrive" -SourceRoot $PrimaryKRC -DestinationPath $PrimaryPath

# SECONDARY: Copy robo cal files from secondary controller
Copy-Files -DriveName "SecondaryTempDrive" -SourceRoot $SecondaryKRC -DestinationPath $SecondaryPath

Write-Output "All robo operations completed."
exit 0