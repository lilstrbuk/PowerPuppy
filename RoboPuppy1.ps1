$Source = "\\192.168.10.28\r1"
$Destination = "C:\Puppy\Testing"
$Username = "kukauser"
$Password = "68kuka1secpw59"

# Convert the password to a secure string and create a credential object
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($Username, $SecurePassword)

# Create a temporary PSDrive to access the network share
New-PSDrive -Name TempDrive -PSProvider FileSystem -Root $Source -Credential $Credential

# Perform the copy operation from the network location to the local folder
Copy-Item -Path "TempDrive:\\Program\Machine Specific\" -Destination $Destination -Recurse -Force

# Remove the temporary PSDrive
Remove-PSDrive -Name TempDrive
