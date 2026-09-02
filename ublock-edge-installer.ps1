# Installs uBlock Origin Lite in Microsoft Edge for all users.
$regLocation = 'SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist'
$regKey = '1'
# uBlock Origin Lite Edge Add-ons ID: cimighlppcgcoapaliogpjjdehbnofhn
$regData = 'cimighlppcgcoapaliogpjjdehbnofhn;https://edge.microsoft.com/extensionwebstorebase/v1/crx'
New-Item -Path "HKLM:\$regLocation" -Force
New-ItemProperty -Path "HKLM:\$regLocation" -Name $regKey -Value $regData -PropertyType STRING -Force
