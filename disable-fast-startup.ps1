# Disable Fast Startup
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
$regName = "HiberbootEnabled"
$regValue = 0

try {
    Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -ErrorAction Stop
    Write-Host "Fast Startup has been disabled successfully."
}
catch {
    Write-Host "An error occurred while disabling Fast Startup: $_"
}
