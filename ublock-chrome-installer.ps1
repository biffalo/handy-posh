# Installs uBlock Origin in Chrome for all users. Also forces enable v2 manifest to give another year of ublock origin before we switch to lite
# This is meant for workgroup environments because this is well documented to do with Chrome GPO things.
# Force enable v2 extensions
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Google\Chrome" -Name "ExtensionManifestV2Availability" -PropertyType DWord -Value 2 -Force -ErrorAction SilentlyContinue

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


# Create the registry location if it doesn't exist and force the installation of uBlock Origin
New-Item -Path "HKLM:\$regLocation" -Force
New-ItemProperty -Path "HKLM:\$regLocation" -Name $ublockKey -Value $ublockData -PropertyType STRING -Force

# Remove Ublock Lite
Remove-ItemProperty -Path "HKLM:\$regLocation" -Name $otherExtensionKey -Force -ErrorAction SilentlyContinue

