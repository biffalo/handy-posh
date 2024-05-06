#gets top 60 external senders for given 365 tenant. useful for admins and security teams#
# Connect to Exchange Online PowerShell 
Import-Module ExchangeOnlineManagement
$BiffArt = @"
       /\
      /..\       _
     /....\   _ // Top External Senders
    /......\  \X/  Powered by Biff.
"@

# Display the ASCII art
Write-Host $BiffArt -ForegroundColor Cyan
#prompt for user/domain info
$admin = Read-Host "enter 365 admin username"
$domain = Read-Host "enter 365 domain name"
Connect-ExchangeOnline -UserPrincipalName "$admin" 
#menu options
Write-Host "Please Select Report Type" -ForegroundColor Magenta
Write-Host "1. Top External Senders DELIVERED" -ForegroundColor Green
Write-Host "2. Top External Senders FILTERED/SPAM/BLOCKED" -ForegroundColor Green
$selection = Read-Host "Please select 1 or 2 based off desired report"
# Set the date range for the last 10 days
$startDate = (Get-Date).AddDays(-10)
$endDate = Get-Date
if ($selection -eq "1") {
    Write-Host "You selected Top External Senders DELIVERED" -ForegroundColor Magenta
    $topSenders = Get-MessageTrace -StartDate $startDate -EndDate $endDate | Where-Object {$_.Status -like "*Delivered*"} | Where-Object {$_.RecipientAddress -like "*$domain*"} | Where-Object {$_.SenderAddress -notlike "*$domain*"} | Group-Object -Property SenderAddress | Sort-Object -Property Count -Descending | Select-Object -First 60
}
if ($selection -eq "2") {
    Write-Host "You selected Top External Senders FILTERED/SPAM/BLOCKED" -ForegroundColor Magenta
    $topSenders = Get-MessageTrace -StartDate $startDate -EndDate $endDate | Where-Object {$_.Status -notlike "*Delivered*"} | Where-Object {$_.RecipientAddress -like "*$domain*"} | Where-Object {$_.SenderAddress -notlike "*$domain*"} | Group-Object -Property SenderAddress | Sort-Object -Property Count -Descending | Select-Object -First 60
}
#show raw output before building html report
Write-Host "Top Sender Results" -ForegroundColor Magenta
$topSenders | Select -Property Count, Name | Format-Table
# Build correct html report based on selection above
Write-Host "Building report now..." -ForegroundColor Magenta
$data = $topSenders | Select -Property Count, Name 
if ($selection -eq "1") {
$htmlTable = $data | ConvertTo-Html -Head "<style>
body {font-family: 'Arial'; background-color: #f4f4f4; color: #333;}
table {border-collapse: collapse; width: 80%; margin: 20px auto;}
th, td {border: 1px solid #ccc; padding: 8px; text-align: left;}
th {background-color: #4CAF50; color: white;}
td {background-color: #f9f9f9;}
</style>" -Title "Top External Mail Senders" -PreContent "<h1>Top DELIVERED External Mail Senders for $domain</h1>"
}
if ($selection -eq "2") {
    $htmlTable = $data | ConvertTo-Html -Head "<style>
    body {font-family: 'Arial'; background-color: #f4f4f4; color: #333;}
    table {border-collapse: collapse; width: 80%; margin: 20px auto;}
    th, td {border: 1px solid #ccc; padding: 8px; text-align: left;}
    th {background-color: #4CAF50; color: white;}
    td {background-color: #f9f9f9;}
    </style>" -Title "Top External Mail Senders" -PreContent "<h1>Top BLOCKED External Mail Senders for $domain</h1>"
    }

# Save HTML to file with name of domain
$htmlTable | Out-File -FilePath "C:\temp\top_senders-$domain.html"

#Open the HTML file automatically in the default web browser
Invoke-Item "C:\temp\top_senders-$domain.html"