##
# Поиск записей по обработке пришедших писем  в транспортных логах
# Created: Pukhov Maxim 14.03.2021
##
Remove-Variable -Name * -Force -ErrorAction SilentlyContinue
cls
#Add-PSSnapin Microsoft.Exchange.*  # Имортируем модуль EX
if ( (Get-PSSnapin -Name Microsoft.Exchange.* -ErrorAction SilentlyContinue) -eq $null ) {Add-PsSnapin Microsoft.Exchange.*}
#
$days = 5
$count = 0
$count2 = 0
#$Recipient = 'uslugi@vorgo.ru'
$Recipient = 'adeva@bkk.ru'
#поиск по шаблону *@mail.ru
#$Recipients = '*@mail.ru'
#$Sender = '**********@digital'
#$Sender = '**@ergo.ru'

$TrackLog = @()
[System.DateTime]$DataS = '04/30/2021 00:00:00'
[System.DateTime]$DataE = '04/30/2021 23:59:59'
 
#$Servers = Get-TransportService
$GEs = Get-ExchangeServer
$Servers =  ($GEs | where {$_.isHubTransportServer -eq $true -or $_.isMailboxServer -eq $true})

do {
    $period = $DataS.AddDays($days)
    if($period -ge $DataE) { $period = $DataE }
    foreach($ser in $Servers) {
        Write-Host "Заглядываем в" $ser -NoNewline
        try {
			$count =  $TrackLog.Count
            if((![string]::IsNullorEmpty($Recipient)) -or (![string]::IsNullorEmpty($Sender)) ) {
                $TrackLog += Get-MessageTrackingLog -Server $ser -Start $DataS -End $period -Sender $Sender -Recipient $Recipient -resultsize unlimited -ErrorAction Stop
                Write-Host " - ne shablon"
			} else {
                $TrackLog += (Get-MessageTrackingLog -Server $ser -Start $DataS -End $period -resultsize unlimited -ErrorAction Stop | where {([string]$_.sender -like $Sender) -or ([string]$_.Recipients -like $Recipients)})
            }
			
            $count2 = $TrackLog.Count
			if($count2 -gt $count ) {
				$tmp_count = $count2 - $count
				Write-Host " $DataS - $period, Кол-во найденных:" $tmp_count
			} else { Write-Host " $DataS - $period, Кол-во найденных: 0"}
        } catch {
            Write-Host
            write-host $ser "Failed to connect to the Microsoft Exchange Transport Log Search service on computer" -ForegroundColor Gray
        }
		
    } $DataS = $period
}
while($period -lt $DataE )
Write-Host
Write-Host "Начинаем обработку резултатов! Найдено" $TrackLog.Count
Write-Host
[array]$TrackLog2 = $TrackLog | Sort-Object -Property @{expression={$_.Timestamp}}
foreach($Tr in $TrackLog2) {
    try {
		if(($Tr.GetType().BaseType).Name -ne "Array") {
    		write-host  $Tr.Sender "-" $Tr.Recipients "-" $Tr.MessageSubject "-" $Tr.ServerHostname "-"$Tr.Timestamp "-" $Tr.TotalBytes "-" $Tr.EventId
    	} else {
			Write-Host "Далее будет Рассылка"
			for($i=0; $i -le $Tr.Count-1; $i++) {
				Write-Host $Tr[$i].Sender "-" $Tr[$i].Recipients "-" $Tr[$i].MessageSubject "-" $Tr[$i].Timestamp
 
			}
		}
	} catch [System.Management.Automation.RuntimeException] {
		Write-Host "You cannot call a method on a null-valued expression"
		Write-Host "Записи не найдены"
		exit
	}
    Write-Host
 }
	Write-Host "Если нужно отобразить данные в таблице"
	Write-Host "1 - Таблица в консоле краткая форма"
	Write-Host "2 - Таблица в Out-GridView"
	Write-Host "3 - Таблица в Excel - no work - exit"
	$a = Read-Host "Сделайте выбор:"
	switch($a) {
		1 {"Сделан выбор 1";
			$TrackLog2
		}
		2 {"Сделан выбор 2"; 
			$TrackLog2 | Out-GridView
			exit
		}
		3 {"Сделан выбор 2";
			Write-Host "Пока еще не реализовано";
			exit
		}
	default {"Out of range"; 
             exit 
            } 
	}
	
	#$TrackLog2
