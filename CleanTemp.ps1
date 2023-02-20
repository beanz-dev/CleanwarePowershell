Clear-Host

$Proc = @(
"iexplore"
"Chrome"
"firefox"
)
foreach ($Process in $Proc){
try { Stop-Process -processname $process }catch { 
$err=$Error[0]
Write


[Windows.Clipboard]::SetText($null)
cmd /c "C:\Scripts\browsers.cmd"

#region IE, Chrome, TEMP

-Host $err}
}

$Paths = @(
"$env:LOCALAPPDATA\Microsoft\Windows\Temporary Internet Files"
"$env:LOCALAPPDATA\Microsoft\Windows\Tempor~1"
"$env:LOCALAPPDATA\Microsoft\Windows\History"
"$env:LOCALAPPDATA\Microsoft\Windows\WER"
"$env:APPDATA\Microsoft\Windows\Cookies"
"$env:LOCALAPPDATA\Google\Chrome\User Data\"
)

$cutoff = (Get-Date) - (New-TimeSpan -Days -1)

foreach ($Path in $Paths) {


try{
$acl = Get-Acl $Path
$Perm = [System.Security.AccessControl.FileSystemRights]"FullControl"
$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
$PropagationFlag = [System.Security.AccessControl.PropagationFlags]"InheritOnly"
$objType = [System.Security.AccessControl.AccessControlType]"Allow"

$permission = "Administrators",$Perm, $objType
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.SetAccessRule($accessRule)
$acl | Set-Acl $Path -ErrorAction SilentlyContinue}catch{
$err=$Error[0]
Write-Host $err
}


#Write-Host $Path
$before = (Get-ChildItem $Path | Measure-Object Length -Sum).Sum

Get-ChildItem $Path |                            
  Where-Object { $Path.Length -ne $null } |             
  Where-Object { $Path.LastWriteTime -lt $cutoff } |    
  Remove-Item -Force -Recurse -ErrorAction SilentlyContinue #-WhatIf  # REMOVE -whatif to ENABLE DELETING!
  Remove-Item $Path -Force -Recurse -ErrorAction SilentlyContinue
  New-Item $Path -Force -ItemType directory
$after = (Get-ChildItem $Path -recurse | Measure-Object Length -Sum).Sum

#'Freed {0:0.00} MB disk space' -f (($before-$after)/1MB)
}
#endregion

#region firefox
$ffPath = "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\"
$ffPath2 = "$env:APPDATA\Mozilla\Firefox\Profiles\"

$ffCacheItems = @(
"cookies.sqlite"
"content-prefs.sqlite"
"downloads.sqlite"
"formhistory.sqlite"
"search.sqlite"
"signons.sqlite"
"search.json"
"permissions.sqlite"
"Cache"
)

$Proc = @(
"FireFox*"
)
foreach ($Process in $Proc){
try { Stop-Process -processname $process }catch { 
$err=$Error[0]
Write-Host $err}
}

get-childitem $ffPath -include "Cache" -recurse | foreach ($_) {remove-item $_.fullname -recurse}

foreach ($ffCache in $ffCacheItems){get-childitem $ffPath2 -include $ffCache -recurse | foreach ($_) {remove-item $_.fullname -recurse}}

#endregion

#region Temp folders
Remove-Item -path "$env:Temp" -include "*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -path "$env:Windir\temp" -include "*" -Recurse -Force -ErrorAction SilentlyContinue
New-Item "$env:Temp"-ItemType directory -Force -ErrorAction SilentlyContinue
New-Item "$env:Windir\Temp"-ItemType directory -Force -ErrorAction SilentlyContinue
#endregion

#cmd /c "RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255"
#cmd /c "RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 4351"
#cmd /c "wmic shadowcopy delete /NOINTERACTIVE"

#cmd /c "wbadmin start backup -user:192.168.1.110\Administrator -password:Cavedoor45 -backupTarget:'\\192.168.1.110\D$\Backup\My_LT' -include:c:\Scripts -vssfull"

# PowerShell Temporary Files Deletion.  Note -force parameter
$Dir = Get-Childitem $Env:temp -recurse
$Dir | Remove-Item -force
foreach ($_ in $Dir ){$count = $count +1} 
"Number of files = " +$count