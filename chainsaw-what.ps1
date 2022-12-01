#this script will automate a chainsaw hunt provided you have folders containing evt and evtx files in the same folder as chainsaw or nested below it#
#get date and time stuff so we can execute chainsaw automatically without having to remember a bunch of stuff#
#chanage the -90 in below lineto whatever you'd like. this controls number of days back chainsaw will parse#
$from = (get-date).AddDays(-90).ToString("yyyy-MM-dd")
$to = Get-Date -Format "yyyy-MM-dd"
$ct = Get-Date -Format "HH:mm:ss"
#execute chainsaw in current directory. it will recursively scan any evt or evtx logs in root or below#
.\chainsaw.exe hunt . -s sigma/rules/ --mapping .\mappings\sigma-event-logs-all.yml -r rules/ --level high --from "$from T$CT" --to "$to T$CT" --csv --output results
#chainsaw csv is ugly so we'll do some dirty css/html/powershell magic to give us a more visually pleasing report#
$css = @"
<style>
h1, h5, th { text-align: center; font-family: Segoe UI; }
table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }
th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }
td { font-size: 11px; padding: 5px 20px; color: #000; }
tr { background: #b8d1f3; }
tr:nth-child(even) { background: #dae5f4; }
tr:nth-child(odd) { background: #b8d1f3; }
</style>
"@
#change lines below wherever your source csv and destination html should be#
$csv = E:\logdump\results\sigma.csv
$html = E:\logdump\results\sigma.html
Import-CSV "$csv" | ConvertTo-Html -Head $css -Body "<h1>Chainsaw Report</h1>`n<h5>Generated on $(Get-Date)</h5>" | Out-File "$html"
