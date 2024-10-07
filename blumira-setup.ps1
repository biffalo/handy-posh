# Automates setup of Blumira 365 Cloud Connector from https://www.blumira.com/support#support-Integrating+with+Microsoft+365

$BiffArt = @"
..........................................
...................@......................
...................@@@....................
................@....@....................
..............@@.@@..@@@..................
...........@@...@@...@@...................
..........@@@@@....@@@...@@@..............
............@@...@@@......@.@@............
................@@@..@@@..................
................@@...@@@@@................
.................@@....@..................
....................@.....................
..........................................
.Blumira.Azure/365.Connector.Setup.Script.
..........................................
..powered.by...BIFF.......................
"@
Write-Host "$BiffArt" -ForegroundColor DarkCyan
# Prompt user for tenant ID
$TenantId = Read-Host "Enter Azure TenantID of Customer"

# Connect to Microsoft Graph with necessary scopes
Connect-MgGraph -TenantId $TenantId -Scopes 'Application.ReadWrite.All','Directory.ReadWrite.All' -NoWelcome

# Define the application name
$appName = "Microsoft 365 Audit Logs to Blumira"

# Create a new application
$application = New-MgApplication -DisplayName $appName

# Retrieve Client ID and Tenant ID
$clientId = $application.AppId
$tenantId = (Get-MgContext).TenantId

# Get the service principal for Office 365 Management API
$officeMgmtApiAppId = 'c5393580-f805-4401-95e8-94b7a6ef2fc2' # Office 365 Management APIs
$officeMgmtApi = Get-MgServicePrincipal -Filter "AppId eq '$officeMgmtApiAppId'"

# Get the service principal for Microsoft Graph
$graphApiAppId = '00000003-0000-0000-c000-000000000000' # Microsoft Graph
$graphApi = Get-MgServicePrincipal -Filter "AppId eq '$graphApiAppId'"

# Office 365 Management API Application Permissions
$officeMgmtApiAppRoles = $officeMgmtApi.AppRoles

$activityFeedReadRole = $officeMgmtApiAppRoles | Where-Object { $_.Value -eq "ActivityFeed.Read" -and $_.AllowedMemberTypes -contains "Application" }
$activityFeedReadDlpRole = $officeMgmtApiAppRoles | Where-Object { $_.Value -eq "ActivityFeed.ReadDlp" -and $_.AllowedMemberTypes -contains "Application" }
$serviceHealthReadRole = $officeMgmtApiAppRoles | Where-Object { $_.Value -eq "ServiceHealth.Read" -and $_.AllowedMemberTypes -contains "Application" }

# Office 365 Management API Delegated Permissions
$officeMgmtApiOauth2Scopes = $officeMgmtApi.Oauth2PermissionScopes

$activityFeedReadScope = $officeMgmtApiOauth2Scopes | Where-Object { $_.Value -eq "ActivityFeed.Read" }
$activityFeedReadDlpScope = $officeMgmtApiOauth2Scopes | Where-Object { $_.Value -eq "ActivityFeed.ReadDlp" }
$serviceHealthReadScope = $officeMgmtApiOauth2Scopes | Where-Object { $_.Value -eq "ServiceHealth.Read" }

# Microsoft Graph Application Permissions
$graphApiAppRoles = $graphApi.AppRoles

$userReadAllRole = $graphApiAppRoles | Where-Object { $_.Value -eq "User.Read.All" -and $_.AllowedMemberTypes -contains "Application" }

# Define required resource access
$requiredResourceAccess = @()

# Office 365 Management API
$officeMgmtApiAccess = [Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess]@{
    ResourceAppId = $officeMgmtApiAppId
    ResourceAccess = @(
        [Microsoft.Graph.PowerShell.Models.MicrosoftGraphResourceAccess]@{
            Id   = $activityFeedReadRole.Id
            Type = "Role"
        },
        [Microsoft.Graph.PowerShell.Models.MicrosoftGraphResourceAccess]@{
            Id   = $activityFeedReadDlpRole.Id
            Type = "Role"
        },
        [Microsoft.Graph.PowerShell.Models.MicrosoftGraphResourceAccess]@{
            Id   = $serviceHealthReadRole.Id
            Type = "Role"
        },
        [Microsoft.Graph.PowerShell.Models.MicrosoftGraphResourceAccess]@{
            Id   = $activityFeedReadScope.Id
            Type = "Scope"
        },
        [Microsoft.Graph.PowerShell.Models.MicrosoftGraphResourceAccess]@{
            Id   = $activityFeedReadDlpScope.Id
            Type = "Scope"
        },
        [Microsoft.Graph.PowerShell.Models.MicrosoftGraphResourceAccess]@{
            Id   = $serviceHealthReadScope.Id
            Type = "Scope"
        }
    )
}
$requiredResourceAccess += $officeMgmtApiAccess

# Microsoft Graph API
$graphApiAccess = [Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess]@{
    ResourceAppId = $graphApiAppId
    ResourceAccess = @(
        [Microsoft.Graph.PowerShell.Models.MicrosoftGraphResourceAccess]@{
            Id   = $userReadAllRole.Id
            Type = "Role"
        }
    )
}
$requiredResourceAccess += $graphApiAccess

# Update the application with the required permissions
Update-MgApplication -ApplicationId $application.Id -RequiredResourceAccess $requiredResourceAccess

# Create a new client secret
$clientSecretDescription = "Blumira sensor"
$clientSecretStartDate = Get-Date
$clientSecretEndDate = $clientSecretStartDate.AddMonths(24) # Expires in 24 months

# Prepare the password credential
$passwordCredential = @{
    DisplayName   = $clientSecretDescription
    StartDateTime = $clientSecretStartDate.ToUniversalTime()
    EndDateTime   = $clientSecretEndDate.ToUniversalTime()
}

# Add the password credential to the application
$clientSecret = Add-MgApplicationPassword -ApplicationId $application.Id -PasswordCredential $passwordCredential

# Output the Client ID, Tenant ID, and Client Secret Value
Write-Host "Application (client) ID: $clientId" -BackgroundColor DarkBlue -ForegroundColor White
Write-Host "Directory (tenant) ID: $tenantId" -BackgroundColor DarkBlue -ForegroundColor White
Write-Host "Client Secret Value: $($clientSecret.SecretText)" -BackgroundColor DarkBlue -ForegroundColor White

Write-Host "`nPlease grant admin consent for the application permissions in the Azure Portal." -BackgroundColor DarkGreen -ForegroundColor White

# Instructions to grant admin consent
Write-Host "To grant admin consent:" -BackgroundColor DarkGreen -ForegroundColor White
Write-Host "1. Go to the Azure Active Directory admin center." -BackgroundColor DarkGreen -ForegroundColor White
Write-Host "2. Navigate to 'App registrations' and select the application named '$appName'." -BackgroundColor DarkGreen -ForegroundColor White
Write-Host "3. Click on 'API permissions' from the left-hand menu." -BackgroundColor DarkGreen -ForegroundColor White
Write-Host "4. Click on the 'Grant admin consent' button." -BackgroundColor DarkGreen -ForegroundColor White
