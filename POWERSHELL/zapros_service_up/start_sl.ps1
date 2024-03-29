###
# Программа проверки и запуска службы на выбранном Сервере.
# create: Pukhov Maksim Date:15.01.2021
##
Remove-Variable -Name * -Force -ErrorAction SilentlyContinue
Clear-Host

$cred = Get-Credential -Credential "IIE\ams_"
#Введем имя сервера
$server = Read-Host "Добавте имя сервера"
$server = $server.Trim()

function testConnect {
    param($ip,$port)
  
    New-Object System.Net.Sockets.TCPClient -ArgumentList $ip, $port
}
try {
    $testS = (testConnect -ip $server -port 135).Connected
    Write-Host "Сервер $server доступент ли RPC? " $testS 
} catch [System.Management.Automation.MethodInvocationException] {
    write-host "Попытка установить соединение была безуспешной, т.к. от другого компьютера за требуемое время не получен нужный отклик"
    exit
} catch [System.UnauthorizedAccessException] {
    write-host "Нет прав на сервер"
    exit
} catch [System.Management.Automation.SessionStateUnauthorizedAccessException] {
    write-host "Нет прав на сессию"
    exit
}


#Введем имя службы
$slujba = Read-Host "Введите имя службы или Enter для вывода всех служб"
$slujba = $slujba.Trim()
$ii=0

function ZaprosState {
    Param ([Parameter(Mandatory = $true,
		    HelpMessage="Credential объект разрешение",
		    ValueFromPipeLine = $false,
			Position = 0)]
            [System.Management.Automation.PSCredential]$cred,
			
			[Parameter(Mandatory = $true,
			HelpMessage="Сервер на котором находится служба",
			ValueFromPipeLine = $false,
			Position = 1)]
			[string]$serv,
			
			[Parameter(Mandatory = $true,
			HelpMessage="Сама Служба",
			ValueFromPipeLine = $false,
			Position = 2)]
			[string]$slu
    )
    try {
        $proc = Get-WmiObject -ComputerName $serv -Class win32_service -Credential $cred | Where{$_.Name -like $slu+"*"} 
        if($proc.count -gt 0) {
            return $proc[0]
        } else { return $proc }
    } catch [System.Management.Automation.SessionStateUnauthorizedAccessException] {
        write-host "Нет прав на сессию"
        exit
    } catch [System.UnauthorizedAccessException] {
        write-host "Нет прав на сервер"
        exit
    } catch [System.TimeoutException] {
        Write-Host "Время истеккло"
        exit
    } catch [System.Exception]{
        Write-host $($Error[0].Exception.Message)
    }
}

if([string]::IsNullOrWhitespace($slujba)) {
    Get-WmiObject -ComputerName $server -Class win32_service -Credential $cred | select Name,StartMode,State | ft Name,StartMode,State -AutoSize
    exit
}

$statusSlujb = ZaprosState -cred $cred -serv $server -slu $slujba
[string]$status = $statusSlujb
$status += ": "
$status += $statusSlujb.State
Write-Host "Статус службы:" $status
[string]$startMode = $statusSlujb.StartMode
Write-Host "StartMode : " $startMode

Write-Host "Напишите что делать со службой: start\stop"
$rvibor = Read-Host "Введите start или stop"
if($rvibor -eq 'stop') {
	Write-Host "Останавливаем.."
    (ZaprosState -cred $cred -serv $server -slu $slujba).StopService()
    do {
		Write-Host "Ожидание.."
		Start-Sleep 5
		[string]$status = (ZaprosState -cred $cred -serv $server -slu $slujba).State
		if($ii -eq 23) { 
            [string]$status = (ZaprosState -cred $cred -serv $server -slu $slujba).State
            Write-Host "Статус службы:" $status " Не удалось остановить"
            exit 
        }
		$ii++
	}
	while($status -eq 'Running') 
    
} elseif($rvibor -eq 'start') {
	Write-Host "Стартуем.."
    (ZaprosState -cred $cred -serv $server -slu $slujba).StartService() 
	do {
		Write-Host "Ожидание.."
		Start-Sleep 5
		[string]$status = (ZaprosState -cred $cred -serv $server -slu $slujba).State
		if($ii -eq 23) { 
            [string]$status = (ZaprosState -cred $cred -serv $server -slu $slujba).State
            Write-Host "Статус службы:" $status " Не удалось запустить"
            exit 
        }
		$ii++
	}
	while($status -eq 'Stopped') 
     
} else { 
	[string]$status = (ZaprosState -cred $cred -serv $server -slu $slujba).State
    Write-Host "Статус службы:" $status
	Write-Host "Действия не были выбраны."
    exit 
    }



[string]$status = (ZaprosState -cred $cred -serv $server -slu $slujba).State
Write-Host "Статус службы:" $status
Remove-Variable -Name * -Force -ErrorAction SilentlyContinue

