##
## проверка адреса на присутсвие в списке WhiteList и добавление в WL
# Create: Pukhov Maksim Date: 28.12.2020
###
Remove-Variable -Name * -Force -ErrorAction SilentlyContinue
cls
#Add-PSSnapin Microsoft.Exchange.*  # Имортируем модуль EX
if ( (Get-PSSnapin -Name Microsoft.Exchange.* -ErrorAction SilentlyContinue) -eq $null ) {Add-PsSnapin Microsoft.Exchange.*}

Function Pause2 ($Msg = "Press any key to continue . . . ") {
    if ($psise){
        # Если выполняется в ISE       
        Add-Type -assem System.Windows.Forms
        [void][Windows.Forms.MessageBox]::Show("$Msg")
        } else {
            # Если выполняется в ConsoleHost
            Write-Host "$Msg"
            $host.UI.RawUI.ReadKey('NoEcho, IncludeKeyDown') | Out-Null
            }
} # End Function

function IsValidEmail { 
    param([string]$Email)
		$Regex = '^[A-Za-z0-9 ?._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$'
#       $Regex = '^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$'

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

Write-Host "Количество записей в WL:" ((Get-ContentFilterConfig).BypassedSenders).Count
write-host "Введите адрес почтового ящика который нужно проверить "
$wla = read-host "на присутвие в WhiteList "

if(IsValidEmail $wla) {
    Write-Host "Валидный адрес"
} else {
    Write-Host "Невалидный адрес"
    exit
}

(Get-ContentFilterConfig).BypassedSenders | Where-Object {$_.Address -like "$wla*" }

[array]$ArAddrs = (Get-ContentFilterConfig).BypassedSenders | Where-Object {$_.Address -like "$wla*" }

if($ArAddrs.Length -gt 0) { Write-Host "Домен уже введен в WhiteList"; exit }

Write-Host "Если необходимо ввести этот домен в WhiteList"
$v_y = Read-Host "используй y/n "
if($v_y -eq 'y') {
    Set-ContentFilterConfig -BypassedSenders @{add=$wla}
    Write-Host "Adding Domain" $wla    

} else { exit }

Pause2
