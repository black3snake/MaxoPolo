#
# Получает ACL на ресурс, так же сколько места занимает и в добавок Квоту
# внутри надо поменять путь. (допишу обработку параметра во $Sb,$Sb2 ) 
#
Remove-Variable -Name * -Force -ErrorAction SilentlyContinue
cls
#
$server = "server"
$SH = '\\server\F-SHARE03-RTU\01_Буфер обмена'
[array]$Acs = Get-Acl $SH -Filter Members
[array]$Groups = ($Acs.Access | where {$_.IdentityReference -like "IIE\*"})
[array]$ADgrs = @()
#[string]$LastFolder = $SH -replace '^.+\\',''
[string]$SH2 = $SH -replace '^\\\\',''
$SH2 = $SH2.Split('\\')[1]

[array]$Gws = (Get-WmiObject -class Win32_Share -computername $server –filter "Type=0 OR name like '%$'" )
foreach ($Gw in $Gws) {
	if($Gw.Name -match $SH2) {
		Write-Host "Совпадение с" $Gw.Path
	}
}

Write-Host "Отчет по:" $SH
foreach($item in $Groups) {
    $item2 = $item.IdentityReference -replace '^.+\\',''
    $NameGr = Get-ADGroup -Identity $item2
    #if($NameGr.DistinguishedName -cmatch $LastFolder ) {
        Write-Host "=== Group ===" $item2 "права:" $item.FileSystemRights
        $ADgrs = (Get-ADGroupMember -Identity $item2 | select SamAccountName)
        foreach($a in $ADgrs) {
			$a.SamAccountName
		}
		Write-Host
       
    # }
}

$Sb = { $share = "E:\F-SHARE03-RTU\01_Буфер обмена"; 
$Dr = (dir $share -recurse | where {-Not $_.PSIsContainer} `
| Measure-Object -Property length -Sum -Minimum -Maximum);
$hash=@{ 
Computername=$env:Computername
Folder = $share
SizeMB=[math]::Round(($Dr.sum/1Mb),2)
Files=$Dr.count 
};
New-Object -TypeName PSObject -Property $hash;
}
$Results = Invoke-Command -ScriptBlock $Sb -ComputerName $server -HideComputerName
Write-Host "Общий размер ресурса на данный момент -" $(Get-Date -Format "dd/MM/yyyy")
$Results | sort SizeMB –Descending | Select Computername,Folder,SizeMB,Files | ft -auto

$Sb2 = { $DC = (Get-FsrmQuota | where {$_.Path -cmatch "01_Буфер обмена"});
$hash2=@{
Path = $DC.Path 
SizeMB = [math]::Round(($DC.Size/1MB),2)
UsageMB = [math]::Round(($DC.Usage/1MB),2)
};
New-Object -TypeName PSObject -Property $hash2;
}
$Results2 = Invoke-Command -ScriptBlock $Sb2 -ComputerName $server -HideComputerName
Write-Host "Информация о Квоте на ресурс"
$Results2 | Select Path,SizeMB,UsageMB | ft -AutoSize