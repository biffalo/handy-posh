#gets scheduled tasks in task root and prints name and action of each. if you see powershell/cmd/rundll in the action section it is likely malicious#

# Import the ScheduledTasks module
Import-Module ScheduledTasks

# Get a list of all scheduled tasks
$tasks = Get-ScheduledTask -TaskPath "*"

# Loop through each scheduled task
foreach ($task in $tasks) {
  # Output the task name and action
  Write-Output "TASKNAME: $($task.Taskname)  TASKACTIONS: $($task.Actions[0].ActionType) $($task.Actions[0].Path) $($task.Actions[0].Arguments)"
}
