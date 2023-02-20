###########################################################
#
#	Script Name:  
#	Version: 1.0
#	Author: kmtowning
#	Date: 	06/26/2012 08:05:46
#
#	Description: 
#
###########################################################


#region---------------Start Here--------------------#
Clear-Host
#Remove-Variable * -Scope Global 
$ErrorActionPreference =  "silentlycontinue"

#region write to event log
function Write-Log ($errs){
if (!(test-path ` HKLM:\SYSTEM\CurrentControlSet\Services\Eventlog\Application\Scripts )) {new-eventlog -logname Scripts -source Appevent -ErrorAction SilentlyContinue}Write-EventLog -LogName "Scripts" -EntryType Error -Source AppEvent -ID 1000 -Message "$errs"
}
#endregion

#region Get-Hash
function Get-Hash {
param($file);[system.bitconverter]::tostring([System.Security.Cryptography.sha1]::create().computehash([system.io.file]::openread((resolve-path $file)))) -replace "-",""
}
#endregion

#region Vairables

# Set %ComputerName% Pattern
$pattern = [regex]'^(?i)((tre_|TRE_))([0-9]{13}(.zip|.ZIP))$'
$pattern2 = ($env:computername + "_" + [regex]'^(?i)((dps_tre_|DPS_TRE_))([0-9]{13}(.zip))$')

$APath = "C:\Users\KTowning\Documents\WindowsPowerShell\TestData\\"
$BPath = @("Test1\","Test2\","Test3\")
$sPath = "C:\Users\Kevin\Documents\WindowsPowerShell\TestData\Test1\"
$dPath = "C:\Users\Kevin\Documents\WindowsPowerShell\TestData\Test2\"
$items = Get-ChildItem -Path ($APath + $BPath[0]) | Where-Object {$_.Name -match $pattern}

#endregion

# enumerate the items array
foreach ($item in $items)
{Write-Host $item
      # if the item is NOT a directory or directory is not empty, then process it.
      if ($item.Attributes -ne "Directory" -and $item -ine $null)
	  {
			$nName = $env:computername + "_" + $item.Name
			Rename-Item -path $item.FullName -NewName $nName -Force
}catch{
Write-Host $errs; Write-Log $errs
}
				}
				
$items2 = Get-ChildItem -Path $sPath | Where-Object {$_.Name -match $pattern2}
foreach ($item2 in $items2)
{#Write-Host $item
      # if the item is NOT a directory or directory is not empty, then process it.
      if ($item2.Attributes -ne "Directory" -and $item2 -ine $null)
	  {
			Move-Item -Path $item2.FullName -Destination $dPath -Force
			$shaName = $item2.Name + ".sha"
			Get-Hash $dPath$item2 | Out-File $dPath$shaName; 	
}catch{
Write-Host $errs; Write-Log $errs
}
				}
#Remove-Variable * -Scope Global 

#endregion------------End Here----------------------#