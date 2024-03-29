# Код проверяющий файл Excel на предмет новых записей о DFS
# 06.09.2021 Pukhov Max
#Remove-Variable -Name * -Force -ErrorAction SilentlyContinue
Clear-Host

import-module ActiveDirectory
import-Module NTFSSecurity
import-Module dfsn
do {
        [array]$ModSNV=Get-Module -Name dfsLibrary*
        if($($ModSNV.Count) -gt 0) {Remove-Module $ModSNV[-1].Name}
} while($null -ne (Get-Module -Name dfsLibrary* -ErrorAction SilentlyContinue))
import-module -Name  $($(Split-Path -Parent $MyInvocation.MyCommand.Path)+"\dfsLibrary2.ps1")
write-host "dfsLibriry:" $($(Split-Path -Parent $MyInvocation.MyCommand.Path)+"\dfsLibrary2.ps1")


$global:f1970 = 0
$ErrorActionPreference = "stop"
# Переменная строки откуда начинать работу
$i=25
#Only One String $true (default=$false)
[bool]$NOrepeat = $true
# Имя Домена
$server = 'server'
# Manager can update membership list 
[bool]$CheckBoxManaged = $true

#$cred = Get-Credential -Credential "$env:UserDomain\$env:username"
# 


$PathToScript=$(Split-Path -Parent $MyInvocation.MyCommand.Path)+"\"
if(Test-Path($($PathToScript+"XLSfile2.xlsx"))){
	$xlsx =  $PathToScript+"XLSfile2.xlsx"
} else {
	Write-Host "Файл XLSfile не наден, проверте.." -ForegroundColor Red
	Write-Host "Exit." 
	exit
}
[string]$CurrentDate = Get-Date -Format "dd/MM/yyyy"

# убьем процесс Excel после работы программы
function KillExcel($excel){
	[array]$ProcEx = Get-Process -Name EXCEL -IncludeUserName
	[array]$idPr = @()
	foreach($p in $ProcEx){
		if($($p.UserName -replace '^.+\\','') -eq $env:username) {
			Write-Host "Номер закрываемого EXCEL процесса:"$p.Id
			$idPr += $p.Id
		}
	}
	# Закроем все открытые листы в Excel				
	while($excel.Workbooks.Count -gt 0){
		$excel.Workbooks.Item(1).Close()
	}
	$excel.Quit()
	[System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
	[System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
	foreach($i in $idPr) {
		try {
		Get-Process -Id $i | Stop-Process -Force -Confirm:$false
		} catch {
			write-host $Error[0].Exception.Message -ForegroundColor Red
		}
	}
} #убьем процесс Excel после работы программы
# вывод ошибки в excel
function errorExcel($i2) {
	$ws.Cells.item($i2,4).Interior.ColorIndex = 15
	$ws.Cells.item($i2,15).Interior.ColorIndex = 53
	$ws.Cells.item($i2, 10) = $null
	$ws.Cells.item($i2, 11) = $null
	$ws.Cells.item($i2, 12) = $null
	$ws.Cells.item($i2, 13) = $null
	$ws.Cells.item($i2, 14) = $null
	$ws.Cells.item($i2, 15) = "ОШИБКА"
	write-host $Error[0].Exception.Message -ForegroundColor Red
} # вывод шибки в excel

$excel = New-Object -ComObject "Excel.Application"
$excel.Visible = $false
$excel.displayAlerts = $false
$wb = $excel.workbooks.open($xlsx)
$ws = $wb.worksheets.item("EnPlusDigital")

$account = $ws.Cells.item($i, 5).Text
#$server = $ws.Cells.item(2, 10).Text
$Error.Clear()
while ((-not [string]::IsNullOrEmpty($account)) -and (-not [string]::IsNullOrEmpty($($ws.Cells.item($i,4).Text))) ) {
$status = $ws.Cells.item($i, 15).Text
$path = $ws.Cells.item($i,4).Text
$path = $path.TrimEnd()
Write-Host $account
$Error.Clear()
if([string]::IsNullOrEmpty($status)) {
                #  Проверим существования этого пути в DFS 
				$ii = $path.IndexOf('dfs')
				$t = $path.Substring($ii+4).Split('\').count
				$Error.Clear()
				try {
					if(($t -le 2) -and ($t -gt 0)) {
						if($(Get-DfsnFolder -Path $path).State -eq "Online" ) {
							$ws.Cells.item($i,4).Interior.ColorIndex = 8
						} else {
							errorExcel($i)
							Write-Host "Статус отличен от Online" $path -ForegroundColor Red
							if(!$NOrepeat){$i++}else{break}
							continue
						}
					} elseif($t -gt 2)	{
						if(Test-Path($path)) {
							$ws.Cells.item($i,4).Interior.ColorIndex = 0
						} else {
							errorExcel($i)
							if(!$NOrepeat){$i++}else{break}
							continue
						}
					}
				}catch {
					write-host "ошибка DFS: " -NoNewline
					errorExcel($i)
					Start-Sleep 4
					if(!$NOrepeat){$i++}else{break}
					continue
				}
				
				<#
				[array]$pathGroup = ($path -replace '^\\.','' ).Split('\')
				Write-Host "Domen:"$pathGroup[0] ",root:" $pathGroup[1] ",1Level:" $pathGroup[2] ",2Level:" $pathGroup[3]
				
				if($pathGroup.Count -gt 4) {
					Write-Host "3Level:" $pathGroup[4]
				}
				if($pathGroup.Count -gt 5) {
					Write-Host "4Level:" $pathGroup[5]
				}
				Write-Host "-----------------------"
				Start-Sleep 1
				#$gr_read = $ws.Cells.item($i, 10).Text
				#$gr_write = $ws.Cells.item($i, 12).Text
				#>
				$Error.Clear()
				try {
				$result = Main -Path $path -Account $Account -Server $server -CheckBoxManaged $CheckBoxManaged
			
				} catch {
					write-host $Error[0].Exception.Message -ForegroundColor Red
					$Error.Clear()
					KillExcel($excel)
					exit
				}
				
				$Error.Clear()
				if( $global:f1970 -eq 1 ) {
                        $ws.Cells.item($i,15).Interior.ColorIndex = 53
						$ws.Cells.item($i, 15) = "ОШИБКА"
                } ELSE {
                	$gr_read = $(($result["Read0"].ObjectGUID).Guid)
					$gr_read_name = $($result["Read0"].SamAccountName)
					$gr_write = $(($result["Write0"].ObjectGUID).Guid)
					$gr_write_name = $($result["Write0"].SamAccountName)
					if((![string]::IsNullOrEmpty($gr_read)) -and (![string]::IsNullOrEmpty($gr_read))) {
						$ws.Cells.Item($i,10) = $gr_read_name
						$ws.Cells.Item($i,11) = $gr_read
						$ws.Cells.Item($i,12) = $gr_write_name
						$ws.Cells.Item($i,13) = $gr_write
						$ws.Cells.Item($i,14) = $CurrentDate
						$ws.Cells.item($i,15).Interior.ColorIndex = 10
						$ws.Cells.item($i, 15) = "ГОТОВО"
					} else {
						errorExcel($i)
						#$ws.Cells.item($i,15).Interior.ColorIndex = 53
						#$ws.Cells.item($i, 15) = "ОШИБКА"	
					}
			
                }
				try {
                	$wb.Save()
				} catch {
					write-host $Error[0].Exception.Message
					KillExcel($excel)
					exit
				}
        }
        if(!$NOrepeat){$i++}else{break}
        $account = $ws.Cells.item($i, 5).Text
}
try {
	$wb.Save()
} catch {
	write-host $Error[0].Exception.Message
	KillExcel($excel)
	exit
}
KillExcel($excel)

Write-Host "Press any key to continue ..."

$x_lank = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

<#
$PSDefaultParameterValues += @{
    "Get-Function:ErrorAction"="Stop"
    "Get-Command:ErrorAction"="Stop"
    "Get-MyFunction*:ErrorAction"="Stop"
}
#>