#
# программа архивации логов , путем орхивации и 
# и созлания архива какждого лог файла, еще и обновляет старые архивы
#  17.09.2021, Pukhov Maxim

Remove-Variable -Name * -Force -ErrorAction SilentlyContinue
Clear-Host

# Пути к ресурсам которые где лежат логи , рекурсии нет.
[array]$pathA = @(
'C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\LOGS'

)

if($Host.Version.Major -lt 5) { 
    Write-Host "Версия Powershell ниже 5.."
    Write-Host $($Host.Version)
    exit 
} 
#Хранение архивов 12 дней
[datetime]$Delta12 = $((Get-Date).Adddays(-12))

# Раширение лог файлов
[string]$raz = '*.log'
# Раширение zip файлов
[string]$zip = '*.zip'

# Счетчики
[int32]$countNew = 0
[int32]$countOld = 0
[int32]$countITOG = 0
foreach($p in $pathA) {
    [array]$files = Get-ChildItem -Path $p -Force -ErrorAction SilentlyContinue -Filter $raz

    foreach($f in $files) {
        if($f.LastAccessTime -lt $((Get-Date).Adddays(-1))) {
            Write-Host $f.FullName "-" $f.LastAccessTime
            [string]$zipF = $($($f.FullName)+'.zip')
                if(-not $(Test-Path($zipF))) {
                    Compress-Archive -DestinationPath $zipF -Path $($f.FullName)
                    Remove-Item -Path $f.FullName -Force -Confirm:$false
                    $countNew++
                } else {
                    Compress-Archive -DestinationPath $zipF -Update -Path $($f.FullName)
                    Remove-Item -Path $f.FullName -Force -Confirm:$false
                    $countOld++        
                }

        } else {
        Write-Host "Файлы которые не затронуты " $f.Name ", " $f.LastAccessTime
        }

    }
    Write-Host "Ресурс: " $p
    Write-Host "Количество новых созданных архивов: " $countNew
    Write-Host "Количество старых Update архивов: " $countOld
    Write-Host "Всего обработано в ресурсе файлов: " $($files.Count)
    Write-Host
    $countITOG += $($files.Count)
    $files = $null
    Start-Sleep 5

    write-host "УДАЛИМ ZIP старые архивы) старше 12 дней"
    Start-Sleep 3
    [int]$countDel=0

    [array]$filesZip = Get-ChildItem -Path $p -Force -ErrorAction SilentlyContinue -Filter $zip
    foreach($z in $filesZip) {
        # Проверка конкретных архивов где в имени есть SCH02
        if($z.Name -notmatch 'SCH02') { continue }
        [string]$r_tmp = $z -replace '^.*?K-'
        $r_tmp = $r_tmp -replace '-.*$'
        [array]$r_ar = $r_tmp.ToCharArray()
        [string]$r_str = ($($r_ar[0..3] -join '')+'-'+$($r_ar[4,5] -join '') +'-'+$($r_ar[6,7] -join ''))
        [datetime]$r_data = Get-Date -Date $r_str
        
        # сравним и удалим старый архивы
        if($r_data -lt $Delta12) {
            Remove-Item -Path $z.FullName -Force -Confirm:$false
            Write-Host "Удален архив:" $z.FullName
            $countDel++
        
        }
    }

}
Write-Host
Write-Host "Итого всего обработанных фалов:" $countITOG
Write-Host "Количество удаленных файлов:" $countDel


#Write-Host "Press any key to continue ..."

#$x_lank = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
