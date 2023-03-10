Clear-Host

$ErrorActionPreference =  "silentlycontinue"

#region write to event log
function Write-Log ($errs){
if (!(test-path ` HKLM:\SYSTEM\CurrentControlSet\Services\Eventlog\Application\Scripts )) {new-eventlog -logname Scripts -source Appevent -ErrorAction SilentlyContinue}Write-EventLog -LogName "Scripts" -EntryType Error -Source AppEvent -ID 1000 -Message "$errs"
}
#endregion

#region clear clipboard
try{
$ClipClear = [System.Windows.Forms.Clipboard]
$ClipClear.Clear
}catch{
$err=$Error[0]
Write-Host $err
Write-Log $errs
}
#endregion

#region IE and Shadow Copy
#cmd /c "RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255"
cmd /c "RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 4351"
cmd /c "wmic shadowcopy delete /NOINTERACTIVE"
#cmd /c "wbadmin start backup -backupTarget:'E:\Backups' -include:c:\ -vssfull"
#endregion 

#region process kill
$Proc = @(
"iexplore"
"Chrome"
"firefox"
)
foreach ($Process in $Proc){
try {
$process = get-process $proc -ErrorAction:silentlycontinue | Stop-Process -Force
#$process.Kill()
}catch{ 
$err=$Error[0]
$errs = "Process not found, error is :- "+$err
Write-Host $err
Write-Log $errs
}
#cmd /c "C:\Scripts\browsers.cmd"
}
#endregion

#region IE, TEMP
$Paths = @(
"$env:LOCALAPPDATA\Microsoft\Windows\Temporary Internet Files"
"$env:LOCALAPPDATA\Microsoft\Windows\Tempor~1"
"$env:LOCALAPPDATA\Microsoft\Windows\History"
"$env:LOCALAPPDATA\Microsoft\Windows\WER"
"$env:APPDATA\Microsoft\Windows\Cookies"
)

$cutoff = (Get-Date) - (New-TimeSpan -Days -1)

foreach ($Path in $Paths) {

try{
#cmd.exe /c icacls '$Path' /T /grant Administrators:F
}catch{
$err=$Error[0]
Write-Host $err
Write-Log $errs
}


#Write-Host $Path
$before = (Get-ChildItem $Path -recurse | Measure-Object Length -Sum).Sum

Get-ChildItem $Path |                            
  Where-Object { $Path.Length -ne $null } |             
  Where-Object { $Path.LastWriteTime -lt $cutoff } |    
  Remove-Item -Force -Recurse #-WhatIf  # REMOVE -whatif to ENABLE DELETING!
  Remove-Item $Path -Force -Recurse
  New-Item $Path -Force -ItemType directory
$after = (Get-ChildItem $Path -recurse | Measure-Object Length -Sum).Sum

'Freed {0:0.00} MB disk space' -f (($before-$after)/1MB)
}
#endregion

#region Chrome

$chometemps = @(
"arch*.*" 
"cookies.*"
"curr*.*" 
"hist*.*" 
"sess*.*" 
"top*.*" 
"visit*.*" 
)

$gpath = "$env:LOCALAPPDATA\Google\Chrome\User Data\"

foreach ($chometemp in $chometemps){
get-childitem $gpath -include $chrometemp -recurse | where {$_.psIsContainer -eq $false} | foreach ($_) {remove-item $_.fullname -recurse -force}
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
try {
$process = get-process "firefox" -ErrorAction:silentlycontinue
$process.Kill()
}catch{ 
$err=$Error[0]
Write-Host $err
Write-Log $errs
}
}

get-childitem $ffPath -include "Cache" -recurse | foreach ($_) {remove-item $_.fullname -recurse}

foreach ($ffCache in $ffCacheItems){get-childitem $ffPath2 -include $ffCache -recurse | foreach ($_) {remove-item $_.fullname -recurse}}

#endregion

#region Temp folders
Remove-Item -path "$env:Temp" -include "*" -Recurse -Force
Remove-Item -path "$env:Windir\temp" -include "*" -Recurse -Force 
New-Item "$env:Temp"-ItemType directory -Force 
New-Item "$env:Windir\Temp"-ItemType directory -Force 
#endregion

#region safe to delete files
$extens = @(
"*.old"
"*.bak"
"*.log"
"*.000"
"*.001"
"*.002"
"*.~*"
"*.chk"
"*.hdmp"
"*._mp"
"*.dmp"
"*.prv"
"*.~mp"
"~*.*"
"*.??$"
"*.___"
"*.?~?"
"chklist.*"
"thumbs.db"
"chklist.ms"
"*.~"
"*.fts"
"*.gid"
"*.chk"
"*.tmp"
"*.ftg"
"*.---"
"*.err"
"*.$$$"
"log*.txt"
"*.db$"
"*.old"
"*.^"
"*.diz"
"*._detemp"
"*.log?"
"*._dd"
"*.sik"
"*.wbk"
"*.nch"
"*.pch"
"*.$db"
"*.ncb"
"*.ilk"
"*.aps"
)

foreach ($exten in $extens){try{
#$ErrorActionPreference = "SilentlyContinue"
Write-Host "Deleting $exten"
gci "$env:HOMEDRIVE\" -Include $exten -recurse -Force | Where {$_.psIsContainer -eq $false} | foreach ($_) {remove-item $_.fullname -Force}
#get-childitem c:\ -include *.tmp -recurse | foreach ($_) {remove-item $_.fullname -whatif}
#gci -Path "$env:HOMEDRIVE" -Include $exten -rec -filter $exten | Where {$_.psIsContainer -eq $false} | remove-item -recurse -force

}
catch{
$err=$Error[0]
Write-Host $err
Write-Log $errs 
}
}
#endregin