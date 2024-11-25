# 365 Login History v1 by Biff. 
# Requires Microsoft Graph Powershell
# Prompts for tenant id and user name to give you useful output of logins from that user from the last 30 days

# Import the Microsoft Graph PowerShell module
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Reports
Import-Module Microsoft.Graph.Identity.SignIns

# Prompt for Tenant ID
$TenantId = Read-Host -Prompt "Enter Tenant ID"

# Prompt for User Principal Name (UPN)
$UserUPN = Read-Host -Prompt "Enter the User Principal Name (UPN) of the user"

# Authenticate to the Microsoft Graph API
Connect-MgGraph -TenantId $TenantId -Scopes "AuditLog.Read.All" -NoWelcome

# Define the start date for the query
$date30DaysAgo = (Get-Date).AddDays(-30).ToString("yyyy-MM-ddTHH:mm:ssZ")

# Construct the filter for the query, including only successful sign-ins
$Filter = "userPrincipalName eq '$UserUPN' and createdDateTime ge $date30DaysAgo and status/errorCode eq 0"

# Query sign-in logs for the given user
Write-Host "Sign-ins Last 30 days for $UserUPN. This may take up to 60 seconds..." -ForegroundColor White -BackgroundColor DarkGreen

# Retrieve the sign-in logs
$SignIns = Get-MgAuditLogSignIn -Filter $Filter | Select-Object UserPrincipalName, CreatedDateTime, IPAddress

# Output header with formatting
$header = "{0,-30} {1,-25} {2,-15}" -f "UserPrincipalName", "CreatedDateTime", "IPAddress"
Write-Host $header -BackgroundColor DarkBlue -ForegroundColor White

# Initialize row counter and define alternating colors
$rowCounter = 0
$colors = @("DarkGray", "Black")

# Loop through each sign-in record and output with alternating colors
foreach ($signIn in $SignIns) {
    $color = $colors[$rowCounter % $colors.Length]
    $line = "{0,-30} {1,-25} {2,-15}" -f $signIn.UserPrincipalName, $signIn.CreatedDateTime, $signIn.IPAddress
    Write-Host $line -ForegroundColor White -BackgroundColor $color
    $rowCounter++
}
