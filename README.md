![logo](https://github.com/biffalo/handy-posh/raw/main/handy-logo.png)


## Handy powershell/bat scripts for security and quality of life. Scripts are commented. General descriptions for each below:

- **chainsaw-what.ps1**

  Powershell wrapper for chainsaw from https://github.com/WithSecureLabs/chainsaw.  





- **disable-iso-mount.ps1**

  Disables native iso mounting via registry to protect against malicious ISOs.  




- **extra-logging.cmd**

  Enables extra windows logging to catch threat actors. Best paired with RMM or SIEM.  




- **get-logs.ps1**

  Copies various log files to desired folder with goal of using them for IR.  




- **office-365-have-i-been-pwned-check.ps1**

  Checks haveibeenpwned for all emails in a M365 tenancy. Outputs to terminal and csv. Required HIBP API key.  




- **server-disco.ps1**

  Gathers various information about a Windows server and outputs to a text file. Useful for trying to determine what a server does for decom or upgrades.  





- **test-port-loop.ps1**

  Uses Test-NetConnection to check if a given port is open on a host. Prompts for host and port. Uses TCP instead of ICMP. Loops until you close your posh window.  





- **ublock-chrome-installer.ps1**

  Pushes Ublock Origin using registry settings. Handy for non domain environments.  




- **windows-hardening.cmd**

  Fixes some silly defaults in Windows 10/11 to reduce chances of TA gaining foothold on an endpoint. Heavily commented.


