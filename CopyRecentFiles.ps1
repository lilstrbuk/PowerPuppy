param (
    [string]$source,
    [string]$destination,
    [int]$limit
)

# Ensure the destination directory exists
if (-not (Test-Path -Path $destination)) {
    New-Item -ItemType Directory -Path $destination
}

# Get the most recent files up to the limit specified
$files = Get-ChildItem -Path $source -File | Sort-Object LastWriteTime -Descending | Select-Object -First $limit

foreach ($file in $files) {
    Copy-Item -Path $file.FullName -Destination $destination
    if ($?) {
        Write-Output "Copied $($file.Name) successfully."
    } else {
        Write-Output "Failed to copy $($file.Name)."
    }
}
