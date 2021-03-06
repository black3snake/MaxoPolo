##
# вывод имени и полного пути OU и дату создания -> вывод в Excel
# Created: Pukhov Maksim, 02.03.2021
##
Remove-Variable -Name * -Force -ErrorAction SilentlyContinue
Clear-Host

$XL = New-Object -ComObject "Excel.Application"
#Делаем окно Microsoft Excel видимым
$XL.Visible = $True
#Открываем новую рабочую книгу
$XL.WorkBooks.Add() > $Null
#Устанавливаем нужную ширину колонок
$XL.Columns.Item(1).ColumnWidth = 100
$XL.Columns.Item(2).ColumnWidth = 50
$XL.Columns.Item(3).ColumnWidth = 15
#Печатаем в ячейках текст
$XL.Cells.Item(1,1).Value="ObjectDN"
$XL.Cells.Item(1,2).Value="ExtendedRightHolders"
$XL.Cells.Item(1,3).Value="WhenCreated"
#Выделяем три ячейки
$XL.Range("A1:C1").Select() > $Null
#Устанавливаем полужирный текст для выделенного диапазона
$XL.Selection.Font.Bold = $true

$dynM = @();
$dynG = Get-Content -Path "D:\Scripts\1.txt"
$ii=2
foreach($d in $dynG) {
	$dynM = $d.Split(";") 	
	$D1 = $dynM[0].Trim('"')
	$O2 = $dynM[1].Trim('"')
	$W3 = $dynM[2].Trim('"')
		
    $XL.Columns.Item(1).Rows.Item($ii) = $D1
	$XL.Columns.Item(2).Rows.Item($ii) = $O2
	$XL.Columns.Item(3).Rows.Item($ii) = $W3
	$ii++
}
