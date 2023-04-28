#this script will automate a chainsaw hunt on the current system utilizing any evt/evtx files in C:\windows\system32\logs#
#get date and time stuff so we can execute chainsaw automatically without having to remember command line context#
#prompt user for number of days back to search#
Write-Host "How many days back would you like to search?" -ForegroundColor Magenta
$days = Read-Host "Enter a Number "
$from = (get-date).AddDays(-"$days").ToString("yyyy-MM-dd")
$to = Get-Date -Format "yyyy-MM-dd"
$ct = Get-Date -Format "HH:mm:ss"
#change the variable below to wherever your chainsaw folder is located#
$location = "C:\PortableApps\Chainsaw"
Set-Location -Path $location
$option1 = "--level critical"
$option2 = "--level high"
$option3 = "--level medium"
$option4 = ""

# Prompt user for Level of Sigma rules to use
Write-Host "Please select what level of Sigma rules to use:" -ForegroundColor Magenta
Write-Host "1. Critical" -ForegroundColor DarkRed
Write-Host "2. High" -ForegroundColor Red
Write-Host "3. Medium" -ForegroundColor Yellow
Write-Host "4. ALL" -ForegroundColor Green

$selection = Read-Host "Enter a number (1-4) "

# Run chainsaw based on selection
if ($selection -eq "1") {
    Write-Host "You selected $option1" -ForegroundColor Magenta
    .\chainsaw.exe hunt C:\Windows\System32\winevt\Logs -s sigma/rules/ -r rules/ --mapping .\mappings\sigma-event-logs-all.yml --level critical --from "$from T$CT" --to "$to T$CT" --csv --output results --skip-errors
}
elseif ($selection -eq "2") {
    Write-Host "You selected $option2" -ForegroundColor Magenta
    .\chainsaw.exe hunt C:\Windows\System32\winevt\Logs -s sigma/rules/ -r rules/ --mapping .\mappings\sigma-event-logs-all.yml --level high --from "$from T$CT" --to "$to T$CT" --csv --output results --skip-errors
}
elseif ($selection -eq "3") {
    Write-Host "You selected $option3" -ForegroundColor Magenta
    .\chainsaw.exe hunt C:\Windows\System32\winevt\Logs -s sigma/rules/ -r rules/ --mapping .\mappings\sigma-event-logs-all.yml --level medium --from "$from T$CT" --to "$to T$CT" --csv --output results --skip-errors
}
elseif ($selection -eq "4") {
    Write-Host "You selected ALL" -ForegroundColor Magenta
    .\chainsaw.exe hunt C:\Windows\System32\winevt\Logs -s sigma/rules/ -r rules/ --mapping .\mappings\sigma-event-logs-all.yml --from "$from T$CT" --to "$to T$CT" --csv --output results --skip-errors
}
else {
    Write-Host "Invalid selection. Please enter a number between 1 and 4."
}
