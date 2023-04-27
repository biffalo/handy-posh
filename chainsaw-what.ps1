#this script will automate a chainsaw hunt on the current system utilizing any evt/evtx files in C:\windows\system32\logs#
#get date and time stuff so we can execute chainsaw automatically without having to remember command line context#
#prompt user for number of days back to search#
$days = Read-Host -Prompt 'How many days back do you want to search?'
$from = (get-date).AddDays(-"$days").ToString("yyyy-MM-dd")
$to = Get-Date -Format "yyyy-MM-dd"
$ct = Get-Date -Format "HH:mm:ss"
#set the below variable to define where all your chainsaw files and scans are
$location = "C:\PortableApps\Chainsaw"
Set-Location -Path $location
#execute chainsaw with selected options#
.\chainsaw.exe hunt C:\Windows\System32\winevt\Logs -s sigma/rules/ -r rules/ --mapping .\mappings\sigma-event-logs-all.yml --from "$from T$CT" --to "$to T$CT" --csv --output results --skip-errors 
