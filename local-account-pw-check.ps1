Get-LocalUser | Where-Object {$_.PasswordRequired -eq $false} | Where-Object {$_.Enabled -eq "True"} > C:\ktemp\localaccount-nopw.txt
