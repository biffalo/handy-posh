# Open the file containing the IP addresses
$ip_file = "ip-check.txt"
$ip_addresses = Get-Content $ip_file

# Loop through the IP addresses and get ARIN info
foreach ($ip_address in $ip_addresses) {

  # Get the ARIN info for the IP address
  $arin_info = Invoke-RestMethod -Uri "https://whois.arin.net/rest/ip/$ip_address"

  # Print the ARIN info

  Write-Host "$ip_address" -ForegroundColor Green
  Write-Host $arin_info.net.name -ForegroundColor Yellow
}