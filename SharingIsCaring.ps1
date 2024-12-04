# Parameters
param (
    [string]$PlantName,
    [string]$SharePointSiteURL,
    [string]$SharePointFolderPath,
    [string]$FolderToUpload
)

# The PFX must be married to AzAppID in Azure
$AzAppID = 'e4601a05-7658-4b08-b30e-e76d3f7143d2'
$PathToPFX = 'C:\Puppy\puppyCert.pfx'

# Disable updates
$env:PNPPOWERSHELL_DISABLETELEMETRY=$true
$env:PNPPOWERSHELL_UPDATECHECK=$false

# Connect to SharePoint Online
Connect-PnPOnline -ClientId $AzAppID -CertificatePath $PathToPFX -Url $SharePointSiteURL -Tenant "omnisharp.onmicrosoft.com"
#  Connect-PnPOnline -ClientId fefe3735-738e-445c-acc6-8fd9d21befe1 -CertificatePath 'C:\Users\Luke Starbuck\TestApp.pfx' -Url https://omnisharp.sharepoint.com -Tenant "omnisharp.onmicrosoft.com"

# Function to create a folder in SharePoint
function Create-SharePointFolder {
    param (
        [string]$path
    )

    $folders = $path -split '/'
    $currentPath = ""

    foreach ($folder in $folders) {
        if ($folder -ne "") {
            $currentPath = "$currentPath/$folder"
            try {
                $existingFolder = Get-PnPFolder -Url $currentPath -ErrorAction Stop
                Write-Host "Folder already exists: $currentPath"
            } catch {
                try {
                    $parentPath = $currentPath.Substring(0, $currentPath.LastIndexOf('/'))
                    if ($parentPath -eq "") {
                        $parentPath = "/"
                    }
                    Add-PnPFolder -Name $folder -Folder $parentPath
                    Write-Host "Created folder: $currentPath"
                } catch {
                    Write-Host "Error creating folder: $currentPath. $_"
                }
            }
        }
    }
}

# Construct the full SharePoint path
$fullSharePointPath = "$SharePointFolderPath/$PlantName/$((Get-Item $FolderToUpload).Name)"

# Create the full SharePoint path
Create-SharePointFolder -path $fullSharePointPath

# Function to upload files and folders recursively
function Upload-Folder {
    param (
        [string]$localFolderPath,
        [string]$sharePointFolderPath
    )

    # Upload files in the current folder
    Get-ChildItem -Path $localFolderPath -File | ForEach-Object {
        Write-Host "Uploading file: $($_.FullName) to $sharePointFolderPath"
        Add-PnPFile -Path $_.FullName -Folder $sharePointFolderPath
    }

    # Recursively upload subfolders
    Get-ChildItem -Path $localFolderPath -Directory | ForEach-Object {
        $subFolderPath = "$sharePointFolderPath/$($_.Name)"
        Create-SharePointFolder -path $subFolderPath
        Upload-Folder -localFolderPath $_.FullName -sharePointFolderPath $subFolderPath
    }
}

# Upload the folder to SharePoint
Upload-Folder -localFolderPath $FolderToUpload -sharePointFolderPath $fullSharePointPath

Write-Host "All files and folders uploaded successfully."
