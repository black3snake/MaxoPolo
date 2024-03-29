
#cls
Import-Module ActiveDirectory
# paths
$PathToScript=$(Split-Path -Parent $MyInvocation.MyCommand.Path)+"\"
$LogTime = Get-Date -Format "dd-MM-yyyy_hh-mm"
[string]$pc_log = $PathToScript+"$LogTime-Log_consoleEx1.txt"
#
$Fname0 = 'OU=Эн плюс,OU=Организации,DC=iie'
[hashtable]$hashF = @{}
$myarray = [System.Collections.ArrayList]::new()
$hashF.Add($Fname0,$myarray)
# Удаляем права простых пользователей имеющих ExtRight на Pc
[bool]$remove_exri = $true
#
[array]$ExRi_new = @()

$ExRi = Find-AdmPwdExtendedRights -Identity $Fname0 -IncludeComputers
write-host "Исходная коллекция:" $($ExRi.Count)
foreach($e in $ExRi){
	
	if(($e.ExtendedRightHolders -match 'IIE\\(?-i)[a-z]')) {
	#-and ($e.ExtendedRightHolders -notlike 'ie\\adm*') -and ($e.ExtendedRightHolders -notlike 'ie\\Domain*') ) {
		#Write-Host $e.ExtendedRightHolders
		#Start-Sleep 5
		#Write-Host
		if(($e.ExtendedRightHolders -match 'apc') -or ($e.ExtendedRightHolders -match 'srv-xxx') ) {
		
		} else {
			$ExRi_new += $e
			$hashF[$Fname0] += $e
		}
		
	}
	
}
Write-Host "Новая коллекция:" $($ExRi_new.Count)

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
				if($ar -notmatch 'IIE\\') {continue} else { $ar = $ar -replace '^IIE\\' }
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




if($remove_exri) {
    Write-Host "Удаление расширенный прав в записи PC, пользователей с обычной учеткой - Началось!"
    Remove-ExtRights -HashFT $hashF
} else {
    Write-Host
    Write-Host "Удаление расширенный прав в записи PC, пользователей с обычной учеткой - Отключено"
    Write-Host
}




<#  Отключенный машины
[array]$ExRi_new2 = @()
foreach($e2 in $ExRi_new) {
	$tmp_comp = $e2.ObjectDN -replace '^CN=|,.*$'
	if((Get-ADComputer -Identity $tmp_comp).Enabled) {
		$ExRi_new2 += $e2
	} else {
		#$ExRi_new2 += $e2
	}

}
Write-Host "Новая коллекция2:" $($ExRi_new2.Count)
#>

# work code
<#----------------------------------------
$E1 = $ExRi_new | ForEach-Object {$_} | Where-Object{$_.ObjectDN-match 'SERVER'}
$id = [array]::IndexOf($ExRi_new, $E1)


$mashina = $ExRi_new[$id].ObjectDN
$acl = Get-Acl AD:$mashina
$acl_user = $acl.Access | Where-Object {$_.IdentityReference -eq 'IIE\user'}
foreach($au in $acl_user) {
	$acl.RemoveAccessRule($au)
}
Set-Acl -AclObject $acl -Path AD:$mashina
#-----------------------------------
#>

#Invoke-Command -Credential $cred -ScriptBlock {param($acl,$mashina) Set-Acl -AclObject $acl -Path AD:$mashina;   } -ArgumentList $acl,$mashina
