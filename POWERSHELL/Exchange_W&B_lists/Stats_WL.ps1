##
## обработка Белого списка на предмет одинаковых доменов и дальнейший их перенос
#  в белый лист доменов.
# Create: Pukhov Maksim Date: 16.02.2021
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

#if(IsValidEmail $wla) {
#    Write-Host "Валидный адрес"
#} else {
#    Write-Host "Невалидный адрес"
#    exit
#}

$WLhash = @{}
$W800S = (Get-ContentFilterConfig).BypassedSenders 



foreach($W800 in $W800S) {
    [string]$post = ($W800.Address -replace "^[A-Za-z0-9 ?._%+-]+@", "")
    $WLhash[$post] = 0
}
Write-Host $W800S.Count "Количество адресов в WhiteList"
Write-Host $WLhash.Count "количество уникальный адресов"
     
for ($i=0; $i -le $W800S.Count – 1; $i++)  {
	[string]$post = ($W800S[$i] -replace "^[A-Za-z0-9 ?._%+-]+@", "")
	
	foreach($key in $($WLhash.Keys)) {
	
		if($key -eq $post) {
			#Write-Host "${key}: $($WLhash.Item($key))"
			$WLhash[$key] += 1 
		}
	}
}  

$WLhash | ft -AutoSize

Pause2