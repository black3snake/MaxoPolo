# Новая версия DFSLibrary.ps1
# ver 1.2.7 Date: 29.11.2021

# Создание OU папки а AD
function Make_OU { 
    Param([Parameter(Mandatory = $true,
        HelpMessage="Проверяемый OU",
        Position = 0,
        ValueFromPipeLine = $false)]
        [string]$OU,
            
        [Parameter(Mandatory = $true,
        HelpMessage="server на котором проверяем",
        Position = 1,
        ValueFromPipeLine = $false)]
        [string]$server,
    
        [Parameter(Mandatory = $true,
        HelpMessage="Предварительно сформированное имя группы",
        Position = 2,
        ValueFromPipeLine = $false)]
        [Array]$PathGroup
        
    )
$Error.Clear()
try {
    $OU_tmp = $OU -replace '^.*?,'
    New-ADOrganizationalUnit -Name $PathGroup[-1] -Path $OU_tmp -Server $server -ProtectedFromAccidentalDeletion $true
    Write-Host "Создалась папка в AD:" $PathGroup[-1]
    Write-Host "Ожидание обновления AD..."
    Start-Sleep 15
    return 1
}
catch {
    write-host $Error[0].Exception.Message -ForegroundColor Red
    write-host "Не создался OU :(" -ForegroundColor Red
}
} # Создание OU папки а AD


# Создание OU текущей папки
function GetOU {
    Param( 
        [Parameter(Mandatory = $true,
        HelpMessage="Родительский OU",
        Position = 0,
        ValueFromPipeLine = $false)]
        [string]$OU_parent,    

        [Parameter(Mandatory = $true,
        HelpMessage="Предварительно сформированное имя группы",
        Position = 1,
        ValueFromPipeLine = $false)]
        [Array]$PathGroup,
    
        [Parameter(Mandatory = $true,
        HelpMessage="Левел папки",
        Position = 2,
        ValueFromPipeLine = $false)]
        [string]$lev
    
    )

    
for($i=$PathGroup.Count-1; $i -ge 3; $i-- ) {
    $ou_tmp += 'OU='+$PathGroup[$i]+','
    
}
$ou = $ou_tmp+$OU_parent

# Обработка символа плюса
if ($ou -match '\+') { $ou = $ou -replace '\+','\+' }
Write-Host "OU текущей папки:" $ou
return $ou
} # Создание OU текущей папки

# функция проверки OU
function CheckPathOU{ 
    Param([Parameter(Mandatory = $true,
            HelpMessage="Проверяемый OU",
            Position = 0,
            ValueFromPipeLine = $false)]
            [string]$OU,
            
            [Parameter(Mandatory = $true,
            HelpMessage="server на котором проверяем",
            Position = 1,
            ValueFromPipeLine = $false)]
            [string]$server,
    
            [Parameter(Mandatory = $true,
            HelpMessage="Предварительно сформированное имя группы",
            Position = 2,
            ValueFromPipeLine = $false)]
            [Array]$PathGroup
    
    )

if($PathGroup.Count -gt 4) {
    # Попытка создания промежуточных папок OU в AD
    $Error.Clear()
    try{
        [int]$countParent = 3
        [int]$countCurrent = $PathGroup.Count
        [int]$ic = 0
        [string]$OU_next
        $OU_parent = GetOU_Parent -PathGroup $PathGroup
        do {
          
            $OU_next += 'OU='+$PathGroup[$countParent]+','
            $countParent++
            $ic++
        } while ($countParent -ne $countCurrent-1 )
        $OU_next += $OU_parent
        Get-ADOrganizationalUnit -Identity $OU_next -Server $server
        Write-Host "Директория промежуточная в AD существует:" $($OU_next.Split(',')[0] -replace '^OU=') 
    } catch {
        Write-Host "Директории промежуточной нет в AD:" $($OU_next.Split(',')[0] -replace '^OU=')
        # Пробуем создать!!!
        Make_OU $OU_next -server $server -PathGroup $($PathGroup[0..($PathGroup.count-$($ic+1))])
    }
}
    $Error.Clear()
    try {
        Get-ADOrganizationalUnit -Identity $OU -Server $server
        Write-Host "директория в AD существует:" $($PathGroup[-1])
        return 1
    } catch {
        Write-Host "Директории нет: " $($PathGroup[-1])
        write-host $($Error[0].Exception.Message) -ForegroundColor Red
        return 0
    }
    return 0	
    
} # функция проверки OU

# получени OU родительской папки 1 Уровня
function GetOU_Parent {
    Param(
        [Parameter(Mandatory = $true,
		HelpMessage="Массив содержимого пути",
		Position = 0,
		ValueFromPipeLine = $false)]
		[Array]$PathGroup
    )
$count = 3

[string]$path_tmp = '\\'
for($i=0; $i -lt $count; $i++ ) {
	$path_tmp += $($PathGroup[$i]+'\')

}
$path_tmp = $path_tmp.TrimEnd('\')
[array]$acl_tmp = (get-acl -path $path_tmp).Access
foreach($a in $acl_tmp) {
	if($a.IdentityReference -match $PathGroup[$count-1]) {
		$gr_tmp = $a.IdentityReference.Value.Substring(3, $($a.IdentityReference.Value.Length-3))
		break
	}

}
$OU_parent_tmp = (Get-ADGroup -Identity $gr_tmp).DistinguishedName

$OU_parent_tmp = $OU_parent_tmp -replace '^CN.*?,'

return $OU_parent_tmp
} # получени OU родительской папки 1 Уровня


# функция проверяющее имя группы, если оно есть в OU контейнера
function CheckGroup {
    Param(
        [Parameter(Mandatory = $true,
        HelpMessage="родительский OU",
		Position = 0,
		ValueFromPipeLine = $false)]
		[string]$OU_parent,

        [Parameter(Mandatory = $true,
        HelpMessage="Server Active Directory",
        Position = 1,
        ValueFromPipeLine = $false)]
        [String]$gr_tmp,

        [Parameter(Mandatory = $true,
		HelpMessage="Массив содержимого пути",
		Position = 2,
		ValueFromPipeLine = $false)]
		[Array]$PathGroup,
        
        [Parameter(Mandatory = $true,
        HelpMessage="уровень папки",
        Position = 2,
        ValueFromPipeLine = $false)]
        [int]$lev
        
    )
    [array]$groups = @()
    $count2 = 0
    $count3 = 0

    if($lev -eq 1) {
        $groups = (Get-ADGroup -SearchBase $OU_parent -Filter * -SearchScope 1).SamAccountName
        Write-Host "Группы 1L в Active Directory мы не задаем.."
        return -1

    } elseif ($lev -eq 2) {
        $OU_parent_2 = 'OU='+$PathGroup[-1]+','+$OU_parent
        # Обработка символа плюса
        if ($OU_parent_2 -match '\+') { $OU_parent_2 = $OU_parent_2 -replace '\+','\+' }
        # Создание OU папки если вдруг его нет
        do {
            $res = CheckPathOU -OU $OU_parent_2 -server $server -PathGroup $PathGroup
            if($($res.Gettype().BaseType.Name) -eq 'Array') {$res = $res[-1] }
            # отсутствие папки ou в AD
            if($res -eq 0) {
                Make_OU -OU $OU_parent_2 -server $server -PathGroup $PathGroup
                
            }
            $count2++
            if($count2 -gt 2) {break}
        } while ($res -ne 1)


        if($res -eq 1) {
            try {
                $groups = (Get-ADGroup -SearchBase $OU_parent_2 -Filter * -SearchScope 1).SamAccountName 
            } catch [System.Security.Authentication.AuthenticationException] {
                Write-Host $($Error[0].Exception.Message) -ForegroundColor Red
                return 0
            }  catch {
                Write-Host "Other Error:" -NoNewline
                Write-Host $($Error[0].Exception.Message) -ForegroundColor Red
                Write-Host "Этой группы нет, будем создавать"
                return 0
            }

            foreach($g in $groups) {
                if($g -eq $gr_tmp) {
                    Write-Host "Группа 2L в Active Directory существует:" $g
                    Write-Host
                    return 1
                }
            }
            Write-Host "Группы 2L в Active Directory НЕТ..:( будем создавать"
            Write-Host
            return 0
        }         
    return 0
      
    
    } elseif ($lev -eq 3) {
        $OU_parent_3 = 'OU='+$PathGroup[-1]+','+'OU='+$PathGroup[-2]+','+$OU_parent
        # Обработка символа плюса
        if ($OU_parent_3 -match '\+') { $OU_parent_3 = $OU_parent_3 -replace '\+','\+' }
        # Создание OU папки если вдруг его нет
        do {
            $res = CheckPathOU -OU $OU_parent_3 -server $server -PathGroup $PathGroup
            if($($res.Gettype().BaseType.Name) -eq 'Array') {$res = $res[-1] }

            if($res -eq 0) {
                Make_OU -OU $OU_parent_3 -server $server -PathGroup $PathGroup
                
            }
            $count3++
            if($count3 -gt 2) {break}
        } while ($res -ne 1)
            

        if($res -eq 1) {
            try {
                $groups = (Get-ADGroup -SearchBase $OU_parent_3 -Filter * -SearchScope 1).SamAccountName
            } catch [System.Security.Authentication.AuthenticationException] {
                Write-Host $($Error[0].Exception.Message) -ForegroundColor Red
		        return 0
            }  catch {
                Write-Host "Other Error:" -NoNewline
                Write-Host $($Error[0].Exception.Message) -ForegroundColor Red
                Write-Host "Этой группы нет, будем создавать"
                return 0
            }
            
            foreach($g in $groups) {
                if($g -eq $gr_tmp) {
                    Write-Host "Группа 3L в Active Directory существует:" $g
                    return 1
                } 
            }
            Write-Host "Группы 3L в Active Directory НЕТ..:( будем создавать"
            return 0
        } 
    return 0
    }

} # функция проверяющее имя группы, если оно есть в OU контейнера


# функция создающая имя группы 3 левела
function CreateNameGroup3L {
    Param(
        [Parameter(Mandatory = $true,
		HelpMessage="Массив содержимого пути",
		Position = 0,
		ValueFromPipeLine = $false)]
		[Array]$PathGroup,

        [Parameter(Mandatory = $true,
		HelpMessage="RWFV status",
		Position = 1,
		ValueFromPipeLine = $false)]
		[int]$Perm
    )
# Ограничим название группы по определнному критерию
[string]$Name1L_tmp = $($pathGroup[2])
[string]$Name2L_tmp = $($pathGroup[$pathGroup.Count-2])
[string]$Name3L_tmp = $($pathGroup[$pathGroup.Count-1])

if($pathGroup[2].Length -gt 16) {
    $Name1L_tmp = $($pathGroup[2]).Substring(0,16)
}
if($($pathGroup[$pathGroup.Count-2]).Length -gt 20) {
    $Name2L_tmp = $($pathGroup[$pathGroup.Count-2]).Substring(0,20)
}
if($($pathGroup[$pathGroup.Count-1]).Length -gt 20) {
    $Name3L_tmp = $($pathGroup[$pathGroup.Count-1]).Substring(0,20)
}

#[string]$twoLevelName =  $($pathGroup[2]).Substring(0,4).ToLower()
$gr_tmp = "FS-"+$Name1L_tmp+"-"+$Name2L_tmp+"-"+$Name3L_tmp
# Имеется ограничение на длинну имени группы 64 символа
if($gr_tmp.Length -gt 62) {
    $gr_tmp = $gr_tmp.Substring(0,62)	
}
$gr_tmp = $gr_tmp -replace '[/|\\|\+|:|\?|\*|\№]', '_'

switch($Perm) {
	
    0 { $gr_tmp = $gr_tmp + "-L";    
        return $gr_tmp;
    }
    1 { $gr_tmp = $gr_tmp + "-R";
        return $gr_tmp;
    }
    2 { $gr_tmp = $gr_tmp + "-W";
        return $gr_tmp;
    }
    3 { $gr_tmp = $gr_tmp + "-F";
        return $gr_tmp;
    }
}	

} # функция создающая имя группы 3 левела


# функция создающая имя групп 2 левела
function CreateNameGroup2L {
    Param(
        [Parameter(Mandatory = $true,
		HelpMessage="Массив содержимого пути",
		Position = 0,
		ValueFromPipeLine = $false)]
		[Array]$PathGroup,

        [Parameter(Mandatory = $true,
		HelpMessage="RWFV status",
		Position = 1,
		ValueFromPipeLine = $false)]
		[int]$Perm
    )

# Ограничим название группы по определнному критерию
[string]$Name1L_tmp = $($pathGroup[$pathGroup.Count-2])
[string]$Name2L_tmp = $($pathGroup[$pathGroup.Count-1])

if($($pathGroup[$pathGroup.Count-2]).Length -gt 16) {
    $Name1L_tmp =  $($pathGroup[$pathGroup.Count-2]).Substring(0,16)
}
if($($pathGroup[$pathGroup.Count-1]).Length -gt 20) {
    $Name2L_tmp = $($pathGroup[$pathGroup.Count-1]).Substring(0,20)
}

$gr_tmp = "FS-"+$Name1L_tmp+"-"+$Name2L_tmp
# Имеется ограничение на длинну имени группы 64 символа
if($gr_tmp.Length -gt 62) {
    $gr_tmp = $gr_tmp.Substring(0,62)	
}
$gr_tmp = $gr_tmp -replace '[/|\\|\+|:|\?|\*|\№]', '_'

switch($Perm) {
	
    0 { $gr_tmp = $gr_tmp + "-L";    
        return $gr_tmp;
    }
    1 { $gr_tmp = $gr_tmp + "-R";
        return $gr_tmp;
    }
    2 { $gr_tmp = $gr_tmp + "-W";
        return $gr_tmp;
    }
    3 { $gr_tmp = $gr_tmp + "-F";
        return $gr_tmp;
    }
}	

} # функция создающая имя групп 2 левела

function CreateGroup{
    Param(
        [Parameter(Mandatory = $true,
		HelpMessage="Массив содержимого пути",
		Position = 0,
		ValueFromPipeLine = $false)]
		[Array]$PathGroup,
            
        [Parameter(Mandatory = $true,
        HelpMessage="Server Active Directory",
        Position = 1,
        ValueFromPipeLine = $false)]
        [String]$Server,

        [Parameter(Mandatory = $true,
        HelpMessage="уровень папки",
        Position = 2,
        ValueFromPipeLine = $false)]
        [int]$lev,

        [Parameter(Mandatory = $true,
        HelpMessage="RWFV status",
        Position = 2,
        ValueFromPipeLine = $false)]
        [int]$Perm
         
    )
    $Error.Clear()
    # строковое имя группы
    [string]$gr_tmp = $null

    # получим OU родительской папки
    [string]$OU_parent = GetOU_Parent -PathGroup $PathGroup

    # выбор создания имени папки по уровню
    if($lev -eq 2) {
        # формирование имени группы для 2L
        $gr_tmp = CreateNameGroup2L -PathGroup $PathGroup -Perm $Perm

        # Проверка существования группы
        $Ch_res = CheckGroup -OU_parent $OU_parent -gr_tmp $gr_tmp -PathGroup $PathGroup -lev $lev
        # приведем к нужному значению
        if($($Ch_res.Gettype().BaseType.Name) -eq 'Array') {$Ch_res = $Ch_res[-1] }

        if($Ch_res -eq 1) {
            $grCurrent = Get-ADGroup -Identity $gr_tmp -Server $server;
            return $grCurrent
        } elseif ($Ch_res -eq 0) {
            write-host "Будем запускать функцию создания группы 2L"
            # получим текущий OU 
            $current_ou = GetOU -OU_parent $OU_parent -PathGroup $PathGroup -lev $lev
            
            $grCurrent = CreateGroupAD -OU $current_ou -gr_tmp $gr_tmp -Server $Server -PathGroup $PathGroup
            return $grCurrent

        } elseif ($Ch_res -eq -1) {
            # Запустим исключение
            #trow
        }


    } elseif ($lev -ge 3) {
        $gr_tmp = CreateNameGroup3L -PathGroup $PathGroup -Perm $Perm

        # Проверка существования группы
        $Ch_res = CheckGroup -OU_parent $OU_parent -gr_tmp $gr_tmp -PathGroup $PathGroup -lev $lev
        # приведем к нужному значению
        if($($Ch_res.Gettype().BaseType.Name) -eq 'Array') {$Ch_res = $Ch_res[-1] }
        
        if($Ch_res -eq 1) {
            $grCurrent = Get-ADGroup -Identity $gr_tmp -Server $server;
            return $grCurrent
        } elseif ($Ch_res -eq 0) {
            write-host "Будем запускать функцию создания группы 3L"
            # получим текущий OU 
            $current_ou = GetOU -OU_parent $OU_parent -PathGroup $PathGroup -lev $lev
            
            $grCurrent = CreateGroupAD -OU $current_ou -gr_tmp $gr_tmp -Server $Server -PathGroup $PathGroup
            return $grCurrent
        }
    }


    
}
<#
ОСНОВНАЯ ФУНКЦИЯ
функция запускает все основные процессы для работы программы 
#>
function Main {
    Param(
    [Parameter(Mandatory = $true,
            HelpMessage="Full path to target folder",
            ValueFromPipeLine = $false,
            Position = 0)]
            [String]$Path,
        
            [Parameter(Mandatory = $true,
            HelpMessage="Account name with format id_name\SamAccountName",
            Position = 1,
            ValueFromPipeLine = $false)]
            [string]$Account,
            
            [Parameter(Mandatory = $true,
            HelpMessage="Server Active Directory",
            Position = 2,
            ValueFromPipeLine = $false)]
            [String]$Server,

            [Parameter(Mandatory = $true,
            HelpMessage="Manager can update membership list",
            Position = 3,
            ValueFromPipeLine = $false)]
            [bool]$CheckBoxManaged
            
    )
    Write-Host "Library....... start"
    [int]$rr = 1
    $global:f1970 = 1
    
    # проверка переданных аргументов
    foreach($item in $PSBoundParameters.Keys) {
        if($null -eq $PSBoundParameters[$item]) {
            Write-Host  $item "argument required !!!" -ForegroundColor Red
            return 0
        } else {
            $msg = 'Key {0} | Value {1}' -f $item,$PSBoundParameters[$item]
        }
        # Строка для вывода передоваемых аргументов
        Write-host $msg
    } # проверка переданных аргументов
    
    
    # проверка существования папки на которую будут заданы права
    if (-not (Test-Path $Path)) {
        Write-Error "$Path is not exist. It should be defined before procedure"
        return 0
    }
    
    # Создадим массив элементов $path
    [array]$pathGroup = @()
    $pathGroup = ($path -replace '^\\.','' ).Split('\')
    
    # Уровень (Левел) папки, что в есть в $path
    [int]$lev = GetLevelDir -Path $path
    Write-Host
   
    # массив для создания групп
    $gr = @{}
          
    if($lev -eq 2) {
        $gr0 = CreateGroup -PathGroup $pathGroup -Server $Server -lev $lev -Perm 0 
        # добавим поля в объект
            $FSR = [System.Security.AccessControl.FileSystemRights]'Read,ExecuteFile,ListDirectory'
            $inhr = [System.Security.AccessControl.InheritanceFlags]'ContainerInherit'
            $prop = [system.security.accesscontrol.PropagationFlags]'None'
            $access = [System.Security.AccessControl.AccessControlType]'Allow'
            $gr0 | Add-Member -NotePropertyName "FSR" -NotePropertyValue $FSR -Force
            $gr0 | Add-Member -NotePropertyName "INHR" -NotePropertyValue $inhr -Force
            $gr0 | Add-Member -NotePropertyName "PROP" -NotePropertyValue $prop -Force
            $gr0 | Add-Member -NotePropertyName "ACCESS" -NotePropertyValue $access -Force
            $FSR,$inhr,$prop,$access = $null

        $gr1 = CreateGroup -PathGroup $pathGroup -Server $Server -lev $lev -Perm 1
            # добавим поля в объект
            $FSR = [System.Security.AccessControl.FileSystemRights]'Read,ExecuteFile,ListDirectory'
            $inhr = [System.Security.AccessControl.InheritanceFlags]'ContainerInherit,ObjectInherit'
            $prop = [system.security.accesscontrol.PropagationFlags]'None'
            $access = [System.Security.AccessControl.AccessControlType]'Allow'
            $gr1 | Add-Member -NotePropertyName "FSR" -NotePropertyValue $FSR -Force
            $gr1 | Add-Member -NotePropertyName "INHR" -NotePropertyValue $inhr -Force
            $gr1 | Add-Member -NotePropertyName "PROP" -NotePropertyValue $prop -Force
            $gr1 | Add-Member -NotePropertyName "ACCESS" -NotePropertyValue $access -Force
            $FSR,$inhr,$prop,$access = $null

        $gr2 = CreateGroup -PathGroup $pathGroup -Server $Server -lev $lev -Perm 2
           # добавим поля в объект
           $FSR = [System.Security.AccessControl.FileSystemRights]'Read,ExecuteFile,ListDirectory,Modify,Delete'
           $inhr = [System.Security.AccessControl.InheritanceFlags]'ContainerInherit,ObjectInherit'
           $prop = [system.security.accesscontrol.PropagationFlags]'None'
           $access = [System.Security.AccessControl.AccessControlType]'Allow'
           $gr2 | Add-Member -NotePropertyName "FSR" -NotePropertyValue $FSR -Force
           $gr2 | Add-Member -NotePropertyName "INHR" -NotePropertyValue $inhr -Force
           $gr2 | Add-Member -NotePropertyName "PROP" -NotePropertyValue $prop -Force
           $gr2 | Add-Member -NotePropertyName "ACCESS" -NotePropertyValue $access -Force
           $FSR,$inhr,$prop,$access = $null

        $gr3 = CreateGroup -PathGroup $pathGroup -Server $Server -lev $lev -Perm 3
            # добавим поля в объект
           $FSR = [System.Security.AccessControl.FileSystemRights]'FullControl'
           $inhr = [System.Security.AccessControl.InheritanceFlags]'ContainerInherit,ObjectInherit'
           $prop = [system.security.accesscontrol.PropagationFlags]'None'
           $access = [System.Security.AccessControl.AccessControlType]'Allow'
           $gr3 | Add-Member -NotePropertyName "FSR" -NotePropertyValue $FSR -Force
           $gr3 | Add-Member -NotePropertyName "INHR" -NotePropertyValue $inhr -Force
           $gr3 | Add-Member -NotePropertyName "PROP" -NotePropertyValue $prop -Force
           $gr3 | Add-Member -NotePropertyName "ACCESS" -NotePropertyValue $access -Force
           $FSR,$inhr,$prop,$access = $null

    } elseif ($lev -ge 3) {
        $gr1 = CreateGroup -PathGroup $pathGroup -Server $Server -lev $lev -Perm 1
            # добавим поля в объект
            $FSR = [System.Security.AccessControl.FileSystemRights]'Read,ExecuteFile,ListDirectory'
            $inhr = [System.Security.AccessControl.InheritanceFlags]'ContainerInherit,ObjectInherit'
            $prop = [system.security.accesscontrol.PropagationFlags]'None'
            $access = [System.Security.AccessControl.AccessControlType]'Allow'
            $gr1 | Add-Member -NotePropertyName "FSR" -NotePropertyValue $FSR -Force
            $gr1 | Add-Member -NotePropertyName "INHR" -NotePropertyValue $inhr -Force
            $gr1 | Add-Member -NotePropertyName "PROP" -NotePropertyValue $prop -Force
            $gr1 | Add-Member -NotePropertyName "ACCESS" -NotePropertyValue $access -Force
            $FSR,$inhr,$prop,$access = $null
        $gr2 = CreateGroup -PathGroup $pathGroup -Server $Server -lev $lev -Perm 2
            # добавим поля в объект
            $FSR = [System.Security.AccessControl.FileSystemRights]'Read,ExecuteFile,ListDirectory,Modify,Delete'
            $inhr = [System.Security.AccessControl.InheritanceFlags]'ContainerInherit,ObjectInherit'
            $prop = [system.security.accesscontrol.PropagationFlags]'None'
            $access = [System.Security.AccessControl.AccessControlType]'Allow'
            $gr2 | Add-Member -NotePropertyName "FSR" -NotePropertyValue $FSR -Force
            $gr2 | Add-Member -NotePropertyName "INHR" -NotePropertyValue $inhr -Force
            $gr2 | Add-Member -NotePropertyName "PROP" -NotePropertyValue $prop -Force
            $gr2 | Add-Member -NotePropertyName "ACCESS" -NotePropertyValue $access -Force
            $FSR,$inhr,$prop,$access = $null
    }
   
    $gr.View0 = $gr0
    $gr.Read0 = $gr1
    $gr.Write0 = $gr2
    $gr.Full0 = $gr3
    
    if(-not ($null -eq $gr.View0)) {
        Add-Members1 -HashGr $gr -Server $Server -PathGroup $PathGroup

    } else {
        Add-Members3 -HashGr $gr -Server $Server -PathGroup $PathGroup
    }


    Write-Host
    write-host "--- НАЧИНАЕМ ПРОВЕРЯТЬ и УСТАНАВЛИВАТЬ ПРАВА ---"
    Write-Host
    # Для начала создадим объект acl_rule_folder_nodel что предатврятить удаление папки
    # Передадим его в функцию Get-Permission , хоть по названию она не подходит но тут более логичнее ее вставить
    [int32]$cultura=0
    $cultura=(Get-Host).CurrentUiCulture.LCID
    if ($cultura -eq 1033) {
        [object]$acl_rule_folder_nodel=New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone","delete, Synchronize","none", "NoPropagateInherit", "Deny")
    } elseif ($cultura -eq 1049) {
        [object]$acl_rule_folder_nodel=New-Object System.Security.AccessControl.FileSystemAccessRule("Все","delete, Synchronize","none", "NoPropagateInherit", "Deny") 
    } else {
        Write-Host "Текущий язык окружения не определен используеться ENG or RU"
        $acl_rule_folder_nodel = 0
    }

    # Проверяем назначены ли права на папку данной группе
    foreach($g in $gr.Keys) {
        if($null -eq $gr[$g]) { continue }
        $resPr =  Get-Permission -path $Path -gr_tmp $gr[$g] -server $Server -acl_rule_folder_nodel $acl_rule_folder_nodel
        if($resPr -eq 1) {
            Write-Host "Права $($gr[$g].Name) на $path выставлены корректно.."
            continue

        } elseif($resPr -eq 2) {
            Write-Host "Права $($gr[$g].Name) на $path ОТСУТСТВУЮТ..."

        } elseif ($resPr -eq 2) {
            Write-Host "Права $($gr[$g].Name) на $path выставлены НЕ корректно..."
        }
        Write-Host "!!! ВЫСТАВЛЯЕМ ПРАВА !!!"
        
        # Выставим права на папку 
        Set-Permission -path $Path -gr_tmp $gr[$g]

    }

    # Добавим Owner(a) на папку
    SetOwner -path $Path -Account $Account -Server $Server -Hashgr $gr

    # Проверим присутствие группы FS Admins при настройке 3L
    if($null -eq $gr.View0) {
        SetFSAdmins  -HashGr $gr -Server $Server -PathGroup $pathGroup
    }

    # Разрешения для папок DFS используются только для отображения или скрытия папок DFS, а не для управления доступом
    # Проверим и установим если нет
    AddStealth -HashGr $gr -PathGroup $PathGroup

    # Проверка на включеную галку в Managed By (Если $CheckBoxManaged = $false, не будет работать)
    # включение её для NetworkFoldersManagers
    # Manager can update membership list
    if($CheckBoxManaged) {
        Write-Host
        Write-Host "Начинаем проверять ChackBox: Manager can update membership list.."
        Write-Host
        AddCheckBox2 -HashGr $gr -Server $Server
    }



    Write-Host "Library...... end"
     
    
    
    $global:f1970 = 0
    return  $gr
    }

    # функция получает количество елементов и формирующее левел папки

function GetLevelDir {
    Param(
    [Parameter(Mandatory = $true,
    HelpMessage="Full path to target folder",
    ValueFromPipeLine = $false,
    Position = 0)]
    [String]$Path
 
)
[array]$pathGroup_tmp= @()
$pathGroup_tmp = ($path -replace '^\\.','' ).Split('\')
    
if($PathGroup.Count -eq 2) {
	[int]$lev_tmp = 0
	Write-Host "Левел папки:"  $lev_tmp
	return $lev_tmp
} elseif ($PathGroup.Count -eq 3) {
	[int]$lev_tmp = 1
	Write-Host "Левел папки:"  $lev_tmp
	return $lev_tmp
} elseif ($PathGroup.Count -eq 4) {
	[int]$lev_tmp = 2
	Write-Host "Левел папки:"  $lev_tmp
    return $lev_tmp
}elseif ($PathGroup.Count -eq 5) {
    [int]$lev_tmp = 3
    Write-Host "Левел папки:"  $lev_tmp
    return $lev_tmp
} else {
	write-host "Левел папки вышел за рамки допустимого:" $PathGroup.Count -ForegroundColor Red
	Exit
}


} # функция получает количество елементов и формирующее левел папки
function CreateGroupAD{
    Param(
        [Parameter(Mandatory = $true,
        HelpMessage="OU текущей папки",
		Position = 0,
		ValueFromPipeLine = $false)]
		[string]$OU,

        [Parameter(Mandatory = $true,
        HelpMessage="Создаваемая группа",
        Position = 1,
        ValueFromPipeLine = $false)]
        [String]$gr_tmp,
            
        [Parameter(Mandatory = $true,
        HelpMessage="Server Active Directory",
        Position = 2,
        ValueFromPipeLine = $false)]
        [String]$Server,
        
        [Parameter(Mandatory = $true,
		HelpMessage="Массив содержимого пути",
		Position = 3,
		ValueFromPipeLine = $false)]
		[Array]$PathGroup

    )
# Создадим дискрипшн для группы
[string]$discr = '\\'
for($i=0; $i -lt $PathGroup.Count; $i++ ) {
	$discr += $($PathGroup[$i]+'\')
}
$discr = $discr.TrimEnd('\')

$Error.Clear()
try {
    # Будем создавать группу в AD
    Write-Host "Будем создавать группу в AD:" $gr_tmp
    New-ADGroup "$gr_tmp" -Path $OU -GroupCategory Security -GroupScope DomainLocal -Description $discr -Server $server -ManagedBy "CN=NetworkFoldersManagers,OU=Service accounts,DC=ie,DC=corp" 
        #-Credential $cred 

        Start-Sleep 15
        $grrC = Get-ADGroup "$gr_tmp" -Server $server
        Write-Host "SID групп:" $grrC.SID
        Write-Host
        if ($grrC.distinguishedName) {$flag_grr = 1} # не решил , что с этим делать
    } catch {
    Write-Host "Не могу создать группу $gr_tmp в контейнере $Full_ou";
    Write-Host $Error[0].Exception.Message -ForegroundColor Red
    Write-Host ""
}
return $grrC
} # функция получает количество елементов и формирующее левел папки

# # Добавление групп 2L в родительскую группу 1L (уровня) и в своих 2R2W2F-> 2L
function Add-Members1 {
    Param(
        [Parameter(Mandatory = $false,
        HelpMessage="Добавляемая группа или пользователь Distinquished Name",
        ValueFromPipeLine = $false,
        Position = 0)]
        [hashtable]$HashGr = $null,
    
        [Parameter(Mandatory = $false,
        HelpMessage="Сервер",
        ValueFromPipeLine = $false,
        Position = 1)]
        [String]$Server,
        
        [Parameter(Mandatory = $true,
		HelpMessage="Массив содержимого пути",
		Position = 2,
		ValueFromPipeLine = $false)]
		[Array]$PathGroup
    )

    #получим родительскую OU папки
    $OU_parent = GetOU_Parent -PathGroup $PathGroup
    # получим группу в Родительской папке
    [array]$groups = (Get-ADGroup -SearchBase $OU_parent -Filter * -SearchScope 1)
    foreach($g in $groups) {
        if($g.SamAccountName -match  $($PathGroup[2]+'-L')) {
            [string]$gr_parent = $g.SamAccountName
            break
        }
    }
    Write-Host "Родительская группа:" $gr_parent
      
try {
    [array]$grr = Get-ADGroupMember -Identity $gr_parent -Server $Server 
    #-Credential $cred
} catch {
	Write-Host "can't accept memebers from:" $gr_parent
    exit
}

foreach($item in $HashGr.Keys) {
    [bool]$G_view0_b = $false
    [bool]$G_All0_b = $false
    if('View0' -eq $item) {
        Write-Host  $item "key found !!!" -ForegroundColor Red
    
        foreach( $gg in $grr ) {
            if( $gg.SamAccountName -eq $HashGr[$item].SamAccountName ) {
                Write-Host "$($HashGr[$item].SamAccountName) является членом группы $gr_parent"
                $G_view0_b = $true
                break
            }
        }
        if(-not $G_view0_b){
            Add-ADGroupMember -Identity $gr_parent -Members $($HashGr[$item].SamAccountName) -Server $server
            
            Write-host "##################################################"
            Write-Host "Группа $($HashGr[$item].SamAccountName) добавлена в Members $gr_parent" 
            Write-Host
        }
    
    } elseif (('Read0' -eq $item) -or ('Write0' -eq $item) -or ('Full0' -eq $item)) {
        
        try {
            [array]$grr2L = Get-ADGroupMember -Identity $($HashGr.View0.SamAccountName) -Server $Server 
            #-Credential $cred
        } catch {
            Write-Host "can't accept memebers from:" $($HashGr.View0.SamAccountName)
            exit
        }

        if($grr2L.Count -gt 0) {
            foreach( $gg2 in $grr2L ) {
                if( $gg2.SamAccountName -eq $HashGr[$item].SamAccountName ) {
                    Write-Host "$($HashGr[$item].SamAccountName) является членом группы $gr_parent"
                    $G_All0_b = $true
                    break
                }
            }
            if(-not $G_All0_b) {
                Add-ADGroupMember -Identity $($HashGr.View0.SamAccountName) -Members $($HashGr[$item].SamAccountName) -Server $server
                Write-host "##################################################"
                Write-Host "Группа $($HashGr[$item].SamAccountName) добавлена в Members $($HashGr.View0.SamAccountName)" 
                Write-Host
            }

        } else {
            Add-ADGroupMember -Identity $($HashGr.View0.SamAccountName) -Members $($HashGr[$item].SamAccountName) -Server $server
            #Add-ADGroupMember -Identity $($HashGr.View0.SamAccountName) -Members $($HashGr.Write0.SamAccountName) -Server $server
            #Add-ADGroupMember -Identity $($HashGr.View0.SamAccountName) -Members $($HashGr.Full0.SamAccountName) -Server $server
            Write-host "##################################################"
            #Write-Host "Группы $($HashGr.Read0.SamAccountName), $($HashGr.Write0.SamAccountName), $($HashGr.Full.SamAccountName)  добавлены в Members $($HashGr.View0.SamAccountName)" 
            Write-Host "Группы $($HashGr[$item].SamAccountName)  добавлены в Members $($HashGr.View0.SamAccountName)" 
            Write-Host
        }

    }        


} 
} # Добавление групп 2L в родительскую группу 1L (уровня) и в своих 2R2W2F-> 2L

# Добавление групп 3L в 2L (уровня) 3R3W-> 2L
function Add-Members3 {
    Param(
        [Parameter(Mandatory = $false,
        HelpMessage="Добавляемая группа или пользователь Distinquished Name",
        ValueFromPipeLine = $false,
        Position = 0)]
        [hashtable]$HashGr = $null,
    
        [Parameter(Mandatory = $false,
        HelpMessage="Сервер",
        ValueFromPipeLine = $false,
        Position = 1)]
        [String]$Server,
        
        [Parameter(Mandatory = $true,
		HelpMessage="Массив содержимого пути",
		Position = 2,
		ValueFromPipeLine = $false)]
		[Array]$PathGroup
    )

    [string]$group_LevUp = $null

    foreach($item in $HashGr.Keys) {
        # пропустим пустые ключи
        if($null -eq $HashGr[$item]) { continue }
        [bool]$G_2Lev = $false
        # найдем имя группу предыдущего уровня
        if([string]::IsNullOrEmpty($group_LevUp)) {
            $OU_LevUP = $($HashGr[$item].DistinguishedName) -replace '^CN=.*?,'
            $OU_LevUP = $OU_LevUP -replace '^.*?,'    
            [array]$g2roups = (Get-ADGroup -SearchBase $OU_LevUP -Filter * -SearchScope 1)
            # изменение 18.10.2021
            [string]$ograniсh = $null
            if($($pathGroup[-2]).Length -gt 20) {
                $ograniсh = $($PathGroup[-2]).Substring(0,20)
            } else {
                $ograniсh = $($PathGroup[-2])
            }
            [string]$proverka = $ograniсh+'-L'
            foreach($g2 in $g2roups) {
                if($g2.SamAccountName -match $proverka) {
                    $group_LevUp = $g2.SamAccountName
                    break
                }
            }
        }

        try {
            # Дописать получение группы 2L View SamAccountName
            
            [array]$grr2L = Get-ADGroupMember -Identity $group_LevUp -Server $Server 
            #-Credential $cred
        } catch {
            Write-Host "can't accept memebers from:" $group_LevUp
            exit
        }

        if($grr2L.Count -gt 0) {
            foreach( $gg2 in $grr2L ) {
                if( $gg2.SamAccountName -eq $HashGr[$item].SamAccountName ) {
                    Write-Host "$($HashGr[$item].SamAccountName) является членом группы $group_LevUp"
                    $G_2Lev = $true
                    break
                }
            }
            if(-not $G_2Lev) {
                Add-ADGroupMember -Identity $group_LevUp -Members $($HashGr[$item].SamAccountName) -Server $server
                Write-host "##################################################"
                Write-Host "Группа $($HashGr[$item].SamAccountName) добавлена в Members $group_LevUp" 
                Write-Host
            }

        } else {
            Add-ADGroupMember -Identity $group_LevUp -Members $($HashGr[$item].SamAccountName) -Server $server
            Write-host "##################################################"
            Write-Host "Группы $($HashGr[$item].SamAccountName)  добавлены в Members $group_LevUp" 
            Write-Host
        }
    
    }

} # Добавление групп 3L в 2L (уровня) 3R3W-> 2L

# Функция проверки прав на папке
function Get-Permission {
    Param(
        [Parameter(Mandatory = $true,
        HelpMessage="Полный путь к директории для которой формируем группы. Прим I:\IESK-F-OIR",
        ValueFromPipeLine = $false,
        Position = 0)]
        [string]$path,
        
        [Parameter(Mandatory = $true,
        HelpMessage="Объект группы",
        Position = 1,
        ValueFromPipeLine = $false)]
        [Microsoft.ActiveDirectory.Management.ADGroup]$gr_tmp,
         
        [Parameter(Mandatory = $true,
        HelpMessage="Сервер на котором находится группа",
        Position = 2,
        ValueFromPipeLine = $false)]
        [string]$server,
        
        [Parameter(Mandatory = $false,
        HelpMessage="Объект правила NO DEL Folder",
        Position = 3,
        ValueFromPipeLine = $false)]
        [System.Security.AccessControl.FileSystemAccessRule]$acl_rule_folder_nodel
    )

    $acl = Get-Acl -Path $path

    # долго не мог придумать куда данную фичу запихать в конце концов остановился тут
    # проверим сущестует ли правило в объектe $acl.Access по защите от удаления папки
    # $acl_rule_folder_nodel
    Write-Host "Проверим Защиту папки от удаления. $path"
    
    if(($acl.Access[0].FileSystemRights -ne $acl_rule_folder_nodel.FileSystemRights) -and ($acl_rule_folder_nodel -ne 0 )) {
        Write-Host "Отсутвует защита от удаления папки..включим её.."
        $acl.AddAccessRule($acl_rule_folder_nodel)
	    $acl | Set-Acl -Path $path
        
        Write-Host "Проверим применение защиты от удаления."
        Start-Sleep 3
        $acl = $null
        $acl = Get-Acl -Path $path
    }
    
    if(($acl.Access[0].FileSystemRights -eq $acl_rule_folder_nodel.FileSystemRights)) {
        Write-Host "Защита имеется идем дальше.."
        Write-Host
    }
    ## $acl_rule_folder_nodel

    # 32 битное число со снятым 20 битом, что бы исключить из сравнения Syncronize флаг
	$z = -1048577

    foreach( $a in $acl.Access ) {
		$sn = [string]$a.IdentityReference
		$k = $sn.indexof("\")
		$sn = $sn.substring($k+1)
		if( $sn -eq [string]$gr_tmp.sAmaccountName ){
			# Группа присутствует 
			$aa = $a.FileSystemRights
            $aa.value__ = $aa.value__ -band (-1048577)
            $perm = $gr_tmp.FSR
			$perm.value__ = $gr_tmp.FSR -band (-1048577)
            if( -not ($perm -eq $aa ) ) {
				Write-Host "$($gr_tmp.Name) имеет не корректные права на папку $path"
				return 0;
			}
			if( -not ($gr_tmp.INHR -eq $a.InheritanceFlags) ) {
				Write-Host "$($gr_tmp.Name) имеет не корректное наследование на папке $path"
				return 0;
			}
			if( -not ($gr_tmp.PROP -eq $a.PropagationFlags) ) {
				Write-Host "$($gr_tmp.Name) имеет не корректное распространение на дочерние папки $dir"
				return 0;
			}
            Write-Host "Права для группы $($gr_tmp.Name) на папке $path заданы правильно"
		    return 1
        
        }
    }

    Write-Host "Права для группы | $($gr_tmp.Name) | на папке $path НЕ заданы."
    return 2



} # Функция проверки прав на папке 

# Функция наложения прав на папку
function Set-Permission {
    Param(
        [Parameter(Mandatory = $true,
            HelpMessage="Полный путь к директории для которой формируем группы. Прим I:\IESK-F-OIR",
            ValueFromPipeLine = $false,
            Position = 0)]
            [string]$path,
            
            [Parameter(Mandatory = $true,
            HelpMessage="Префикс для директории. Прим. I:",
            ValueFromPipeLine = $false,
            Position = 1)]
            [Microsoft.ActiveDirectory.Management.ADGroup]$gr_tmp
    )


    Add-NTFSAccess -Path $path -Account $gr_tmp.SID -AccessRights $gr_tmp.FSR -InheritanceFlags $gr_tmp.INHR
    Write-Host "Права на папку $path установлны..: | $($gr_tmp.Name) |"
    # включим наследование верхних групп
    Enable-NTFSAccessInheritance -path $path
    Write-Host


} # Функция наложения прав на папку

# Функция Владельца папки + FS Admin 2L
function SetOwner {
    param (
        [Parameter(Mandatory = $true,
        HelpMessage="Полный путь к директории для которой формируем группы. Прим I:\IESK-F-OIR",
        ValueFromPipeLine = $false,
        Position = 0)]
        [string]$path,

        [Parameter(Mandatory = $true,
        HelpMessage="Account name with format id_name\SamAccountName",
        Position = 1,
        ValueFromPipeLine = $false)]
        [string]$Account,
            
        [Parameter(Mandatory = $true,
        HelpMessage="Server Active Directory",
        Position = 2,
        ValueFromPipeLine = $false)]
        [String]$Server,

        [Parameter(Mandatory = $false,
        HelpMessage="Добавляемая группа или пользователь Distinquished Name",
        ValueFromPipeLine = $false,
        Position = 3)]
        [hashtable]$HashGr = $null
    )

    # Добавим владельца в группу доступа
    # Если это 2L то в группц -W
    # Если 3L то в группу -W

    # 
    [string]$lev = GetLevelDir -Path $path
            
    try {
        [Microsoft.ActiveDirectory.Management.ADUser]$Account_tmp = Get-ADUser -Identity $Account
    } catch {
        write-host $Error[0].Exception.Message -ForegroundColor Red
        Write-Host "Account: $Account не получил данные с AD" : $Account_tmp.Name
    }
 
    if($lev -eq 2) {
        # FS Admins
        [string]$gr_fsadmins = 'fs_admins_'
        try {
            # Получим список групп, пользователей которые входят в группу Write (-W)
            [array]$gr_Ws = Get-ADGroupMember -Identity $HashGr.Write0.SamAccountName -Server $Server 
            
        } catch {
            Write-Host "can't accept memebers from:" $HashGr.Write0.SamAccountName
            exit
        }
        # для FS Admins 2L
        try {
            # Получим список групп, пользователей которые входят в группу Write (-F)
            [array]$gr_Fs = Get-ADGroupMember -Identity $HashGr.Full0.SamAccountName -Server $Server 
            
        } catch {
            Write-Host "can't accept memebers from:" $HashGr.Full0.SamAccountName
            exit
        } # для FS Admins 2L

        [bool]$Logic_W = $false
        [bool]$Logic_F = $false

        if($gr_Ws.Count -gt 0) {
            foreach( $g_W in $gr_Ws ) {
                if( $g_W.SamAccountName -eq $Account_tmp.SamAccountName ) {
                    Write-Host "$($Account_tmp.SamAccountName) является членом группы $($HashGr.Write0.SamAccountName)"
                    $Logic_W = $true
                    break
                }
            }
            if(-not $Logic_W) {
                Add-ADGroupMember -Identity $($HashGr.Write0.SamAccountName) -Members $($Account_tmp.SamAccountName) -Server $server
                Write-host "##################################################"
                Write-Host "Акаунт $($Account_tmp.SamAccountName) добавлен в Members " $($HashGr.Write0.SamAccountName)
                Write-Host
            }
        } else {
            Add-ADGroupMember -Identity $($HashGr.Write0.SamAccountName) -Members $($Account_tmp.SamAccountName) -Server $server
                Write-host "################################################## Нет мемберов в группе" $($HashGr.Write0.SamAccountName)
                Write-Host "Акаунт $($Account_tmp.SamAccountName) добавлен в Members " $($HashGr.Write0.SamAccountName)
                Write-Host
        
        }
        ### FS Admins 2L
        if($gr_Fs.Count -gt 0) {
            foreach( $g_F in $gr_Fs ) {
                if( $g_F.SamAccountName -eq $gr_fsadmins ) {
                    Write-Host "$gr_fsadmins является членом группы $($HashGr.Full0.SamAccountName)"
                    $Logic_F = $true
                    break
                }
            }
            if(-not $Logic_F) {
                Add-ADGroupMember -Identity $($HashGr.Full0.SamAccountName) -Members $gr_fsadmins -Server $server
                Write-host "##################################################"
                Write-Host "Акаунт $gr_fsadmins добавлен в Members " $($HashGr.Full0.SamAccountName)
                Write-Host
            }
        } else {
            Add-ADGroupMember -Identity $($HashGr.Full0.SamAccountName) -Members $gr_fsadmins -Server $server
                Write-host "################################################## Нет мемберов в группе" $($HashGr.Full0.SamAccountName)
                Write-Host "Акаунт $gr_fsadmins добавлен в Members " $($HashGr.Full0.SamAccountName)
                Write-Host
        
        }
        ### FS Admins 2L


                
    } elseif ($lev -eq 3) {
        
        try {
            # Получим список групп, пользователей которые входят в группу Write (-W)
            [array]$gr_Ws3 = Get-ADGroupMember -Identity $HashGr.Write0.SamAccountName -Server $Server 
            
        } catch {
            Write-Host "can't accept memebers from:" $HashGr.Write0.SamAccountName
            exit
        }

        [bool]$Logic_W3 = $false

        if($gr_Ws3.Count -gt 0) {
            foreach( $g_W3 in $gr_Ws3 ) {
                if( $g_W3.SamAccountName -eq $Account_tmp.SamAccountName ) {
                    Write-Host "$($Account_tmp.SamAccountName) является членом группы $($HashGr.Write0.SamAccountName)"
                    $Logic_W3 = $true
                    break
                }
            }
            if(-not $Logic_W3) {
                Add-ADGroupMember -Identity $($HashGr.Write0.SamAccountName) -Members $($Account_tmp.SamAccountName) -Server $server
                Write-host "##################################################"
                Write-Host "Акаунт $($Account_tmp.SamAccountName) добавлен в Members " $($HashGr.Write0.SamAccountName)
                Write-Host
            }
        } else {
            Add-ADGroupMember -Identity $($HashGr.Write0.SamAccountName) -Members $($Account_tmp.SamAccountName) -Server $server
                Write-host "################################################## Нет мемберов в группе" $($HashGr.Write0.SamAccountName)
                Write-Host "Акаунт $($Account_tmp.SamAccountName) добавлен в Members " $($HashGr.Write0.SamAccountName)
                Write-Host
        
        }
    
    } else {
        Write-Host "В назначении Owner не получилось определить уроветь папки" -ForegroundColor Red
    }
   
} # Функция Владельца папки + fs_admin_ 2L       

# Функция проверки и добаления группы fs_admins_
# входящая группа 3L проверяю 2L если там есть группа -F то добавляю
# если нет ошибка
function SetFSAdmins {
    param (
        [Parameter(Mandatory = $false,
        HelpMessage="Добавляемая группа или пользователь Distinquished Name",
        ValueFromPipeLine = $false,
        Position = 0)]
        [hashtable]$HashGr = $null,
    
        [Parameter(Mandatory = $false,
        HelpMessage="Сервер",
        ValueFromPipeLine = $false,
        Position = 1)]
        [String]$Server,
        
        [Parameter(Mandatory = $true,
		HelpMessage="Массив содержимого пути",
		Position = 2,
		ValueFromPipeLine = $false)]
		[Array]$PathGroup
    )
    
      
    [string]$gr_fsadmins = 'FS Admins'
    [string]$group_LevUp = $null

    [bool]$G_2Lev = $false

    foreach($item in $HashGr.Keys) {
        # проверка от лишних повторений
        if($G_2Lev) { break }
        # пропустим пустые ключи
        if($null -eq $HashGr[$item]) { continue }
        $G_2Lev = $false
        # найдем имя группу предыдущего уровня
        if([string]::IsNullOrEmpty($group_LevUp)) {
            $OU_LevUP = $($HashGr[$item].DistinguishedName) -replace '^CN=.*?,'
            $OU_LevUP = $OU_LevUP -replace '^.*?,'    
            [array]$g2roups = (Get-ADGroup -SearchBase $OU_LevUP -Filter * -SearchScope 1)
            # изменение 13.10.2021
            [string]$ograniсh = $null
            if($($pathGroup[-2]).Length -gt 20) {
                $ograniсh = $($PathGroup[-2]).Substring(0,20)
            } else {
                $ograniсh = $($PathGroup[-2])
            }
            [string]$proverka = $ograniсh+'-F'
            foreach($g2 in $g2roups) {
                if($g2.SamAccountName -match $proverka) {
                    $group_LevUp = $g2.SamAccountName
                    break
                }
            }
        }

        
        try {
            # Дописать получение группы 3L View SamAccountName
            
            [array]$grr2L = Get-ADGroupMember -Identity $group_LevUp -Server $Server 
            #-Credential $cred
        } catch {
            Write-Host "can't accept memebers from:" $group_LevUp
            write-host "Необходимо создать группу $proverka .." -ForegroundColor Red
            Write-Host "Поgытка записать группe FS Admmins не удачна " -ForegroundColor Red
            Write-Host
            
            exit
        }

        if($grr2L.Count -gt 0) {
            foreach( $gg2 in $grr2L ) {
                
                if( $gg2.SamAccountName -eq $gr_fsadmins ) {
                    Write-Host "$gr_fsadmins является членом группы $group_LevUp"
                    $G_2Lev = $true
                    break
                }
            }
            if(-not $G_2Lev) {
                Add-ADGroupMember -Identity $group_LevUp -Members $gr_fsadmins -Server $server
                Write-host "##################################################"
                Write-Host "Группа $gr_fsadmins добавлена в Members $group_LevUp" 
                Write-Host
            }

        } else {
            Add-ADGroupMember -Identity $group_LevUp -Members $gr_fsadmins -Server $server
            Write-host "##################################################"
            Write-Host "Группа $gr_fsadmins добавлены в Members $group_LevUp" 
            Write-Host
        }
    
    }        
    
} # Функция проверки и добаления группы fs_admins_

# отображения или скрытия папок DFS
function AddStealth {
    param (
        [Parameter(Mandatory = $false,
        HelpMessage="Добавляемая группа или пользователь Distinquished Name",
        ValueFromPipeLine = $false,
        Position = 0)]
        [hashtable]$HashGr = $null,    
    
        [Parameter(Mandatory = $true,
		HelpMessage="Массив содержимого пути",
		Position = 1,
		ValueFromPipeLine = $false)]
		[Array]$PathGroup
    )

    # формируем путь для работы с dfs access
    [string]$pathL2 = '\\'
    for($i=0; $i -lt 4; $i++ ) {
	    $pathL2 += $($PathGroup[$i]+'\')
    }
    $pathL2 = $pathL2.TrimEnd('\')
    
    # где расположен dfsutil.exe
    [string]$DFSU = 'C:\Windows\system32\dfsutil.exe'
    
    # --- найдем нужную нам группу 2levela --------------
    [string]$group_LevUp = $null

    
    foreach($item in $HashGr.Keys) {
        # пропустим пустые ключи
        if($null -eq $HashGr[$item]) { continue }
        [bool]$G_2Lev = $false
        # найдем имя группу предыдущего уровня
        if([string]::IsNullOrEmpty($group_LevUp)) {
            $OU_LevUP = $($HashGr[$item].DistinguishedName) -replace '^CN=.*?,'
            # ---- найдем сколько раз встречается OU= ------
            [array]$OUar = @()
            [int]$index = 0
            $OUar =  $OU_LevUP.Split(',')
            foreach($O in $OUar) {
	            if($O -match 'OU=') {
		            $index++
	            }
            }
            if($index -eq 5) { $OU_LevUP = $OU_LevUP -replace '^.*?,' }

            #----- найдем сколько раз встречается OU= ------
            # на нужна группа L из втрогого уровня OU должно быть 4 

            [array]$g2roups = (Get-ADGroup -SearchBase $OU_LevUP -Filter * -SearchScope 1)
            # поищим групп 2L 
            [string]$ograniсh = $null
            if($($PathGroup[3]).length -gt 20) {
                $ograniсh = $($PathGroup[3]).Substring(0,20)
            } else {
                $ograniсh = $($PathGroup[3])
            }
            [string]$proverka = $ograniсh+'-L'
            foreach($g2 in $g2roups) {
                if($g2.SamAccountName -match $proverka) {
                    $group_LevUp = $g2.SamAccountName
                    break
                }
            }
        }
   
    } #-----------------------------

    [string]$DFScmd = 'IE\'+$group_LevUp
    [string]$DFSroot = $pathL2
    [string]$ARG0 = "property SD grant `"" +$DFSroot+"`" `""+$DFScmd+"`":RX protect"
    $AC =  Get-DfsnAccess -Path $DFSroot
    if($null -eq $AC) {
        if(Test-Path $DFSU) {
            $Error.Clear()
            try {
                Start-Process -FilePath $DFSU -ArgumentList $ARG0 -WindowStyle Hidden
            }
            catch {
                write-host $($Error[0].Exception.Message) -ForegroundColor Red
                write-host "Не получилось установить сокрытие ресурса. Сделайте в DFS скрытие папок руками"
                write-host
            }
           
        } else {
            write-host "Не найден $DFSU"
            write-host "К сожелению Grant-DfsnAccess не может сделать то что нам нужно"
            write-host "мелкомягкие советуют использовать только dfsutil"
            write-host "Сделайте в DFS скрытие папок руками"
            Start-Sleep 4
            
        }
    } 
    # уберем дублирование вывода
    #else {
    #    write-host "Скрытие установлено для папки $($AC.Path)"
    #    write-host "Назначена группа: $($AC.AccountName)"
    #}
    
    Start-Sleep 3
    $AC2 =  Get-DfsnAccess -Path $DFSroot
    write-host "Скрытие ранее было установлено для папки $($AC2.Path)"
    write-host "Назначена группа: $($AC2.AccountName)"
} # отображения или скрытия папок DFS


# Проверка на включеную галку в Managed By (Если $CheckBoxManaged = $false, не будет работать)
# включение её для NetworkFoldersManagers
function AddCheckBox {
    param (
        [Parameter(Mandatory = $false,
        HelpMessage="Добавляемая группа или пользователь Distinquished Name",
        ValueFromPipeLine = $false,
        Position = 0)]
        [hashtable]$HashGr = $null,
    
        [Parameter(Mandatory = $false,
        HelpMessage="Сервер",
        ValueFromPipeLine = $false,
        Position = 1)]
        [String]$Server
    )
    # Необходимы эти модули
    #Add-PSSnapin Microsoft.Exchange.*  # Имортируем модуль EX
    $Error.Clear()
    try {
        if ( $null -eq (Get-PSSnapin -Name Microsoft.Exchange.* -ErrorAction SilentlyContinue) ) {Add-PsSnapin Microsoft.Exchange.*}
    } catch {
        write-host $Error[0].Exception.Message -ForegroundColor Red
        return
    }
   
    foreach($item in $HashGr.Keys) {
        # пропустим пустые ключи
        if($null -eq $HashGr[$item]) { continue }
    
        if(('Read0' -eq $item) -or ('Write0' -eq $item)) {
            
            $ADPerG = Get-ADPermission -Identity $HashGr[$item].SamAccountName | Where-Object {$_.user -match 'NetworkFoldersManagers'}
            if( -not [string]::IsNullOrEmpty($ADPerG)) {
                Write-Host "Для -" $HashGr[$item].SamAccountName
                Write-Host "ChackBox: Manager can update membership list - Уже был установлен"
            } else {
                Add-ADPermission -Identity $HashGr[$item].SamAccountName -User 'NetworkFoldersManagers' -AccessRights WriteProperty -Properties "Member"
                Write-Host "Для -" $HashGr[$item].SamAccountName
                Write-Host "ChackBox: Manager can update membership list - Установлен"
            }

        }
    }


} # Проверка на включеную галку в Managed By (Если $CheckBoxManaged = $false, не будет работать)
# включение её для NetworkFoldersManagers

# Версия №2 более быстрая и без имполртирования доп. модулей.
function AddCheckBox2 {
    param (
        [Parameter(Mandatory = $false,
        HelpMessage="Добавляемая группа или пользователь Distinquished Name",
        ValueFromPipeLine = $false,
        Position = 0)]
        [hashtable]$HashGr = $null,
    
        [Parameter(Mandatory = $false,
        HelpMessage="Сервер",
        ValueFromPipeLine = $false,
        Position = 1)]
        [String]$Server
    )
    $userAccount = 'IE\NetworkFoldersManagers'

    $Error.Clear()
  
  
    foreach($item in $HashGr.Keys) {
        # пропустим пустые ключи
        if($null -eq $HashGr[$item]) { continue }
    
        if(('Read0' -eq $item) -or ('Write0' -eq $item)) {
             
            $group = Get-ADGroup -Identity $HashGr[$item].SamAccountName
            $GroupDN = $group.DistinguishedName
            $acl = Get-Acl AD:\$GroupDN
            
            $access = $acl.Access | Where-Object {$_.IdentityReference -eq $userAccount}
            if ($null -eq $access) {
                    
                Write-Host "Прав Managed By нет для группы: " $userAccount
                Write-Host "Будем создавать.."
                $gr = Get-ADGroup -Identity $($userAccount -replace '^.*\\')
                $group2 = [adsi]"LDAP://$GroupDN"
                # Правим соответствующий атрибут
                $group2.put("ManagedBy",$gr.DistinguishedName)
                # записываем изменения
                $group2.setinfo()
                    
                $sid = $gr.SID
                # Создадим объект guid
                $guid = new-object Guid bf9679c0-0de6-11d0-a285-00aa003049e2

                $ctrl = [System.Security.AccessControl.AccessControlType] "Allow"
                $rights = [System.DirectoryServices.ActiveDirectoryRights] "WriteProperty"
                # Создадим объект прав 
                $rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $sid,$rights,$ctrl,$guid

                $acl.AddAccessRule($rule)

                Set-Acl -AclObject $acl -Path AD:\$GroupDN

                Write-Host "права выставлены CheckBox установлен для: " $($HashGr[$item].SamAccountName)
                Write-Host "После обновления, права будут доступны мин 2+"

            } else {
                Write-Host "CheckBox уже был ранее установлен для -" $($HashGr[$item].SamAccountName)
                
            }     
        }
    }


} # Проверка на включеную галку в Managed By (Если $CheckBoxManaged = $false, не будет работать)
# включение её для NetworkFoldersManagers
# # Версия №2 более быстрая и без имполртирования доп. модулей.