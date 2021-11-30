#
Clear-Host
$ErrorActionPreference = "stop"
$PathToScript=$(Split-Path -Parent $MyInvocation.MyCommand.Path)+"\"
$LogTime = Get-Date -Format "dd-MM-yyyy_hh-mm"
$Data30 = (Get-date).AddDays(-30)
[string]$sched_library = $PathToScript+"sched_library.ps1"
[string]$sched_output = $PathToScript+"$LogTime-sched_report.csv"
[string]$spi_str = $PathToScript+'spisok_serverov_IE.txt'
[string]$ServDCOM_str = $PathToScript+'ServDCOM.txt'
[string]$ServDCOM_nowork_str = $PathToScript+'ServDCOM_nowork.txt'
$cred = Get-Credential -Credential "IE\srv-sch"

if(Test-Path $sched_library) {
    Import-Module -Name $sched_library
} else {
    Write-Host "Нет необходимой библиотеки для работы программы"
    exit
}
# Функция проверки Servers на доступность порта 135 MS RPC DCOM
function testConnect {  
    param($ip,$port)
  
    New-Object System.Net.Sockets.TCPClient -ArgumentList $ip, $port
} # Функция проверки Servers на доступность порта 135 MS RPC DCOM


# Start Получим список серверов в нашем домене и запишим в файл
$Error.Clear()
[array]$spisokServ = @()
$timeD = New-Object -TypeName psobject

try {
	$spisokServ = Get-Content $spi_str
    $timeD = Get-ItemProperty $spi_str

    [array]$spi_tmp = @()
    if($spisokServ.count -gt 0) {
	    foreach($s in $spisokServ) {
	        $spi_tmp += $s.TrimEnd()
		
	    }
    }
    $spisokServ = $null; $spisokServ = $spi_tmp
} catch {
	Write-Host $($Error[0].Exception.Message) -ForegroundColor Red
}

# если списка нет, по получим его
if(!$spisokServ -and ($timeD.LastWriteTime -lt $Data30) ) {
	Write-Host "Получим список серверов и запишем его в файл"
    $PDC = (Get-ADDomainController -Discover -Service PrimaryDC).HostName 
	$srvs = Get-ADComputer -Server $($PDC.Value) -Filter {(enabled -eq "true") -and (OperatingSystem -like "*server*") }  -Properties * -Credential $cred
	Write-host "Количество серверов: " $srvs.Count 
	(($srvs).Name | Format-List) | Out-File $spi_str
	Start-Sleep 5 
}
# End Получим список серверов в нашем домене и запишим в файл

# Start Будем проверять доступность серверов . но сначало проверим имеющиеся файлы
[int]$count=0
[array]$ServDCOM = @()
[array]$ServDCOM_nowork = @()
$timeD1 = New-Object -TypeName psobject
$Error.Clear()
try {
	$ServDCOM = Get-Content $ServDCOM_str
    $timeD1 = Get-ItemProperty $ServDCOM_str
    $ServDCOM_nowork = Get-Content $ServDCOM_nowork_str

    [array]$spi_tmp1 = @()
    if($ServDCOM.count -gt 0) {
	    foreach($s in $ServDCOM) {
	        $spi_tmp1 += $s.TrimEnd()
		
	    }
    }
    [array]$spi_tmp2 = @()
    if($ServDCOM_nowork.count -gt 0) {
	    foreach($s in $ServDCOM_nowork) {
	        $spi_tmp2 += $s.TrimEnd()
		
	    }
    }
    $ServDCOM = $null; $ServDCOM = $spi_tmp1
    $ServDCOM_nowork = $null; $ServDCOM_nowork = $spi_tmp2

} catch {
	Write-Host $($Error[0].Exception.Message) -ForegroundColor Red
}


if(!$ServDCOM -and ($timeD1.LastWriteTime -lt $Data30) -and !$ServDCOM_nowork) {
    foreach($item in $srvs) {
        $count++
	    try {
            $testS = (testConnect -ip $item.Name -port 135).Connected
            Write-Host "Сервер $item.Name доступен MS RPC tcp/135 port " $testS
            if($testS) { 
			    $ServDCOM += $item.Name
		    }
	    } catch [System.Management.Automation.MethodInvocationException] {
            write-host "Попытка установить соединение c $($item.Name) была безуспешной, т.к. от другого компьютера за требуемое время не получен нужный отклик"
    		$ServDCOM_nowork += $item.Name
			Continue
    
	    } catch  {
            Write-Host $($Error[0].Exception.Message) -ForegroundColor Red
            $ServDCOM_nowork += $item.Name
			Continue
   	    }
	    Write-Host "Счетчик:" $count
	    #if($ServWinRM.Count -ge 2 ) { break }
    }

    ($ServDCOM | Format-List) | Out-File $ServDCOM_str
    ($ServDCOM_nowork | Format-List) | Out-File $ServDCOM_nowork_str
}
# End Будем проверять доступность серверов . но сначало проверим имеющиеся файлы


Add-Content -Path $sched_output -Value "Name; State; Enabled; Author; RunAs; Actions; URI; Description"

$SessionOption = New-CimSessionOption -Protocol DCOM

foreach($ComputerName in $ServDCOM) {
    Add-Content -Path $sched_output -Value "$ComputerName"

    # Начало
    $Error.Clear()
    try {
        $NC =  New-CimSession -ComputerName $ComputerName -SessionOption $SessionOption -Credential $cred
        
    } catch {
        Write-Host $($Error[0].Exception.Message) -ForegroundColor Red
        Add-Content -Path $sched_output -Value "Ошибка в создании CIM сессии для $ComputerName"
        continue
    }

    try {
        $REQ22 = Get-ScheduledTask -CimSession $NC
        foreach($item in $REQ22) {
	        $Name = $item.TaskName
	        $Author = $item.Author
	        $CID  = $item.Principal.userid
	        $Desc = $item.Description
	        $Action = $item.Actions.Execute
	        $Trigger = $item.Triggers.Enabled
	        $URI = $item.URI
            $State = $item.State
              

	        Add-Content -Path $sched_output -Value "$Name ; $State ; $Trigger; $Author ; $CID ; $Action ; $URI ; $Desc"
		        
        }
        Get-CimSession | Where-Object {$_.ComputerName -match $ComputerName} | Remove-CimSession

	} catch {
        Write-Host $($Error[0].Exception.Message) -ForegroundColor Red
        Add-Content -Path $sched_output -Value "Ошибка в получении задач Шедулера"
        continue
    }
		
    Write-Host "Server Name: $ComputerName" 
    
   
}