$teamViewer = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -Like "Teamviewer*"}
$teamViewer.Uninstall()