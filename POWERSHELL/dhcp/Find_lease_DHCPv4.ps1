#
# нахождение состояния IP в DHCP, возможность его резервирования
# и вывода из резервирования.
# Create: Pukhov Maksim

Remove-Variable -Name * -Force -ErrorAction SilentlyContinue
Clear-Host
Import-Module DHCPServer

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

function IsValidMAC {
    param([string]$MAC)
                $Regex = '^([0-9A-F]{2}[-]){5}([0-9A-F]{2})$'
   try {
        if($MAC -match $Regex){
            return $True
        }
        return $False
    }
    catch {
        return $False
    }
}

Function killRes {
Param(
        [Parameter(Mandatory=$True,
            HelpMessage="Объект с которым мы работаем",
		    ValueFromPipeLine = $false,
			Position = 0)]
            [psobject]$Person,
  
        [Parameter(Mandatory = $true,
			HelpMessage="Сервер который мы опрашиваем",
			ValueFromPipeLine = $false,
			Position = 1)]
			[string]$server
      
      )


Remove-DhcpServerv4Reservation -ComputerName $server -ScopeId $Person.ScopeID -ClientId $Person.'MAC Address'

Write-Host
Write-Host "ИП адрес:" $Person.'IP Address' "удален из резервирования"
Write-Host
Start-Sleep 5
}

Function Reserv {
Param(
        [Parameter(Mandatory=$True,
            HelpMessage="Объект с которым мы работаем",
		    ValueFromPipeLine = $false,
			Position = 0)]
            [psobject]$Person,

        [Parameter(Mandatory = $true,
			HelpMessage="Сервер который мы опрашиваем",
			ValueFromPipeLine = $false,
			Position = 1)]
			[string]$server

    )

if(($Person.AddressState -eq 'ActiveReservation') -or ($Person.AddressState -eq 'InactiveReservation')) {
    #delete reserv
	$res_y = Read-Host "Существует резервирование этого ИП:" $Person.'IP Address' "по MAC:" $Person.'MAC Address' "- удалить? y/n"
	if($res_y -eq 'y') {
	     Remove-DhcpServerv4Reservation -ComputerName $server -ScopeId $Person.ScopeID -ClientId $Person.'MAC Address'
        
	         
        $ii = 0
        do { 
            # Зарегистрировать MAC и передать Имя
            [string]$NewMac = Read-Host "Enter the computers NEW MAC address (xx-xx-xx-xx-xx-xx) - 4 попытки"
            if(IsValidMAC $NewMac) {
                Write-Host "Валидный MAC адрес"
                $ii = 5
            } else {
                Write-Host "Невалидный MAC адрес"
                if ($ii -gt 2) { exit }
                $ii++
            }
        } while ($ii -lt 4)
        
        
        $Person.'MAC Address' = $NewMac

        if($null -eq  $Person.HostName) {
            $Computer = Read-Host "Enter in the computer name."

        }

#        Add-DhcpServerv4Reservation -ComputerName $server -ScopeId $Person.ScopeID -IPAddress $Person.'IP Address' -ClientId $Person.'MAC Address' -Description $Person.User -Name $Person.HostName -Type DHCP


    }    
} 

Add-DhcpServerv4Reservation -ComputerName $server -ScopeId $Person.ScopeID -IPAddress $Person.'IP Address' -ClientId $Person.'MAC Address' -Description $Person.User -Name $Person.HostName -Type DHCP


Write-Host
Write-Host "ИП адрес:"$Person.'IP Address' "Зарезервирован c новым MAC:" $Person.'MAC Address'
Start-Sleep 5
Write-Host
}

# Нахождение Scope на серверах
Function ScopeP {
Param(
        [Parameter(Mandatory=$True,
        HelpMessage="Объект Scope",
        ValueFromPipeLine = $false,
	    Position = 0)]
        [psobject]$Scope,
        
        [Parameter(Mandatory = $true,
		HelpMessage="Сервер который мы опрашиваем",
		ValueFromPipeLine = $false,
		Position = 1)]
		[IPAddress]$IP
    
    )
$IPstr = $ip.IPAddressToString -replace '\d+$', '*'
$ScopeF = ''
foreach($Sc in $Scope.ScopeId.IPAddressToString) {
    if($Sc -like $IPstr){
		$ScopeF = $Sc
		break
	}
}
return $ScopeF
}


$Person = New-Object PSOBJECT
$servers = (Get-DhcpServerInDC).DnsName
write-host "Введите ИП адрес для поиска Scope" -ForegroundColor Yellow
$IP = read-host "Введи ip-адрес" 
$IP = [IPAddress]$IP.Trim()

    foreach($server in $servers) {
        write-host $server "ищем.." -NoNewline
        try {       
            $Scope = Get-DhcpServerv4Scope -ComputerName $server -ErrorAction Stop
			$ScopeFind = ScopeP -Scope $Scope -IP $IP
			if(![string]::IsNullOrEmpty($ScopeFind)) {
			    write-host
                Write-Host "-----------***----------"
            	Write-Host $ScopeFind "Найдена Scope на сервере" -ForegroundColor Gray
				}	
			
			$ReservationObj = Get-DhcpServerv4Lease -ComputerName $server -IPAddress $IP -ErrorAction Stop 
            #$ReservationObj = Get-DhcpServerv4Reservation -ComputerName $server -IPAddress $IP -ErrorAction Stop
			
			#$Person = New-Object PSOBJECT
       		$Person | Add-Member "Device Name" $ReservationObj.GetCimSessionComputerName
       		$Person | Add-Member User $ReservationObj.Description
       		$MAC = $ReservationObj.ClientId
       		#$MAC = $MAC -replace "-", ":"
       		$SCOPE = $ReservationObj.ScopeId
			$HName = $ReservationObj.HostName
			$AdrSt = $ReservationObj.AddressState
			$CType = $ReservationObj.ClientType
			$Person | Add-Member "MAC Address" $MAC
       		$Person | Add-Member "IP Address" $IP
			$Person | Add-Member "ScopeID" $SCOPE
			$Person | Add-Member "HostName" $HName
			$Person | Add-Member "AddressState" $AdrSt
			$Person | Add-Member "ClientType" $CType
			
			Write-Output $Person | Format-List
            
            Write-Host "1 - Зарезервировать ИП адрес или поменять МАС если он зарегистрирован"
            Write-Host "2 - Удалить резервирование ИП адреса"
            Write-Host "3 - Оставить как есть"
            
            $a = Read-Host "Сделайте выбор:"
            switch ($a) {
                1 {"Сделан выбор 1"; Reserv -Person $Person -server $server }
             
                2 {"Сделан выбор 1"; killRes -Person $Person -server $server }
                
                3 {"Как есть Выход"; exit }
                
                default {
                "Out of range"; 
                exit 
                } 
            }			
        #Не будем дальше проверять другие DHCP адреса
        break
                      
        }
        catch { 
            Write-Output " Nothing found."
            
        }
}
$Person
Write-Host
Write-Host "Опрос" $server 
if(($Person | gm).Name -like "IP*") {
    Get-DhcpServerv4Lease -ComputerName $server -IPAddress $Person.'IP Address'
} else {

    write-host "Nothing found in list DHCP"
}

Pause2

#Remove-Variable -Name * -Force -ErrorAction SilentlyContinue
