#uses test net connection powershell command to tcp ping a specific port. useful for troubleshooting networking/application issues#
#prompts for ip or hostname and port#
function Format-Color([hashtable] $Colors = @{}, [switch] $SimpleMatch) {
	$lines = ($input | Out-String) -replace "`r", "" -split "`n"
	foreach($line in $lines) {
		$color = ''
		foreach($pattern in $Colors.Keys){
			if(!$SimpleMatch -and $line -match $pattern) { $color = $Colors[$pattern] }
			elseif ($SimpleMatch -and $line -like $pattern) { $color = $Colors[$pattern] }
		}
		if($color) {
			Write-Host -ForegroundColor $color $line
		} else {
			Write-Host $line
		}
	}
}


$ip = Read-Host -Prompt 'enter ip address or host name'
  $port = Read-Host -Prompt 'enter tcp port'
  while ($true) {
    Test-NetConnection $ip -Port $port | Format-Color @{'False' = 'Red'; 'True' = 'Green'};
    Start-Sleep -Seconds 5
  }