#############################################################
# Имя: Clear_session2.ps1 Create: Pukhov Maksim Date: 04.12.2020
# Язык: PoSH 5.1
# Описание: Закрытие сессий пользователя в состоянии "Disconnected" по всем серверам
# требуется обработка исклучений
#############################################################
Remove-Variable -Name * -Force -ErrorAction SilentlyContinue
cls
#Add-PSSnapin citrix*  # Имортируем модуль цитриус
if ( (Get-PSSnapin -Name citrix* -ErrorAction SilentlyContinue) -eq $null ) {Add-PsSnapin citrix*}

$si=1
$ss=1

$servers = (Get-XAWorkerGroup -WorkerGroupName "Virtual servers").ServerNames

foreach($server in $servers) {
     $serverS1 = Get-xasession -ServerName $server  
        foreach($item in $serverS1 | Get-Unique) {
             if($item.State -like "Disconnected") {
                write-host $item.ServerName":"$item.SessionId  -ForegroundColor Gray -NoNewline
                Write-Host " - Закрываем $($item.AccountName) "
                $item | stop-xasession
                $si++
            }
        }
        $ss++
}
Write-Host "Количество серверов обработанных $ss"
Write-Host "Количество закрытых сессий $si"

#При обнаружении искоючений по не доступности хоста
# отправить письмо по результатам работы.

#Remove-Variable -Name * -Force -ErrorAction SilentlyContinue