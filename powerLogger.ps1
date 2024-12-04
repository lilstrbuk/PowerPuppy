# powerLogger.ps1
<#
.SYNOPSIS
    Executes the PlayingWithPower.ps1 script and logs its output with timestamps.

.DESCRIPTION
    This script performs the following actions:
    - Ensures a logs directory exists.
    - Generates a timestamped log file.
    - Executes the PlayingWithPower.ps1 script.
    - Captures and cleans the output.
    - Writes the output to the log file with timestamps.

.NOTES
    - Author: Your Name
    - Date: YYYY-MM-DD
    - Version: 1.0
#>

# Define log directory and filename
$logDir = "logs"
if (-not (Test-Path -Path $logDir)) {
    try {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
        Write-Output "Created log directory: $logDir"
    }
    catch {
        Write-Host "Error creating log directory: $_"
        exit 1
    }
}

$datetime = Get-Date -Format "MMddyy_HHmmss"
$logFile = "$logDir\${datetime}_puppy_log.txt"

# Run PlayingWithPower.ps1 and capture output
try {
    # Execute PlayingWithPower.ps1 and capture both stdout and stderr
    $output = & pwsh.exe -ExecutionPolicy Bypass -File .\PlayingWithPower.ps1 2>&1
}
catch {
    Write-Host "Error executing PlayingWithPower.ps1: $_"
    exit 1
}

# Remove ANSI escape sequences using a robust regex
$cleanOutput = $output | ForEach-Object { $_ -replace "`e\[[0-9;]*m", "" }

# Write to log with timestamps, ignoring blank lines
foreach ($line in $cleanOutput) {
    # Trim the line to remove leading and trailing whitespace
    $trimmedLine = $line.Trim()

    # Check if the trimmed line is not empty
    if ($trimmedLine -ne "") {
        $timestamp = Get-Date -Format "[ddd MM/dd/yy HH:mm:ss]"
        "$timestamp $trimmedLine" | Out-File -FilePath $logFile -Append -Encoding UTF8
    }
}

Write-Host "Log file created: $logFile"