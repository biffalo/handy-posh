#disables notifications for Chrome and Edge Browsers#
New-Item "HKLM:\Software\Policies\Google\Chrome" -force -ea SilentlyContinue 
New-Item "HKLM:\Software\Policies\Microsoft\Edge" -force -ea SilentlyContinue 
New-ItemProperty -Path 'HKLM:\Software\Policies\Google\Chrome' -Name 'DefaultNotificationsSetting' -Value '2' -PropertyType DWord
New-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Edge' -Name 'DefaultNotificationsSetting' -Value '2' -PropertyType DWord