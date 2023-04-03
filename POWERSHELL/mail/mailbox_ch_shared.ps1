#
# Перевод ящика в общие
#
Remove-Variable -Name * -Force -ErrorAction SilentlyContinue
cls
#Add-PSSnapin Microsoft.Exchange.*  # Имортируем модуль EX
if ( (Get-PSSnapin -Name Microsoft.Exchange.* -ErrorAction SilentlyContinue) -eq $null ) {Add-PsSnapin Microsoft.Exchange.*}


Get-Mailbox office_ru@xxx.ru | Set-Mailbox -Type Shared