##
# Изменение текущей даты на компьютере
# Pukhov Maksim, create: 19.01.2021
##
Remove-Variable -Name * -Force -ErrorAction SilentlyContinue
Clear-Host

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

$t_date = Get-Date #-Format dd.mm.yyyy
Write-Host "Текущая дата" $t_date

Write-Host "Если необходимо изменить дату введите День.Месяц.Год(2021) "
Write-Host "Или нажмите клавишу Enter для установки текущей даты"
[string]$iz_data = Read-Host "Формат День.Месяц.Год(2021) или Enter"
$iz_d_m = $()
$iz_d_m = $iz_data.Split('.')
if (![string]::IsNullOrEmpty($iz_data)) {
	$date = Get-Date -Day $iz_d_m[0] -Month $iz_d_m[1] -Year $iz_d_m[2]
	Write-Host $date
	try {
		Set-Date $date
	} catch [System.ComponentModel.Win32Exception] {
		Write-Host "Программа должна запускаться с правами администратора"
		Pause2
		exit
	}
	
} else {
		$w32t = (Get-Service W32Time).Status
	if ($w32t -eq 'Running') {
		Write-Host "Службу времени запущена - Синхонизируемся"
		w32tm /resync /force
	} else {
		Write-Host "Стартуем службу времени"
		Start-Service W32Time
		do {
			Write-Host "Ожидание.."
			Start-Sleep 5
			$w32t = (Get-Service W32Time).Status
			if($ii -eq 23) { 
				Get-Date
				Pause2
				exit 
			}
			$ii++
		}
		while($w32t -eq 'Stopped') 
		w32tm /resync /force
	}
	Get-Date
	Pause2
	exit
}
Pause2

Remove-Variable -Name * -Force -ErrorAction SilentlyContinue
