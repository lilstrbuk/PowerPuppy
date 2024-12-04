param (
    [string]$date_format,
    [string]$PlantName,
    [string]$sub_folder
)

$errorFolders = Get-ChildItem -Path 'C:\OmniSharp\Runtime Data\BAD KNIFE SCANS' -Directory

$output = @()
$errorSummary = @()
$dailySummary = @{}
$totalCount = 0

foreach ($folder in $errorFolders) {
    $errorCode = $folder.Name
    $zipFiles = Get-ChildItem -Path $folder.FullName -Filter '*.zip'
    $zipCount = $zipFiles.Count
    $totalCount += $zipCount

    $errorSummary += [PSCustomObject]@{
        "ErrorCode" = $errorCode
        "Count"     = $zipCount
    }
    
    foreach ($zipFile in $zipFiles) {
        $creationTime = (Get-Item $zipFile.FullName).CreationTime
        $primaryOrSecondary = $zipFile.Name.Substring(0, 1)
        $creationDate = $creationTime.ToString('yyyy-MM-dd')

        if (-not $dailySummary.ContainsKey($creationDate)) {
            $dailySummary[$creationDate] = @{}
        }

        if (-not $dailySummary[$creationDate].ContainsKey($errorCode)) {
            $dailySummary[$creationDate][$errorCode] = 0
        }

        $dailySummary[$creationDate][$errorCode] += 1

        $output += [PSCustomObject]@{
            "ErrorCode"       = $errorCode
            "PriOrSec"        = if ($primaryOrSecondary -eq 'P') { 'Primary' } elseif ($primaryOrSecondary -eq 'S') { 'Secondary' } else { 'Unknown' }
            "ZipFile"         = $zipFile.Name
            "CreationTime"    = $creationTime
        }
    }
}

# Combine all data into a single JSON structure
$combinedSummary = [PSCustomObject]@{
    "Date"        = $date_format
    "PlantName"   = $PlantName
    "TotalErrors" = $totalCount
    "DailySummary" = $dailySummary
    "ErrorDetails" = $errorSummary
    "DetailedData" = $output
}

# Export combined summary to JSON
$combinedSummary | ConvertTo-Json -Depth 5 | Set-Content -Path "$sub_folder\$date_format $PlantName CombinedSummary.json"
