#
# Автоматическая очистка профилей CITRIX
# больше 200мб(если включена опция $ClearBigSize=$true) или старше 40 дней
# добавлено два места хранения профилей.
#
Remove-Variable -Name * -Force -ErrorAction SilentlyContinue
Clear-Host
# инициализация путей профиля
$destinationpath = "\\server\CTXProfiles\"
$destinationpath2 = "\\server\CTXProfiles\rdsprofiles\"
$Dir_Empty = $destinationpath +  "_empty_"
# инициализация массивов
[array]$DIRS = @()
[array]$DIRS2 = @()
[array]$DIR_PR = @()
# List для удаления больших профилей
[System.Collections.ArrayList]$ArrayList= @()
# инициализация переменных тип BOOL
[bool]$retry = $false
[bool]$ClearBigSize = $false
# инициализация переменной даты устаривания профилей
[DateTime]$DataSave = (Get-Date).Adddays(-40)

[hashtable]$hashD=@{}
[int]$countN = 0

$ErrorActionPreference = "stop"
# Путь до кода
$PathToScript=$(Split-Path -Parent $MyInvocation.MyCommand.Path)+"\"
# Функция аналога Wite-Host
Function Write-HostAndLog {
 param ($FuncWHLText, $OP)
 if([string]::IsNullOrWhitespace($OP)) {
 	Write-Host $FuncWHLText -ForegroundColor Black
 } else {
 	Write-Host $FuncWHLText -ForegroundColor "$OP"
 }
 Add-Content $PathToScript\log.txt $FuncWHLText
}
# Функция удаления директории
Function RoDel($S_Dir,$D_empty) {
    #Define arguments for robocopy ( "/L" только имитирует работу | "/E")
    $array = @("/E","/PURGE","/R:0","/W:0")
    #Create an arraylist
    $params = New-Object System.Collections.Arraylist
    $params.AddRange($array)

    #Write-Host $Dir_Empty
    #Write-Host $SourceDir
    robocopy $Dir_Empty $S_Dir $params | Out-Null
}

function RoBo($D_empty) {
    if (Test-Path $D_empty) {
        Remove-Item $D_empty -Force -Recurse
    }
    New-Item -Path $D_empty -Type "directory" | Out-Null
}

Function EndSession ($Account) {
	$Session = Get-xasession -Account $Account
	if(!$Session) { Write-Host "Сессия пользователя $Account не найдена" -ForegroundColor Red }
    else {
    	foreach ($s in $Session | Get-Unique) {
    		Write-Host $s -ForegroundColor Gray
            $s | stop-xasession; write-host "Сессия пользователя $($item.AccountName) $s отключена" -ForegroundColor Green 
        }
	}
}

Function ClearBigProfile {
Param(
        [Parameter(Mandatory=$True,
        HelpMessage="Массив объектов",
        ValueFromPipeLine = $false,
        Position = 0)]
        [array]$ArrayDRS
    )
	[System.Collections.ArrayList]$ArrayListF= @()
	foreach($item in $ArrayDRS) {
		try {
			$ArrayDRS2 = Get-ChildItem -Recurse -Force $item.FullName -ErrorAction SilentlyContinue
			$lenObj=0
			foreach($item2 in $ArrayDRS2) {
				$lenObj += $item2.length
				if([math]::Round(($lenObj/1MB),2) -gt 250) { 
					$ArrayListF.Add($($item.FullName)) 
					# извлечем имя пользователя с доменом
					$Account= $(($($item.FullName) -replace '^\\+','').Split('\')[2])
					[array]$tmp = $Account.Split('.')
					$Account = $tmp[1],$tmp[0] -join '\'
					
					# Закроем сессии пользователя если они есть
					EndSession($Account)
					
					# Удалим профиль
					Remove-Item $item.FullName -Force -Recurse -Confirm:$false
					break
			
			
				}
			}
		} catch [System.IO.PathTooLongException] {
			Write-Output "Директория содержит длинные имена папок и файлов 260+"
			[string]$Dir_Empty2 = $Dir_Empty + $($tmp[0])
			RoBo($Dir_Empty2)
			RoDel($($item.FullName),$Dir_Empty2)
    		Remove-Item $Dir_Empty -Force -Recurse -Confirm:$false
			
		} catch {
			Write-Host $($Error[0].Exception.Message)
		}
	$tmp = $null
	}
}

# Оснавная часть кода
# Заберем объеты (директории) из $destinationpath
$DIRS = Get-ChildItem -Force $destinationpath -ErrorAction SilentlyContinue -Directory -Filter '*.v2'
# Из второй переменной тоже заберем $destinationpath2
$DIRS2 = Get-ChildItem -Force $destinationpath2 -ErrorAction SilentlyContinue -Directory -Filter '*.v2'
# а тепереь объеденим массивы объектов
$DIRS += $DIRS2

# Начало  записи работы программы
Write-HostAndLog "$(Get-Date): Starting my script!"

foreach($D in $DIRS) {
	try {
		[psobject]$timeD = Get-ItemProperty $($($D.FullName)+"\Pending") -ErrorAction Stop
	} catch [System.Management.Automation.ItemNotFoundException] {
		#Write-Host "Папки нет, use parent" -ForegroundColor Red  $($($D.FullName)+"\Pending")
		Write-HostAndLog "Папки нет, use parent $($D.FullName)\Pending" "Red"
		$timeD = Get-ItemProperty $($D.FullName) -ErrorAction SilentlyContinue
	}
	if($($timeD.LastAccessTime) -lt $DataSave) {
		# извлечем имя пользователя с доменом
		#$Account= $(($($D.FullName) -replace '^\\+','').Split('\')[2])
		$Account= $($D.FullName) -replace '.+//',''
		[array]$tmp = $Account.Split('.')
		$Account = $tmp[1],$tmp[0] -join '\'
		try {
		$DIR_PR = Get-ChildItem -Recurse -Force $D.FullName -ErrorAction SilentlyContinue
		$len = 0
		foreach($D_PR in $DIR_PR) {
			$len += $D_PR.length
		}
		[double]$SizeD = [math]::Round(($len/1MB),2)
		#Write-Host $($D.FullName)": " $SizeD " Время ->" $($D.LastWriteTime)
		Write-HostAndLog "$($D.FullName):  $SizeD  Время -> $($D.LastWriteTime)"
		
		$hashD.Add($($D.FullName), $SizeD)
		$DIR_PR = $null
		Remove-Item $D.FullName -Force -Recurse -Confirm:$false
		
		} catch [System.IO.PathTooLongException] {
			Write-HostAndLog $("Директория содержит длинные имена папок и файлов 260+") "Red"
			[string]$Dir_Empty2 = $Dir_Empty + $($tmp[0])
			RoBo($Dir_Empty2)
			RoDel($($D.FullName),$Dir_Empty2)
    		Remove-Item $Dir_Empty2 -Force -Recurse -Confirm:$false
		} catch {
			Write-HostAndLog $($Error[0].Exception.Message)
		}
	$tmp = $null
	}
	$countN++
}

#Write-Host "Всего профилей: " $countN
#Write-Host "Профилей просроченных: " $($hashD.Count)
#Write-Host "Активных профилей" $($countN-$($hashD.Count))
Write-HostAndLog "Всего профилей: $countN" 
Write-HostAndLog "Профилей просроченных: $($hashD.Count)" 
Write-HostAndLog "Активных профилей $($countN-$($hashD.Count))" 

if($ClearBigSize) {
	ClearBigProfile($DIRS)
	
} else { Write-HostAndLog $("Расширенная опция ClearBigSize:"+$ClearBigSize) }

