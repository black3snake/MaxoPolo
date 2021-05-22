#
# Выключение ярлыков (приложений) в Citrix
#
Remove-Variable -Name * -Force -ErrorAction SilentlyContinue
Clear-Host
#Add-PSSnapin citrix*  # Имортируем модуль цитриус
if ( (Get-PSSnapin -Name citrix* -ErrorAction SilentlyContinue) -eq $null ) {Add-PsSnapin citrix*}
#

[array]$Yarls = @()
[string]$BNames = @()
# Запрос серверов в Citrix
$servers = (Get-XAWorkerGroup -WorkerGroupName "Virtual servers").ServerNames
# Запрос ярлыков приложений по шаблону 
$Yarls = (Get-XAApplication | where {($_.DisplayName -like "БК*УТБ") -and ($_.DisplayName -notlike "БК Т*")})

write-host "Далее процедура Включения или Отключения ярлыков"
write-host "1 - Отключить ярлыки приложений"
write-host "2 - Включить ярлыки приложений"
Write-Host "3 - Выход"
$a = Read-Host "Сделайте выбор"
switch($a) {
    1 { "Сделан выбор 1";
        foreach($Yarl in $Yarls) {
            if($Yarl.Enabled) {
                #Disable-XAApplication $Yarl
                Write-Host "Отключено приложение -" $Yarl.DisplayName":"$Yarl.ApplicationId
                Write-Host "Папка нахождения:" $Yarl.ClientFolder
                Write-Host "BrowserName:" $Yarl.BrowserName
                Start-Sleep 0
                Write-Host "Статус включенного приложения:" $Yarl.Enabled
                Write-Host
                $BNames += $Yarl.BrowserName
            }
        }
# Запрос и обработка сессий
    $si=1
    $ss=1
    
    foreach($server in $servers) {
     $serverS1 = Get-xasession -ServerName $server  
        foreach($item in $serverS1 | Get-Unique) {
             for($i=0; $i -le $BNames.Count-1; $i++) {
                if($item.BrowserName -like $($BNames[$i])) {
                    write-host $item.ServerName":"$item.SessionId  -ForegroundColor Gray -NoNewline
                    Write-Host " - Закрываем $($item.AccountName) "
                    #$item | stop-xasession
                    $si++
                }
             }
        }
        $ss++
}
Write-Host "Количество серверов обработанных $ss"
Write-Host "Количество закрытых сессий $si"

# -----------------
    }
    2 {"Сделан выбор 2";
        foreach($Yarl in $Yarls) {
            if(!$Yarl.Enabled) {
                #Eneble-XAApplication $Yarl
                Write-Host "Включено приложение -" $Yarl.DisplayName":"$Yarl.ApplicationId
                Write-Host "Папка нахождения:" $Yarl.ClientFolder
                Write-Host "BrowserName:" $Yarl.BrowserName
                Start-Sleep 1
                Write-Host "Статус включенного приложения:" $Yarl.Enabled
                Write-Host 
               
            }
               
        }
    }
    3 {"Как есть Выход, начинаем взлом..."; exit}
    default { "Out of range"; exit }
}

Write-Host
write-host "Всего обработтаных ярлыков приложений:" $Yarls.Count

