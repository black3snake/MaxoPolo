#############################################################
# Имя: Citrix_user_on_servers.ps1 Create: Pukhov Maksim Date: 03.02.2021
# Язык: PoSH 5.1
# Описание: Запрос на количество пользователей работающих на каждом сервере 
# из группы Virtual Servers
#############################################################
Remove-Variable -Name * -Force -ErrorAction SilentlyContinue
Clear-Host
#Add-PSSnapin citrix*  # Имортируем модуль цитриус
if ( (Get-PSSnapin -Name citrix* -ErrorAction SilentlyContinue) -eq $null ) {Add-PsSnapin citrix*}

$si=0
$ss=1
$servXX = New-Object System.Collections.Arraylist

$servers = (Get-XAWorkerGroup -WorkerGroupName "Virtual servers").ServerNames
Write-Host "Вывод статистики Имя сервера:Кол. пользователей:Кол. открытых сессий: Disconn"

foreach($server in $servers) {
    $sC=0
    $sessionS = Get-xasession -ServerName $server
    foreach($sesServ in $sessionS) {
        if($sesServ.State -like "Disconnected") {
            $sC++
        }
    }
    $countS = $sessionS.Count
    $serverS = $sessionS.AccountName | Get-Unique
    $count = $serverS.Count
     
    
    $servX = @{NameServ=$server; OSession=$countS; DSession=$sC; Users=$count}
    $obj = New-Object -TypeName PSObject -Property $servX
    $servXX.Add($obj) |Out-Null
    

    $si += $count
    $ss += 1
}

Invoke-Command -scriptblock { $servXX | Sort-Object -Descending -Property @{expression={$_.OSession}}}

Write-Host "Количество серверов обработанных $ss"
Write-Host "Количество пользователей на серверах Citrix $si"


#Remove-Variable -Name * -Force -ErrorAction SilentlyContinue