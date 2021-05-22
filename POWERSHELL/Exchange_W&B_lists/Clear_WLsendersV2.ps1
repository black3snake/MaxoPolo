##
## проверка адресов по домену на присутсвие в списке WhiteList и удаление его необходимого (Чистка WL)
# Create: Pukhov Maksim Date: 04.04.2021
###
Remove-Variable -Name * -Force -ErrorAction SilentlyContinue
Clear-Host

#Add-PSSnapin Microsoft.Exchange.*  # Имортируем модуль EX
if ( (Get-PSSnapin -Name Microsoft.Exchange.* -ErrorAction SilentlyContinue) -eq $null ) {Add-PsSnapin Microsoft.Exchange.*}

function IsValidEmail { 
    param([string]$Email)
		$Regex = '^[A-Za-z0-9 ?._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$'
   try {
        $obj = [mailaddress]$Email
        if($obj.Address -match $Regex){
            return $True
        }
        return $False
    }
    catch {
        return $False
    } 
}

write-host "Введите домен адреса почтового ящика который нужно проверить "
$wla = read-host "на присутвие в WhiteList "

(Get-ContentFilterConfig).BypassedSenders | Where-Object {$_.Address -like "*@$wla*" } | ft Address, Domain, Local -AutoSize

[array]$ArAddrs = (Get-ContentFilterConfig).BypassedSenders | Where-Object {$_.Address -like "*@$wla*" }

if(!$ArAddrs.Length -gt 0) { Write-Host "Нет Записей в WhiteList"; exit }

Write-Host "Если нужно удалить все адреса этого домена"
Write-Host "1 - Если нужно удалить все адреса этого домена"
Write-Host "2 - удалить только конкретный ящик"
Write-Host "3 - Оставить как есть и попутно взломать сервер ЦРУ:)"
            
            $a = Read-Host "Сделайте выбор:"
            switch ($a) {
                1 {"Сделан выбор 1"; 
                        foreach($Ar in $ArAddrs) {
                            Set-ContentFilterConfig -BypassedSenders @{Remove=$Ar.Address}
                            
                            write-host "Удален адрес:" $Ar.Address            
                        }
                  }
             
                2 {"Сделан выбор 2"; 
                     $del_adr = Read-Host "адрес Email"
                     if(IsValidEmail $del_adr) {
                        Write-Host "Валидный адрес"
                     } else {
                        Write-Host "Невалидный адрес"
                        exit
                     } 
                     Set-ContentFilterConfig -BypassedSenders @{Remove=$del_adr}
                     Write-Host "Удален адрес из WL - $del_adr"
                   }
                
                3 {"Как есть Выход, начинаем взлом..."; exit }
                
                default {
                    "Out of range"; 
                    exit 
                } 
               }


