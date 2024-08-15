# Installs uBlock Origin and Ublock Lite in Chrome for all users.
# This is meant for workgroup environments because this is well documented to do with Chrome GPO things.

# Registry location for Chrome extension policies
$regLocation = 'Software\Policies\Google\Chrome\ExtensionInstallForcelist'

# Extension IDs and update URLs
$ublockID = 'cjpalhdlnbpafiamejdnhcphjbkeiagm'
$ublockURL = 'https://clients2.google.com/service/update2/crx'
$otherExtensionID = 'ddkjiahejlhfcafbddmgiahcphecmpfh'
$otherExtensionURL = 'https://clients2.google.com/service/update2/crx'

# Registry keys for the extensions
$ublockKey = '1'
$otherExtensionKey = '2'

# Registry data (Extension ID and URL)
$ublockData = "$ublockID;$ublockURL"
$otherExtensionData = "$otherExtensionID;$otherExtensionURL"

# Create the registry location if it doesn't exist and force the installation of uBlock Origin
New-Item -Path "HKLM:\$regLocation" -Force
New-ItemProperty -Path "HKLM:\$regLocation" -Name $ublockKey -Value $ublockData -PropertyType STRING -Force

# Force the installation of the second Chrome extension
New-ItemProperty -Path "HKLM:\$regLocation" -Name $otherExtensionKey -Value $otherExtensionData -PropertyType STRING -Force
