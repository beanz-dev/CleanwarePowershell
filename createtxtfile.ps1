$file = New-Item -ItemType file c:\scripts\diskpart.txt
$a ="Select Disk 1" | Out-File $File -append
$a ="clean" | Out-File $File -append
$a ="cre part primary" | Out-File $File -append
$a ="active" | Out-File $File -append
$a ="Assign letter=D" | Out-File $File -append
$a ="exit" | Out-File $File -append
rm C:\Scripts\diskpart.txt
