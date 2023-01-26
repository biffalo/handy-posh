#gets actions of every sch task in registry NOTE: requires winreg-tasks exe to be in same folder as script https://github.com/GDATAAdvancedAnalytics/winreg-tasks#
#tasks var gets last 38 characters of the get-child-item | select-object command which is = to full task guid including {} #
$tasks = Get-ChildItem -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Schedule\Taskcache\Tasks\" | Select-Object -ExpandProperty Name | ForEach-Object { $_.Substring($_.Length - 38)}
foreach ($task in $tasks) {
        .\winreg-tasks-amd64.exe actions "$task"
        }
