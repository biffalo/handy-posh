# Script to list local accounts without a password set

# Get all local accounts
$localAccounts = Get-LocalUser

# Filter out disabled accounts
$localAccounts = $localAccounts | Where-Object {$_.Status -eq "Enabled"}

# Filter out accounts with a password set
$localAccounts = $localAccounts | Where-Object {$_.PasswordRequired -eq $false}

# Print the list of accounts
Write-Host "Local accounts without a password set:"
$localAccounts | Select-Object Name, Enabled | Format-Table -AutoSize