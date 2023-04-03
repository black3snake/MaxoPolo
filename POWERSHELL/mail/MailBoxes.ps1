#
# Нахождение выключенных УЗ имеющих почту
#
Remove-Variable -Name * -Force -ErrorAction SilentlyContinue
Clear-Host

#Add-PSSnapin Microsoft.Exchange.*  # Имортируем модуль EX
if ( (Get-PSSnapin -Name Microsoft.Exchange.* -ErrorAction SilentlyContinue) -eq $null ) {Add-PsSnapin Microsoft.Exchange.*}
#
$SB = "OU=Организации,DC=iie"
$100_Days = (Get-Date).adddays(-100)
#Найдем почтовые базы данных
[array]$MailBoxDatabases=@()
[array]$tmpB=@()

$MailBoxDatabases = Get-MailboxDatabase
foreach($item in $MailBoxDatabases) {
    if($item -like "IRK-*") { $tmpB += $item; Write-Host $item }
}
$MailBoxDatabases=$null;$MailBoxDatabases=$tmpB


[array]$DUsers = Get-ADUser -SearchBase $SB -Filter {(Enabled -eq "False") -and (mail -ne "null") -and (LastLogonDate -le $100_days)} -Properties Surname,GivenName,mail,LastLogonDate,SamAccountName | select Name,mail,LastLogonDate,SamAccountName
Write-Host "Количество записей" $DUsers.Count

#$DUsers
$Error.Clear();
[array]$tmpMailBoxes=$null
[array]$tmp=@()

foreach($MBDatabase in $MailBoxDatabases) {
    $tmpMailBoxes = Get-Mailbox -Database $MBDatabase -IgnoreDefaultScope | Where {$_.RecipientType -eq "UserMailbox" -And $_.RecipientTypeDetails -eq "UserMailbox" -and $_.Alias -notlike "*DiscoverySearchMailbox*" -and $_.Alias -ne "Administrator"} 
    if ($ERROR)  # Get-Mailbox -Database
	    {Write-host "ERROR 40: Ошибка получения массива почтовых ящиков из базы данных : $MBDatabase "
    } else {# Get-Mailbox -Database    
        if ($tmpMailBoxes) {
			foreach ($mailbox in $tmpMailBoxes) {
               $tmp+=$mailbox 
            }
        } else {
            Write-host "WARNING 04: Не найдены почтовые ящики в базе данных : $MBDatabase "
        }
    }
}
$MailBoxes=$null;$MailBoxes=$tmp

write-host "Всего почтовых ящиков в базах:" $MailBoxes.Count

[array]$spisok = @()
for($i=0; $i -le $MailBoxes.Count-1; $i++) {
    foreach($DUser in $DUsers.SamAccountName){
        if($MailBoxes[$i].SamAccountName -eq $DUser) {
            $spisok += $DUser
            
        }
    }

}
Write-Host "Количество конечных УЗ:" $spisok.Count

$spisok | Out-File "C:\Users\mv\Documents\1.txt"


#foreach($DUser in $DUsers.SamAccountName){
#-Identity $DUser -ErrorAction SilentlyContinue | Where {$_.RecipientType -eq "UserMailbox" -And $_.RecipientTypeDetails -eq "UserMailbox"} 
