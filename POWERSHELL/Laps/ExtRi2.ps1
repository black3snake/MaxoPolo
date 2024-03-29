# 1. Получение всех OU организаций
# 2. Убрать все расширенниые права у простых пользователей
# Работа в один поток (пока многопоточность не отработана)
# create: Max Pukhov 20.12.2021

Import-Module ActiveDirectory
Clear-Host

$PathToScript=$(Split-Path -Parent $MyInvocation.MyCommand.Path)+"\"
$LogTime = Get-Date -Format "dd-MM-yyyy_hh-mm"
[string]$pc_log = $PathToScript+"$LogTime-Log_consoleEx2.txt"
[string]$pc_output = $PathToScript+"$LogTime-outALL.csv"
[string]$hash_file = $PathToScript+"hash_file.json" 
[hashtable]$hashF = @{}
#$myarray = [System.Collections.ArrayList]::new()

# Записать результаты поиска в файл csv
[bool]$file_csv = $true
# Удаляем права простых пользователей имеющих ExtRight на Pc
[bool]$remove_exri = $false


[array]$onelevels = @()
$onelevels =  Get-ADOrganizationalUnit -SearchBase 'OU=Организации,DC=iie' -Filter * -SearchScope OneLevel
[array]$twolevels = @()

foreach($onelev in $onelevels) {
    if($onelev.DistinguishedName -notmatch 'Контрагенты') {
		[array]$array_tmp = (Get-ADOrganizationalUnit -SearchBase $onelev -Filter * -SearchScope OneLevel).DistinguishedName
		$twolevels += $array_tmp
		$array_tmp = $null
	}
}
Write-Host "Количество записей: " $twolevels.Count

foreach($t in $twolevels) {
    if($t -match '(Филиалы)|(Дочерние предприятия)') {
        
        [array]$dop_mas = (Get-ADOrganizationalUnit -SearchBase $t -Filter * -SearchScope OneLevel).DistinguishedName
        Write-Host "Найден Элемент" $t
        $twolevels += $dop_mas
		$dop_mas = $null
        Write-Host
    }

}

[array]$twolevels_tmp = @($twolevels | Where-Object {$_ -notmatch '(?<=^OU=)(Филиалы)(?=,)|(?<=^OU=)(Дочерние предприятия)(?=,)'})
$twolevels = $null
$twolevels = $twolevels_tmp
Write-Host "Количество записей после обработки: " $twolevels.Count

# Получение раширенных прав пользователей (not apc) на PC
function Get-ZapExRight {
	param (
        [Parameter(Mandatory = $false,
        HelpMessage="OU организации",
        ValueFromPipeLine = $false,
        Position = 0)]
        [string]$OU = $null
	)
	[array]$ExRi_OU = @()
	try {
        $ExRi_OU = Find-AdmPwdExtendedRights -Identity $OU -IncludeComputers
    } catch {
        Write-Host $($Error[0].Exception.Message)
    }
	[array]$ExRi_OU2 = @()
	write-host "Исходная коллекция:" $($ExRi_OU.Count)
	foreach($e in $ExRi_OU){
		if(($e.ExtendedRightHolders -match 'IIE\\(?-i)[a-z]')) {
			if(($e.ExtendedRightHolders -match 'admpc')) {
		
			} else {
				$ExRi_OU2 += $e
			}
		
		}
	}
	return $ExRi_OU2
} # Получение раширенных прав пользователей (not apc) на PC

# Удаление расширенных прав в записи PC, пользователей с обычной учеткой
function Remove-ExtRights { 
    param (
        [Parameter(Mandatory = $false,
        HelpMessage="Hash OU -> extright users not apc",
        ValueFromPipeLine = $false,
        Position = 0)]
        [hashtable]$HashFT = $null
	)    
    
    foreach($itemH in $HashFT.Keys) {
        for($i=0; $i -le $HashFT[$itemH].Count-1; $i++) {
            # получим права которые есть для pc
            [string]$tmp_pc = $HashFT[$itemH][$i].ObjectDN
            $acl = Get-Acl AD:$tmp_pc
            # сузим эти права до конкретного пользователя, но его нужно еще найти
            # используем regex дабы забарть его из строчки.
            [array]$tmp_usr_array = $HashFT[$itemH][$i].ExtendedRightHolders
            foreach($ar in $tmp_usr_array) {
            	$Matches = $null
				# уберем лишние
				if($ar -notmatch 'IIE\\') {continue} else { $ar = $ar -replace '^IE\\' }
				# и начнем искать)
				$Matches = $null
				$ar -match '^((?!srv|admdc)(?-i)[a-z].+)|(Y(?-i)[a-z].+)' | Out-Null
                if($Matches.Count -gt 0) {
                    [string]$user_find = $Matches[0]
					break	
                }
            }
            $acl_user = $acl.Access | Where-Object {$_.IdentityReference -match $user_find }
            foreach($au in $acl_user) {
                $acl.RemoveAccessRule($au) | Out-Null
            }
            Write-Host $user_find
			# временно отключим -WhatIf
			try {
				Set-Acl -AclObject $acl -Path AD:$tmp_pc -WhatIf
				Write-Host
			} catch {
				write-host $($Error[0].Exception.Message) -ForegroundColor Red
				write-host "$tmp_pc -> $user_find"
				write-host
				Add-Content -Path $pc_log -Value "$tmp_pc -> $($Error[0].Exception.Message) -> $user_find"
			}
			Add-Content -Path $pc_log -Value "$tmp_pc -> $user_find; kol:$($acl_user.Count)"

			$tmp_pc =$null; $acl = $null; $tmp_usr_array = $null; $user_find = $null;
        }
        
    }

} # Удаление расширенных прав в записи PC, пользователей с обысной учеткой

[int]$count = 0

# создадим массив записей по организациям
foreach($zap in $twolevels) {
	# Заполняем массив
	[array]$Ex_all = @()
	$Ex_all = Get-ZapExRight -OU $zap
	# Создадим уникальные ключи в Хэш
	$zap_tmp = $zap -replace '^OU=|,.*$'
	try {
		$hashF.Add($zap_tmp,$Ex_all)
	} catch {
		$Error[0].Exception.Message | Out-Null
	}
    $count++
    $Ex_all = $null
    Write-Host "Оганизация $zap_tmp, N:$count"
}

if($file_csv) {
    foreach($item2 in $hashF.Keys) {
        Add-Content -Path $pc_output -Value "$item2"
        for($i=0; $i -le $hashF[$item2].Count; $i++) {
            [string]$s_tmp1 = $hashF[$item2][$i].ObjectDN
		    [string]$s_tmp2 = $hashF[$item2][$i].ExtendedRightHolders
            Add-Content -Path $pc_output -Value "$s_tmp1"
		    Add-Content -Path $pc_output -Value "$s_tmp2"
        }
    }
} else {
    Write-Host "Пропущен вывод в файл CSV"
    Write-Host
}
# Запись Хеша в файл с датой (предварительно удалим старый)
if(Test-Path $hash_file) { Remove-Item $hash_file -Force -Confirm:$false }
$hashF | ConvertTo-Json | Set-Content $hash_file

# Удаляем Расширенные права
if($remove_exri) {
    Write-Host "Удаление расширенный прав в записи PC, пользователей с обычной учеткой - Началось!"
    Remove-ExtRights -HashFT $hashF
} else {
    Write-Host
    Write-Host "Удаление расширенный прав в записи PC, пользователей с обычной учеткой - Отключено"
    Write-Host
}

