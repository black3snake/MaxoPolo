
[string]$path = '\\server\cports$\PC_All\'
$computername = (Get-WmiObject -Class Win32_ComputerSystem).Name
#$env:COMPUTERNAME

[string]$name_pc_str = $path + $computername + '.txt'
# определим имя группы Администраторов
$Admin = (Get-WMIObject -Class Win32_Group -Filter "LocalAccount=True and SID='S-1-5-32-544'").Name

function Variant2 {
    param (
        [Parameter(Mandatory=$True,
        HelpMessage="Название группы локальных администраторов RU or EN",
        ValueFromPipeLine = $false,
        Position = 0)]
        [string]$AdmName,
    
        [Parameter(Mandatory=$True,
        HelpMessage="Название PC",
        ValueFromPipeLine = $false,
        Position = 1)]
        [string]$computername
    
        )
    $userGroup = [ADSI]"WinNT://./$AdmName"
    $test22 = (@($userGroup.Invoke(“Members”)) | ForEach-Object {$_.GetType().InvokeMember(“ADSPath”, ‘GetProperty’, $null, $_, $null)})
    [string]$str1 = ''
    foreach($item in $test22){ 
        $item = $item.Substring(8)
        $str1 += $item + "," 
    
    }
    
    
    $str1 = $str1.TrimEnd(',')
    #Add-Content -path $name_pc_str -Value "Two variant"
    [string]$str1_out = $computername + ";" + $str1
    Set-Content -path $name_pc_str -Value $str1_out
    #Add-Content -path $name_pc_str -Value ""
}

# Вариант запроса № 1
$REQQ = Get-LocalGroup -Name $Admin
$admins = Get-LocalGroupMember $REQQ

[string]$adm_tmp = ''
foreach($adm in $admins){
    if($adm.Name -match “(.+)\\(.+)$”) {
        $adm_tmp += $($matches[1].trim('"') + “\” + $matches[2].trim('"')+",")

    }
}
[string]$adm_tmp2=''
$adm_tmp2 = $adm_tmp.TrimEnd(',')
if(-not [string]::IsNullOrEmpty($adm_tmp2)) {
    [string]$pc_output = $computername + ";" + $adm_tmp2


    if(Test-Path $path ) {
        Set-Content -path $name_pc_str -Value "$pc_output"
    }
} else {
    # Вариант запроса № 2
    Variant2 -AdmName $Admin -computername $computername

}