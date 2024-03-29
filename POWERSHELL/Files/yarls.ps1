# Обработка ярлыков , замена ссылки на ресурс
# 20.05.2022

# Pattern
# Что ищем
[string]$src = '\\xx\root\ИWИД\Docs\'
# На что меняем
[string]$dst = '\\xx\dsf\'
# Начало пути где искать файлы яклыков
[string]$path = 'C:\Users\mv\Desktop\Yarls'


$shell  = New-Object -ComObject WScript.Shell
$count = 0
[array]$arr = @();
$arr = Get-ChildItem -Path $path -Force -Recurse -Include '*.lnk'

foreach($a in $arr) {
	$ShortcutObj = $Shell.CreateShortcut($a.fullname);
	Write-Host "Название файла $($a.fullname)"
	if($ShortcutObj.TargetPath.Contains($src)) {
		Write-Host "Совпадение найдено с $src"
		[string]$newString = $dst + $ShortcutObj.TargetPath.Substring($src.Length)
		Write-Host $newString
		$ShortcutObj.TargetPath = $newString
		$Error.Clear()
		try {
			$ShortcutObj.Save()
			Write-Host "внесено изменение в $($a.fullname)"
		} catch {
			Write-Host $($Error[0].Exception.Message) -ForegroundColor Red
		}
		$count++
    } elseif ($ShortcutObj.TargetPath.Contains($dst)) {
        Write-Host "Изменения уже были внесены Target содержит заменяемое"
    } else {
        Write-Host "Совпадение не найдено" -NoNewline
        Write-Host
    }
	$ShortcutObj = $null
	Write-Host
    Start-Sleep 1
	
}
Write-Host "итого обработано ярлыков: $count"