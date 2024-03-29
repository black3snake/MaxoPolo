
Clear-Host
[string]$path = '\\server\cports$\PC_All\'

$ErrorActionPreference = "stop"
$PathToScript=$(Split-Path -Parent $MyInvocation.MyCommand.Path)+"\"
$LogTime = Get-Date -Format "dd-MM-yyyy_hh-mm"
[string]$pc_output = $PathToScript+"$LogTime-pc_admins.csv"
[string]$file_hash = 'D:\mv\Comps\Hash.json'
[string]$file_hash_full = 'D:\mv\Comps\Hash_full.json'

if(Test-Path $path) {
    try {
        # Заберает данные полученые на текущий день года.
        [array]$BDFiles = Get-ChildItem -Path $path -File -Filter '*.txt' | Where-Object {$_.LastWriteTime.get_DayOfYear() -eq $((Get-date).get_DayOfYear())}
    } catch {
        Write-Host $($Error[0].Exception.Message) -ForegroundColor Red
    }
} else {
    Write-Host "Шара $path не доступна :("
}
# ---- Заберем из AD название организаций глубже 1 уровня после 'OU=Организации,DC=ie,DC=corp'


<#
[array]$Level2 = @()
foreach($L1 in $Level1) {
    #$twolevels.AddRange(@(Get-ADOrganizationalUnit -SearchBase $onelev -Filter * -SearchScope OneLevel -Credential $cred | select DistinguishedName ))
    $Level2 += (Get-ADOrganizationalUnit -SearchBase $onelev -Filter * -SearchScope OneLevel -Credential $cred)
}

[array]$Level3 = @()
foreach($L2 in $Level2) {
    $Level3 += (Get-ADOrganizationalUnit -SearchBase $L2 -Filter * -SearchScope OneLevel -Credential $cred)

}

foreach($L3_tmp in $Level3) {
    Write-Host $($L3_tmp.DistinguishedName)

}
Write-Host "Количество записей: " $Level3.Count

#>

# Восстановим Хэш
[hashtable]$hashF = @{}
try {
    $json = Get-Content $file_hash | Out-String
    (ConvertFrom-Json $json).psobject.properties | ForEach-Object { $hashF[$_.Name] = $_.Value }

} catch {
    Write-Host $($Error[0].Exception.Message) -ForegroundColor Red
}

# Заполним ключи Хэша (уникальными ключами)
if($hashF.count -eq 0) {
    $myarray = [System.Collections.ArrayList]::new()
    foreach($file in $BDFiles) {
        try {
            [string]$Fname0 = (Get-ADComputer -Identity $($($file.name) -replace '\..*$')).DistinguishedName
            $Fname0 = $Fname0 -replace '^CN.*?Computers,OU=|,.*$'
        } catch {
            Write-Host $($Error[0].Exception.Message) -ForegroundColor Red
            continue
        }
        try {
            $hashF.Add($Fname0,$myarray)
        }
        catch {
            $Error[0].Exception.Message | Out-Null
        }
  
    }
    # сохраним хэш в файл
    $hashF | ConvertTo-Json | Set-Content $file_hash
}


#foreach($item in $hashF.Keys) {
#}
[hashtable]$hashF2 = @{}
try {
    $json = Get-Content $file_hash_full | Out-String
    (ConvertFrom-Json $json).psobject.properties | ForEach-Object { $hashF2[$_.Name] = $_.Value }

} catch {
    Write-Host $($Error[0].Exception.Message) -ForegroundColor Red
}

if($hashF2.count -eq 0) {

    foreach($file in $BDFiles) {
        [string]$cont_file =  Get-Content -Path $file.FullName
        $cont_file = $cont_file -replace ',','7r7'
        [string]$name_pc = $($($file.name) -replace '\..*$')
        # получим в какой организации находиться pc
        try {
            [string]$Fname = (Get-ADComputer -Identity $($($file.name) -replace '\..*$')).DistinguishedName
            $Fname = $Fname -replace '^CN.*?Computers,OU=|,.*$'
        } catch {
            Write-Host $($Error[0].Exception.Message) -ForegroundColor Red
            continue
        }

        foreach($item in $hashF.Keys.Clone()) {
        
            if($item -match $Fname) {
                $hashF[$item] += $cont_file
            }
       
        }

    }
    $hashF | ConvertTo-Json | Set-Content $file_hash_full

    foreach($item2 in $hashF.Keys) {

        Add-Content -Path $pc_output -Value "$item2"
        for($i=0; $i -le $hashF[$item2].Count; $i++) {
            [string]$s_tmp = $hashF[$item2][$i] -replace '7r7',','
            Add-Content -Path $pc_output -Value "$s_tmp"
        }
    }
    exit

}


foreach($item2 in $hashF2.Keys) {

    Add-Content -Path $pc_output -Value "$item2"
    for($i=0; $i -le $hashF2[$item2].Count; $i++) {
        [string]$s_tmp = $hashF2[$item2][$i] -replace '7r7',','
        Add-Content -Path $pc_output -Value "$s_tmp"
    }
}

<#    foreach($L1 in $Level1) {
        [string]$L1_tmp = '^OU='+$Fname
        if($L1.DistinguishedName -match $L1_tmp) {       
            [array]$results += $L1.DistinguishedName
        }
    }
    # Найдем минимальную длинну записи
    $MinVal = [int]::MaxValue
    [string]$OUname_min = ''
    foreach($r in $results) {
        if($r.length -lt $MinVal) {
            $MinVal = $r.length
            $OUname_min = $r
        }
    }


#$Level3 | % {$_.DistinguishedName} | ? {$_ -match "ТЭЦ-11"}
#>