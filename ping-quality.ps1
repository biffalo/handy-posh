# Performs ping using test-net connection to whatever IP you specify. Loops until you stop it
# If ping times out or latency is above 100ms the output will be RED
# If ping latency is below 100ms the ouput will be GREEN
# Prompt for the IP address
$ipAddress = Read-Host -Prompt "Enter the IPv4 address to ping"

# Continuous ping with color-coded output
while ($true) {
    $pingResult = Test-Connection -ComputerName $ipAddress -Count 1 -ErrorAction SilentlyContinue
    if ($pingResult) {
        $latency = $pingResult.ResponseTime
        $message = "Reply from ${ipAddress}: time=${latency} ms"
        if ($latency -gt 100) {
            Write-Host $message -ForegroundColor Red
        } else {
            Write-Host $message -ForegroundColor Green
        }
    } else {
        Write-Host "Request timed out." -ForegroundColor Red
    }
    Start-Sleep -Seconds 1
}
