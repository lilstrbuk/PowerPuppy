# Set the configuration file path
$configFile = "C:\Puppy\doggo.yaml"

# Check if the configuration file already exists
if (Test-Path $configFile) {
    Write-Output "Configuration file already exists."
    exit 0
}

# Create the YAML content
$yamlContent = @"
---
PlantName: 'This is my plant'
BigDay:
  - 'Tue'
  - 'Thu'
SharePointSiteURL: 'https://omnisharp.sharepoint.com/'
SharePointFolderPath: 'KSM Backups'
PrimaryKRC: '\\192.168.10.18\r1\Program'
SecondaryKRC: '\\192.168.10.28\r1\Program'
KukaUser: 'kukauser'
KukaPass: '68kuka1secpw59'
OmnisharpPath: 'C:\OmniSharp'
FilesToCopy:
  - 'Runtime Data\LOGS\knife_counts.olog'
  - 'Runtime Data\knivesperhour.csv'
  - 'Grind_Everything.txt'
  - 'users.ouf'
"@

# Write the YAML content to the file
$yamlContent | Out-File -FilePath $configFile -Encoding utf8