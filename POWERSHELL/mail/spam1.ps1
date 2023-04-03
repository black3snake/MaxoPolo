#
# Kak mnogo spama po adresu
# Create: 26.01.2021
##
Remove-Variable -Name * -Force -ErrorAction SilentlyContinue
cls
#Add-PSSnapin Microsoft.Exchange.*  # Имортируем модуль EX
if ( (Get-PSSnapin -Name Microsoft.Exchange.* -ErrorAction SilentlyContinue) -eq $null ) {Add-PsSnapin Microsoft.Exchange.*}


$mailB = "srv-jxxx"
$seach = 'man@beluga-projects.com'
$targetFL = "RE_mail"

Get-Mailbox -Identity $mailB | Search-Mailbox -SearchQuery $seach -EstimateResultOnly

Write-Host "Нужно принять решение что дальше"
$r_y = Read-Host "Переслать себе в ящик письма что находятся в спаме? y/n"
if($r_y -eq 'y') {

    $targetMB = Read-Host "Введи свой почтовый ящик (можно только левую часть от @)"
    Write-Host "Папка в почтовом ящике куда отправляем письмо называется - " $targetFL
    
    Get-Mailbox -Identity $mailB | Search-Mailbox -SearchQuery $seach -TargetMailbox $targetMB -TargetFolder $targetFL

    


} else { exit }


