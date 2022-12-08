#installs ublock origin in chrome for all users. this is meant for workgroup environments because this is well documented to do with chrome gpo things#
$regLocation = 'Software\Policies\Google\Chrome\ExtensionInstallForcelist'
$regKey = '1'
# 'cjpalhdlnbpafiamejdnhcphjbkeiagm' is the Extension ID for ublock origin, easiest way to get this is from the URL of the extension
$regData = 'cjpalhdlnbpafiamejdnhcphjbkeiagm;https://clients2.google.com/service/update2/crx'
New-Item -Path "HKLM:\$regLocation" -Force
New-ItemProperty -Path "HKLM:\$regLocation" -Name $regKey -Value $regData -PropertyType STRING -Force