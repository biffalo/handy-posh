$screenconnect = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -Like "Screenconnect*"}
$screenconnect.Uninstall()