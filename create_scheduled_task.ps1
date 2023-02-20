# script to create scheduled task
$tn = "Cyclamen Central Network Discovery2" 
$args = 'D:\scom\scripts\Update-CentralNetworkDiscoveryOfSites.ps1 -LogOutputToScreen -LogOutputToFile -LogOutputToEventLog'



Function Create-MySched{
parm([string]$args, [string]$tn)
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $args
$trigger = New-ScheduledTaskTrigger  -Daily -At 3am
$executionTimeLimit = New-TimeSpan -Hours 5
$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit $executionTimeLimit -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
$taskUser = "$env:USERDOMAIN\omsched" 
$taskPassword = 'scomtest1!'
$principal = New-ScheduledTaskPrincipal -LogonType S4U -UserId $taskUser
$inputObject = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -Principal $principal
Register-ScheduledTask  -InputObject $inputObject -TaskName $tn -User $taskUser -Password $taskPassword
}
  
Create-MySched $args $tn
