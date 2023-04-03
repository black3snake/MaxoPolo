#############################################################
# Имя: Clear_Profile01.ps1 Create: Pukhov Maksim Date: 02.11.2020
# Язык: PoSH 5.1
# Описание: Закрытие сессий пользователя, востановление атрибутов и удаление как нормальных файлов так и длинных 260+
#############################################################
cls
#Add-PSSnapin citrix*  # Имортируем модуль цитриус
if ( (Get-PSSnapin -Name citrix* -ErrorAction SilentlyContinue) -eq $null ) {Add-PsSnapin citrix*}
#
# - логин вводится без каких либо спец. символов.
# 
$User = "morozovama"
$Domen = "ie"
#
$Account = $Domen+"\"+$user
#
# инициализация путей профиля
$destinationpath = "\\server\CTXProfiles\"
$SourceDir = $destinationpath + $User + "."+ $Domen + ".v2"  
$Dir_Empty = $SourceDir + ".empty"
#
#
$Session = Get-xasession -Account $Account
if(!$Session) { Write-Host "Сессия пользователя $User не найдена" -ForegroundColor Red }
    else {
        foreach ($item in $Session | Get-Unique) {
            Write-Host $item -ForegroundColor Gray
            $item | stop-xasession; write-host "Сессия пользователя $($item.AccountName) $item отключена" -ForegroundColor Green 
        }
}
Start-Sleep 5

#
#функция создания пустого директория 
function RoBo($D_empty) {                                
    if (Test-Path $D_empty) {
        Remove-Item $D_empty -Force -Recurse
    }     
    New-Item -Path $D_empty -Type "directory" | Out-Null
}
#
#функция копирования директории, сохраняя все права и атрибуты
Function RoCoDir($S_Dir) {                               
    $D_copy = $S_Dir + ".iie.v2.copy"
    #Define arguments for robocopy
    $array = @("/E","/COPYALL","/SECFIX","/R:0","/W:0")
    #Create an arraylist
    $params = New-Object System.Collections.Arraylist
    $params.AddRange($array)
    
    #Write-Host $S_Dir $D_copy $params
    robocopy $S_Dir $D_copy $params
}
#
#функция удаления директории содержащие пути 260+ 
Function RoDel($S_Dir,$D_empty) {                        
    #Define arguments for robocopy ( "/L" только имитирует работу | "/E")
    $array = @("/E","/PURGE","/R:0","/W:0")
    #Create an arraylist
    $params = New-Object System.Collections.Arraylist
    $params.AddRange($array)

    #Write-Host $Dir_Empty
    #Write-Host $SourceDir
    robocopy $Dir_Empty $SourceDir $params | Out-Null
}
#
$ErrorActionPreference = "stop"
try {
    Write-Host "Проверка Атрибутов Директории"
    [string]$dirStr = (Get-ItemProperty $SourceDir).Attributes
    $dirAr=$dirStr.Split(",")
    if($dirAr -contains "Hidden") {
        Write-Host "Директория имеет" $dirAr -ForegroundColor Gray "артибуты, заменим на нормальные"
        $(Get-ItemProperty $SourceDir).Attributes = "Directory"
    } else {
        Write-Host "Атрибуты нормальные" $dirAr -ForegroundColor Gray
    }

    #Build a list of folders and files
    $Folder = $destinationpath + "$User.*"
    $FolFil = Get-childitem -Force -Path $Folder               #| where {$_.Mode -like "d*"}
    Write-Host "Директория содержит нормальные по длине имена папок и файлов"
    write-host "Очистка терминального профиля"
    if (!$FolFil) {write-host "Терминальный профиль не найден" -ForegroundColor red -BackgroundColor white}    
        else {    
            foreach($fofl in $FolFil) {
                $fofl | Remove-Item -Force -Recurse
            }
            write-host "Терминальный профиль почищен: $Account" -ForegroundColor Green 
        }
    }
catch [System.Management.Automation.ItemNotFoundException] {
    Write-Output "Вы ошиблись такого директория $SourceDir в этом пути нет, проверте!"
}
catch [System.IO.PathTooLongException] {
    Write-Output "Директория содержит длинные имена папок и файлов 260+"
    #$error | fl * -F
    RoBo($Dir_Empty)

    #Удаление директории --------------------------
    #Write-Host $SourceDir 
    #Write-Host $Dir_Empty
    RoDel($SourceDir,$Dir_Empty)
    Remove-Item $Dir_Empty -Force -Recurse
    #
    #Если стоит ключ /L то нижняя Remove строка должна быть закоментирована
    #Если стоит ключ /E то раскометирована! дабы не оставить пустую директорию.
    Remove-Item $SourceDir -Force -Recurse
    write-host "Терминальный профиль почищен: $Account" -ForegroundColor Green 
}
#
#Копирование директории -----------------------
#RoCoDir($SourceDir)
#

Remove-Variable -Name * -Force -ErrorAction SilentlyContinue
