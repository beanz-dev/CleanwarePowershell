###########################################################
#
#	Script Name:  
#	Version: 1.0
#	Author: Kev
#	Date: 	05/02/2013 22:03:08
#
#	Description: 
#
###########################################################


#region---------------Start Here--------------------#
Clear-Host

$ErrorActionPreference =  "silentlycontinue"

function Write-Log ($errs){
if (!(test-path ` HKLM:\SYSTEM\CurrentControlSet\Services\Eventlog\Application\Scripts )) {new-eventlog -logname Scripts -source Appevent -ErrorAction SilentlyContinue}Write-EventLog -LogName "Scripts" -EntryType Error -Source AppEvent -ID 1000 -Message "$errs"}

$invocation = (Get-Variable MyInvocation -Scope 0).Value
$scriptPath = Split-Path $Invocation.MyCommand.Path
$file = "$scriptPath\adcred.txt"

if (!(Test-Path $file )){New-Item $file -type file -Force}
$creds = Get-Credential -Message "EnterPassword" -UserName "kittuk\Administrator"
$creds.Password | ConvertFrom-SecureString | Set-Content $File


#Read Pass file securely
$pass = cat $File | ConvertTo-SecureString
# Set user and password
$cred = New-Object System.Management.Automation.PsCredential("kittuk\Administrator", $pass)

#endregion------------End Here----------------------#

