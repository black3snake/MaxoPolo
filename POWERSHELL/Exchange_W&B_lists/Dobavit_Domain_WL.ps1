##
## проверка адреса на присутсвие в списке WhiteList
# Create: Pukhov Maksim Date: 06.4.2021
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


write-host "Введите адрес домена который нужно добавить, SubDomains будут включены"
$wla = read-host "в WhiteList"
$wla = "*."+$wla
$wla = $wla.Trim()

if($wla -match '(?=@).[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$') { write-host "Необходимо водить имя домена без имя@"; exit }

(Get-ContentFilterConfig).BypassedSenderDomains | Where-Object {$_.Address -like "$wla*" }

[array]$ArAddrs = (Get-ContentFilterConfig).BypassedSenderDomains | Where-Object {$_.Address -like "$wla*" }

if($ArAddrs.Length -gt 0) { Write-Host "Домен уже введен в WhiteList"; exit }

Set-ContentFilterConfig -BypassedSenderDomains @{add=$wla}
Write-Host "Adding Domain" $wla

Pause2
