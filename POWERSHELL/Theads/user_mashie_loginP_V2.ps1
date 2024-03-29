# Использование параллельного выполнения Runspace, для быстрого поиска
# где был залогинин пользователь
# Create: Pukhov Maksim, 22.05.2021
##
Remove-Variable -Name * -Force -ErrorAction SilentlyContinue
Clear-Host
#
$user = Read-Host "введите логин пользователя"
$user = $user.Trim()

$cred = Get-Credential -Credential "IIE\adc_"

$Code = {
    param($OUper,$cred,$user)
    [array]$Rez = @()
	#Путь где будут лежать файлы с найденными результатами
	$PathF = 'D:\Scripts\LOGON\'
	$Rez = (Get-ADComputer -SearchBase $OUper.DistinguishedName -Filter {enabled -eq "true"} -Properties * -Credential $cred | Select-Object Name, LastLogonDate, description | Where-Object {$_.description -like "*"+$user+"*"})
	$nameAr = $OUper.DistinguishedName.Split(',')[0,1].replace('OU=','')
	$name = $nameAr[0]+$nameAr[1]+'.txt'
	if($Rez.Count -ne 0) { 
		try {
		$Item = New-Item -Name $name -Path $PathF  -ErrorAction Stop
		} catch {
			Write-Output $($Error[0].Exception.Message)
			Write-Output "Перепишем файл"
			$Item = $PathF+$name
		}
		Set-Content $Item -Value $Rez
	}
}

$onelevels = @()
$onelevels =  Get-ADOrganizationalUnit -SearchBase 'OU=Организации,DC=ie,DC=corp' -Filter * -SearchScope OneLevel -Credential $cred
$twolevels = New-Object System.Collections.Arraylist

foreach($onelev in $onelevels) {
    $twolevels.AddRange(@(Get-ADOrganizationalUnit -SearchBase $onelev -Filter * -SearchScope OneLevel -Credential $cred | select DistinguishedName ))
}

foreach($twolevel in $twolevels) {
     write-host $twolevel.DistinguishedName
}
Write-Host "Количество записей: " $twolevels.Count

$RunspacePool = [runspacefactory]::CreateRunspacePool(
    1, #Min Runspaces
    5 #Max Runspaces
)
$RunspacePool.Open()

$i=0
$Jobs = New-Object System.Collections.ArrayList

foreach($OUper in $twolevels) {
	$i++
	Write-Host "Creating runspace for" $OUper.DistinguishedName
	$PowerShell = [powershell]::Create()
    	$PowerShell.RunspacePool = $RunspacePool
	
	$PowerShell.AddScript($Code).AddArgument($OUper).AddArgument($cred).AddArgument($user) |Out-Null
	

	$JobObj = New-Object -TypeName PSObject -Property @{
		Runspace = $PowerShell.BeginInvoke()
		PowerShell = $PowerShell  
    }

    $Jobs.Add($JobObj) | Out-Null


}
while ($Jobs.Runspace.IsCompleted -contains $false) {
    Write-Host (Get-date).Tostring() "Still running..."
	Start-Sleep 2
}

