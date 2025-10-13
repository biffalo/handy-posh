
# Installs uBlock Origin Lite in Chrome for all users.
# Force enable v2 extensions
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Google\Chrome" -Name "ExtensionManifestV2Availability" -PropertyType DWord -Value 2 -Force -ErrorAction SilentlyContinue

# Registry location for Chrome extension policies
$regLocation = 'Software\Policies\Google\Chrome\ExtensionInstallForcelist'

# Extension IDs and update URLs
$ublockID = 'ddkjiahejlhfcafbddmgiahcphecmpfh'
$ublockURL = 'https://clients2.google.com/service/update2/crx'

# Registry keys for the extensions
$ublockKey = '1'

# Registry data (Extension ID and URL)
$ublockData = "$ublockID;$ublockURL"

# Create the registry location if it doesn't exist and force the installation of uBlock Origin Lite
New-Item -Path "HKLM:\$regLocation" -Force
New-ItemProperty -Path "HKLM:\$regLocation" -Name $ublockKey -Value $ublockData -PropertyType STRING -Force
