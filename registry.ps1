Set-Location -Path HKLM:\SOFTWARE\Kittuk\Test
$acl = Get-Acl 
($acl.Access).IdentityReference.Value


$acl = Get-Acl HKLM:\SOFTWARE\Kittuk\Test

$key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SOFTWARE\Kittuk\Test",[Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,[System.Security.AccessControl.RegistryRights]::ChangePermissions)
$acl = $key.GetAccessControl()
$acl.Access | %{$acl.RemoveAccessRule($_)} 


# Disable inheritance for this key (true), remove inherited access rules (false): 
$acl.SetAccessRuleProtection($true, $false) 
#$acl.SetAccessRuleProtection($false, $true) 

# Remove all permissions for "NT AUTHORITY\SYSTEM": 
$rule = New-Object System.Security.AccessControl.RegistryAccessRule ("Administrators","FullControl","Allow")
$acl.SetAccessRule($rule)
$rule = New-Object System.Security.AccessControl.RegistryAccessRule ("BUILTIN\Users","ReadKey","Allow")
$acl.SetAccessRule($rule)
$rule = New-Object System.Security.AccessControl.RegistryAccessRule ("NT AUTHORITY\SYSTEM","FullControl","Deny")
$acl.SetAccessRule($rule)

$key.SetAccessControl($acl)

#$acl.Access | where {$_.IdentityReference.Value -like "NT AUTHORITY\SYSTEM"} | %{$acl.RemoveAccessRule($_)} 
#Set-Acl HKLM:\SOFTWARE\Kittuk\Test $acl 

$acl = Get-Acl 
$acl.Access