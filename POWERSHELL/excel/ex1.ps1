###
# Программа проверки сопаставлений в файле источник XLS
# проверяем в XML
# create: Pukhov Maksim Date:15.01.2021
##
Remove-Variable -Name * -Force -ErrorAction SilentlyContinue
Clear-Host

$xls = "D:\Scripts\АТС_ДЗР_номера.xlsx"
$excel = New-Object -ComObject "Excel.Application"
$excel.DisplayAlerts = $false
$wb = $excel.workbooks.open($xls)
$ws = $wb.worksheets.item("Лист1")

$MaxRows = ($ws.UsedRange.Rows).count;
$MaxColumns = ($ws.UsedRange.Columns).count;
$users=@{};

for ($row = 2; $row -le $MaxRows; $row++) {
#Создадим объект для сотрудников
    $user = New-Object -TypeName PSObject

    for ($col = 1; $col -lt $MaxColumns; $col++) {
        #$user | Add-Member -Name $ws.Columns.Item($col).Rows.Item($row).Text -Value $ws.Columns.Item($col+1).Rows.Item($row).Text -MemberType NoteProperty
		$users.Add($ws.Columns.Item($col).Rows.Item($row).Text, $ws.Columns.Item($col+1).Rows.Item($row).Text)
    }

}
#$users
$Excel.Quit();
[xml]$xml = Get-Content "D:\Scripts\contact.xml"


$xmlH = @();
$xmlH = $xml.DocumentElement.DirectoryEntry

#foreach ($x in $xml) {
#	
#	if ($x -match "^<Name>") {
#		$key = $x.Trim()
#		$key = $key -replace '^<Name>', ''
#		$key = $key -replace '</Name>', ''
#		$xmlH.add($key, 0)
#	}  
#	if ($x -match "^<Telephone>") {
#		$value = $x.Trim()
#		$value = $value -replace '^<Telephone>', ''
#		$value = $value -replace '</Telephone>', ''
#		$xmlH[$key] = $value
#	}
#}
#Foreach($x in $xmlH) {
#	Write-Host  $x.Name "           " $x.Telephone 
#}

Foreach($key in $users.Keys) {

	for ($x = 0; $x -lt $xmlH.Length+1; $x++) {
		if($xmlH[$x].Telephone -contains $key ) {
			Write-Host "номер" $key  " -> " $xmlH[$x].Telephone
			Write-Host "Value" $users[$key]   " -> " $xmlH[$x].Name
	}
}

}