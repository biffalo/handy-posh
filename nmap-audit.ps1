Write-Host "installing chocolatey if you don't have it already" -ForegroundColor Red -BackgroundColor White
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Write-Host "installing nmap and git on your local machine and setting path" -ForegroundColor Red -BackgroundColor White
choco install nmap -y
choco install git -y
# Make `refreshenv` available right away, by defining the $env:ChocolateyInstall variable
# and importing the Chocolatey profile module.
$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).path)\..\.."
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
# refreshenv is now an alias for Update-SessionEnvironment
# (rather than invoking refreshenv.cmd, the *batch file* for use with cmd.exe)
# This should make git.exe accessible via the refreshed $env:PATH, so that it can be 
# called by name only.
refreshenv
New-Item -Path "c:\" -Name "nmap-scans" -ItemType "directory" -ErrorAction SilentlyContinue
git clone https://github.com/vulnersCom/nmap-vulners.git C:\nmap-scans\
Write-Host "creating C:\nmap-scans\ this is where your nmap scan will end up" -ForegroundColor Red -BackgroundColor White
$clientname = Read-Host "Enter Client Name *no spaces*"
$clientip = Read-Host "Enter Client Ip"
nmap --script C:\nmap-scans\vulners.nse -sV -F -oA "C:\nmap-scans\$clientname-results" --stylesheet https://raw.githubusercontent.com/biffalo/handy-posh/main/nmap-bootstrap-infin.xsl -T4 -A -v -Pn $clientip
#nmap -oX "C:\nmap-scans\$clientname-results.xml" --stylesheet "https://raw.githubusercontent.com/honze-net/nmap-bootstrap-xsl/master/nmap-bootstrap.xsl"  -T4 -A -v -Pn $clientip#
[system.Diagnostics.Process]::Start("firefox","C:\nmap-scans\$clientname-results.xml")
