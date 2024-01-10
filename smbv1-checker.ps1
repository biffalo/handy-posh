Set-SmbServerConfiguration -AuditSmb1Access $true -Confirm:$false
Start-Sleep -Seconds 900
Get-WinEvent -LogName Microsoft-Windows-SMBServer/Audit -FilterXPath "*[System[TimeCreated[timediff(@SystemTime) <= 1209600000]]]" | Where-Object { $_.Id -eq 3000 -or $_.Id -eq 3001 -or $_.Id -eq 3002 } | Select-Object TimeCreated, Id, Message | Format-Table -Wrap
