![logo](https://github.com/biffalo/handy-posh/raw/main/handy-logo.png)


## Handy powershell/bat scripts for security and quality of life. Scripts are commented. General descriptions for each below:



### **AIO-IR.ps1**

>  Comprehensive Incident Response Script that gathers common forensic info from a windows system for later analysis. 


### **chainsaw-what.ps1**

>  Powershell wrapper for chainsaw from https://github.com/WithSecureLabs/chainsaw.  





### **disable-iso-mount.ps1**

>  Disables native iso mounting via registry to protect against malicious ISOs.  




###  **extra-logging.cmd**

>  Enables extra windows logging to catch threat actors. Best paired with RMM or SIEM.  



###  **fsrm-backup-protect.ps1**

>  Creates FSRM (file server resource manager) file screen/group that only allows specificed file extensions to be written to a given share. Writes eventlog entry if it is violated.


### **get-logs.ps1**

>  Copies various log files to desired folder with goal of using them for IR.  


### **get-tasks.ps1**

>  Gets scheduled task names and actions from task sch root / and displays them. If action contains powershell/cmd/rundll it is likely malicious. 


### **malicious-lnk-finder.ps1**

>  Searches C:\Users recursivley to find any LNK files pointing to cmd.exe, rundll.exe, or powershell.exe
  
  
  
### **nmap-audit.ps1**
  
>   Installs NMAP via choco, runs scan on desired host/IP. Outputs results to styled XML and opens in edge.




### **office-365-have-i-been-pwned-check.ps1**

>  Checks haveibeenpwned for all emails in a M365 tenancy. Outputs to terminal and csv. Required HIBP API key.  




### **server-disco.ps1**

>  Gathers various information about a Windows server and outputs to a text file. Useful for trying to determine what a server does for decom or upgrades.  





### **test-port-loop.ps1**

>  Uses Test-NetConnection to check if a given port is open on a host. Prompts for host and port. Uses TCP instead of ICMP. Loops until you close your posh window.  





### **ublock-chrome-installer.ps1**

>  Pushes Ublock Origin using registry settings. Handy for non domain environments.  



### **web-nav-killer.ps1**

>  Removes WebNavigator/Blaze browser adware/pup binaries and tasks.


### **windows-hardening.cmd**

>  Fixes some silly defaults in Windows 10/11 and sets additional settings to reduce chances of TA gaining foothold on an endpoint. Heavily commented. Goal here is to be effective with least breakage.


