:: Windows 10/11 Hardening Script v1 by Biffalo. Fork of https://gist.github.com/mackwage/08604751462126599d7e52f233490efe#
::
:: Change file associations to protect against common ransomware attacks
:: ---------------------
ftype htafile="%SystemRoot%\system32\NOTEPAD.EXE" "%1"
ftype wshfile="%SystemRoot%\system32\NOTEPAD.EXE" "%1"
ftype wsffile="%SystemRoot%\system32\NOTEPAD.EXE" "%1"
ftype jsfile="%SystemRoot%\system32\NOTEPAD.EXE" "%1"
ftype jsefile="%SystemRoot%\system32\NOTEPAD.EXE" "%1"
ftype vbefile="%SystemRoot%\system32\NOTEPAD.EXE" "%1"
::
::disable ISO mounting in windows explorer
reg add "HKEY_CLASSES_ROOT\Windows.IsoFile\shell\mount" /v "ProgrammaticAccessOnly" /t REG_SZ /d no /f
:: Enable early launch antimalware driver for scan of boot-start drivers
:: 3 is the default which allows good, unknown and 'bad but critical'. Recommend trying 1 for 'good and unknown' or 8 which is 'good only'
reg add "HKCU\SYSTEM\CurrentControlSet\Policies\EarlyLaunch" /v DriverLoadPolicy /t REG_DWORD /d 3 /f
::
::
::#######################################################################
:: Enable and Configure Internet Browser Settings
::#######################################################################
::
:: Enable SmartScreen for Edge
reg add "HKCU\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" /v EnabledV9 /t REG_DWORD /d 1 /f
:: Enable Notifications in IE when a site attempts to install software
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer" /v SafeForScripting /t REG_DWORD /d 0 /f
:: Disable Edge password manager to encourage use of proper password manager
reg add "HKCU\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" /v "FormSuggest Passwords" /t REG_SZ /d no /f
::
::#######################################################################
:: Enable and Configure General Windows Security Settings
::#######################################################################
::
:: Enable SmartScreen
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableSmartScreen /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v ShellSmartScreenLevel /t REG_SZ /d Block /f
::
::
:: Windows Update Settings
:: Prevent Delivery Optimization from downloading Updates from other computers across the internet
:: 1 will restrict to LAN only. 0 will disable the feature entirely
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config\" /v DODownloadMode /t REG_DWORD /d 1 /f
:: 
:: Removal Media Settings
:: Disable autorun/autoplay on all drives
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v NoAutoplayfornonVolume /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer" /v NoDriveTypeAutoRun /t REG_DWORD /d 255 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoAutorun /t REG_DWORD /d 1 /f
:: Harden lsass to help protect against credential dumping (mimikatz) and audit lsass access requests
:: Configures lsass.exe as a protected process and disables wdigest
:: Enables delegation of non-exported credentials which enables support for Restricted Admin Mode or Remote Credential Guard
:: ---------------------
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\LSASS.exe" /v AuditLevel /t REG_DWORD /d 00000008 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RunAsPPL /t REG_DWORD /d 00000001 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation" /v AllowProtectedCreds /t REG_DWORD /d 1 /f
::
:: Windows RPC and WinRM settings
:: Disabling RPC usage from a remote asset interacting with scheduled tasks
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Schedule" /v DisableRpcOverTcp /t REG_DWORD /d 1 /f
:: Disabling RPC usage from a remote asset interacting with services
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control" /v DisableRemoteScmEndpoints /t REG_DWORD /d 1 /f
::
:: Biometrics
:: Enable anti-spoofing for facial recognition
reg add "HKLM\SOFTWARE\Policies\Microsoft\Biometrics\FacialFeatures" /v EnhancedAntiSpoofing /t REG_DWORD /d 1 /f
:: Disable other camera use while screen is locked
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v NoLockScreenCamera /t REG_DWORD /d 1 /f
:: Prevent Windows app voice activation while locked
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v LetAppsActivateWithVoiceAboveLock /t REG_DWORD /d 2 /f
::
::#######################################################################
:: Enable and configure Windows Firewall
::#######################################################################
::
NetSh Advfirewall set allprofiles state on
::
:: Enable Firewall Logging
netsh advfirewall set currentprofile logging filename %systemroot%\system32\LogFiles\Firewall\pfirewall.log
netsh advfirewall set currentprofile logging maxfilesize 4096
netsh advfirewall set currentprofile logging droppedconnections enable
::
:: Enable Windows Defender Network Protection
powershell.exe Set-MpPreference -EnableNetworkProtection Enabled
::
:: Block Win32 binaries from making netconns when they shouldn't - specifically targeting native processes known to be abused by bad actors
:: ---------------------
Netsh.exe advfirewall firewall add rule name="Block Notepad.exe netconns" program="%systemroot%\system32\notepad.exe" protocol=tcp dir=out enable=yes action=block profile=any
Netsh.exe advfirewall firewall add rule name="Block regsvr32.exe netconns" program="%systemroot%\system32\regsvr32.exe" protocol=tcp dir=out enable=yes action=block profile=any
Netsh.exe advfirewall firewall add rule name="Block calc.exe netconns" program="%systemroot%\system32\calc.exe" protocol=tcp dir=out enable=yes action=block profile=any
Netsh.exe advfirewall firewall add rule name="Block mshta.exe netconns" program="%systemroot%\system32\mshta.exe" protocol=tcp dir=out enable=yes action=block profile=any
Netsh.exe advfirewall firewall add rule name="Block wscript.exe netconns" program="%systemroot%\system32\wscript.exe" protocol=tcp dir=out enable=yes action=block profile=any
Netsh.exe advfirewall firewall add rule name="Block cscript.exe netconns" program="%systemroot%\system32\cscript.exe" protocol=tcp dir=out enable=yes action=block profile=any
Netsh.exe advfirewall firewall add rule name="Block runscripthelper.exe netconns" program="%systemroot%\system32\runscripthelper.exe" protocol=tcp dir=out enable=yes action=block profile=any
Netsh.exe advfirewall firewall add rule name="Block hh.exe netconns" program="%systemroot%\system32\hh.exe" protocol=tcp dir=out enable=yes action=block profile=any
::
::#######################################################################
:: Windows 10 Privacy Settings
::#######################################################################
::
:: Set Windows Analytics to limited enhanced if enhanced is enabled
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v LimitEnhancedDiagnosticDataWindowsAnalytics /t REG_DWORD /d 1 /f
:: Set Windows Telemetry to security only
:: If you intend to use Enhanced for Windows Analytics then set this to "2" instead
:: Note my understanding is W10 Home edition will do a minimum of "Basic"
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v MaxTelemetryAllowed /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v ShowedToastAtLevel /t REG_DWORD /d 1 /f
:: Disable location data
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore" /v Location /t REG_SZ /d Deny /f
:: Prevent the Start Menu Search from providing internet results and using your location
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v AllowSearchToUseLocation /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v CortanaConsent /t REG_DWORD /d 0 /f
:: Disable publishing of Win10 user activity 
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v PublishUserActivities /t REG_DWORD /d 1 /f
:: Disable Win10 settings sync to cloud
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v DisableSettingSync /t REG_DWORD /d 2 /f
:: Disable the advertising ID
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v DisabledByGroupPolicy /t REG_DWORD /d 1 /f
::
:: Disable Windows GameDVR (Broadcasting and Recording)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f
:: Disable Microsoft consumer experience which prevent notifications of suggested applications to install
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SystemPaneSuggestionsEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SilentInstalledAppsEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v PreInstalledAppsEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v OemPreInstalledAppsEnabled /t REG_DWORD /d 0 /f
:: Disable websites accessing local language list
reg add "HKCU\Control Panel\International\User Profile" /v HttpAcceptLanguageOptOut /t REG_DWORD /d 1 /f
:: Prevent toast notifications from appearing on lock screen
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" /v NoToastApplicationNotificationOnLockScreen /t REG_DWORD /d 1 /f
