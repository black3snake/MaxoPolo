# Created Pukhov Max. 27.01.2022
#
Clear-Host
#
#Add-PSSnapin Microsoft.Exchange.*  # Имортируем модуль EX
if ( $null -eq (Get-PSSnapin -Name Microsoft.Exchange.* -ErrorAction SilentlyContinue) ) {Add-PsSnapin Microsoft.Exchange.*}
#
# Переменная хранения почтового ящика названия политики
[string]$policy = 'Policy_In_Recovery'
# Время за какой период искать созданные почтовые ящики
[datetime]$DataInterval = ((Get-Date).AddDays(-1))
# выберим все почтовые сервера
[array]$tmpDB = Get-MailboxDatabase 
[array]$MailBoxDatabases_ID = @()
[array]$MailBoxDatabases_MSK = @()
[array]$MailBoxDatabases_LDN = @()
[array]$MailBoxDatabases_I33 = @()

# Путь до кода
$PathToScript=$(Split-Path -Parent $MyInvocation.MyCommand.Path)+"\"
# Сделаем вывод в лог и консоль
Function Write-HostAndLog {
    param (
    [Parameter(Mandatory = $true,
    HelpMessage="Строка вывода",
    Position = 0,
    ValueFromPipeLine = $false)]
    [string]$FuncWHLText,
    
    [Parameter(Mandatory = $false,
    HelpMessage="не \n\r",
    Position = 1,
    ValueFromPipeLine = $false)]
    [string]$OP
    )
    # консоль    
    if([string]::IsNullOrWhitespace($OP)) {
        Write-Host $FuncWHLText
        # logFile
        Add-Content $PathToScript\log.txt $FuncWHLText
    } else {
        Write-Host $FuncWHLText -NoNewline
        # logFile
        Add-Content $PathToScript\log.txt $FuncWHLText -NoNewline
    }
}
# Сделаем вывод в лог и консоль
# метка времени запуска программы
Write-HostAndLog "Start: $(Get-Date)"
#
# а тут разделим их по зонам
foreach($tmp in $tmpDB) {
    # заполним все массивы по зонам
    if(($tmp.Server -ilike "*-id") -or ($tmp.Server.Server -ilike "*-i02")) {
        $MailBoxDatabases_ID += $tmp
    } elseif ($tmp.Server -ilike "*-MSK") {
        $MailBoxDatabases_MSK += $tmp
    } elseif ($tmp.Server -ilike "*-LDN") {
        $MailBoxDatabases_LDN += $tmp
    } elseif ($tmp.Server -ilike "*-I33") {
        $MailBoxDatabases_I33 += $tmp
    }
    $tmp = $null
}
Write-HostAndLog "В зоне IRK серверов $($MailBoxDatabases_ID.Count)"
Write-HostAndLog "В зоне MSK серверов $($MailBoxDatabases_MSK.Count)"
Write-HostAndLog "В зоне LDN серверов $($MailBoxDatabases_LDN.Count)"
Write-HostAndLog "В зоне I33 серверов $($MailBoxDatabases_I33.Count)"



[array]$tmpMailBoxes_ID = @()
[array]$tmpMailBoxes_MSK = @()
[array]$tmpMailBoxes_LDN = @()
[array]$tmpMailBoxes_I33 = @()

# Измерим за одно сколько времени понадобиться собрать все ящики типа UserMailbox
$tm1 = Measure-Command {
    foreach($m1 in $MailBoxDatabases_ID) {
        $tmpMailBoxes_ID += Get-Mailbox -Database $m1.Name -ResultSize Unlimited -IgnoreDefaultScope | Where-Object {$_.RecipientTypeDetails -eq 'UserMailbox'} 
    }
    Write-HostAndLog "Найдено почтовых ящиков пользователей в базах IRK: $($tmpMailBoxes_ID.length) ящиков." "-NoNewline"
}
$tm1S = [Math]::Round($($tm1.TotalMilliseconds * 0.001),2)
Write-HostAndLog "$tm1S sec или в мин $([math]::Round(($tm1S/60),2))" 

$tm2 = Measure-Command {
    foreach($m2 in $MailBoxDatabases_MSK) {
        $tmpMailBoxes_MSK += Get-Mailbox -Database $m2.Name -ResultSize Unlimited -IgnoreDefaultScope | Where-Object {$_.RecipientTypeDetails -eq 'UserMailbox'}
    }
    Write-HostAndLog "Найдено почтовых ящиков пользователей в базах MSK: $($tmpMailBoxes_MSK.length) ящиков." "-NoNewline"
}
$tm2S = [Math]::Round($($tm2.TotalMilliseconds * 0.001),2)
Write-HostAndLog "$tm2S sec или в мин $([math]::Round(($tm2S/60),2))"

$tm3 = Measure-Command {
    foreach($m3 in $MailBoxDatabases_LDN) {
        $tmpMailBoxes_LDN += Get-Mailbox -Database $m3.Name -ResultSize Unlimited -IgnoreDefaultScope | Where-Object {$_.RecipientTypeDetails -eq 'UserMailbox'}
    }
    Write-HostAndLog "Найдено почтовых ящиков пользователей в базах LDN: $($tmpMailBoxes_LDN.length) ящиков." "-NoNewline"
}
$tm3S = [Math]::Round($($tm3.TotalMilliseconds * 0.001),2)
Write-HostAndLog "$tm3S sec или в мин $([math]::Round(($tm3S/60),2))"

$tm4 = Measure-Command {
    foreach($m4 in $MailBoxDatabases_I33) {
        $tmpMailBoxes_I33 += Get-Mailbox -Database $m4.Name -ResultSize Unlimited -IgnoreDefaultScope | Where-Object {$_.RecipientTypeDetails -eq 'UserMailbox'}
    }
    Write-HostAndLog "Найдено почтовых ящиков пользователей в базах I33: $($tmpMailBoxes_I33.length) ящиков." "-NoNewline"
}
$tm4S = [Math]::Round($($tm4.TotalMilliseconds * 0.001),2)
Write-HostAndLog "$tm4S sec или в мин $([math]::Round(($tm4S/60),2))"


# Создадим таблицу для отчета на почту
[string]$tblHTMLstr = "<html><body>"

<#
$tblHTMLstr += "Изменения с $DataInterval</br>"
$tblHTMLstr += "В зоне IRK серверов $($MailBoxDatabases_ID.Count)</br> "
$tblHTMLstr += "В зоне MSK серверов $($MailBoxDatabases_MSK.Count)</br>"
$tblHTMLstr += "В зоне LDN серверов $($MailBoxDatabases_LDN.Count)</br>"
$tblHTMLstr += "В зоне I33 серверов $($MailBoxDatabases_I33.Count)</br>"

$tblHTMLstr += "Найдено почтовых ящиков пользователей в базах зоны IRK: $($tmpMailBoxes_ID.length) ящиков. Время работы: $tm1S sec или в мин $([math]::Round(($tm1S/60),2))</br>"
$tblHTMLstr += "Найдено почтовых ящиков пользователей в базах зоны MSK: $($tmpMailBoxes_MSK.length) ящиков. Время работы: $tm2S sec или в мин $([math]::Round(($tm2S/60),2))</br>"
$tblHTMLstr += "Найдено почтовых ящиков пользователей в базах зоны LDN: $($tmpMailBoxes_LDN.length) ящиков. Время работы: $tm3S sec или в мин $([math]::Round(($tm3S/60),2))</br>"
$tblHTMLstr += "Найдено почтовых ящиков пользователей в базах зоны I33: $($tmpMailBoxes_I33.length) ящиков. Время работы: $tm4S sec или в мин $([math]::Round(($tm4S/60),2))</br>"
#>

#$tblHTMLstr+= $("<br><br><table border=2 bordercolor=""Blue"">")

# найти policy и создать отчет
function Find-MailPostPolycy {
    param (
    [Parameter(Mandatory = $true,
    HelpMessage="Масив ",
    Position = 0,
    ValueFromPipeLine = $false)]
    [Array]$PostArray,

    [Parameter(Mandatory = $true,
    HelpMessage="Временной интервал",
    Position = 1,
    ValueFromPipeLine = $false)]
    [datetime]$timeM,
    
    [Parameter(Mandatory = $true,
    HelpMessage="Зона",
    Position = 2,
    ValueFromPipeLine = $false)]
    [string]$zona,
    
    [Parameter(Mandatory = $true,
    HelpMessage="Зона",
    Position = 3,
    ValueFromPipeLine = $false)]
    [string]$policy
    )
    
    $colspan=10
    $colorSuccess="PaleGreen"
    $colorWarning="silver"
    $colorError="IndianRed"
    $tbfont="style=""font-size: 11pt; color: Blue"""
    $thfont="style=""font-size: 11pt; color: Black"""
    $tdfont="style=""font-size: 10pt; color: Black"""

    $tblHTMLstrF += $("<br><table border=2 bordercolor=""Blue"">")
    $tblHTMLstrF += $("<tr "+$tbfont+">")
    $tblHTMLstrF += $("<td colspan="+$colspan+" align=""left""><b>"+$zona+"</b></td>")
    $tblHTMLstrF += $("</tr>")
    $tblHTMLstrF += $("<tr "+$thfont+">")
    $tblHTMLstrF += $("<th>№</th><th>Status in AD</th><th>PrimarySmtpAddress</th><th>Policy</th><th>WhenCreated</th><th>DataBase</th>")
    $tblHTMLstrF += $("</tr>")
    [int]$k=0
    foreach($index in $PostArray) {
        
        if($index.WhenCreated -ge $timeM ) {
            $mailuser = Get-ADUser -Identity $($index.SamAccountName)
            $k++
            if([string]::IsNullOrEmpty($($index.RetentionPolicy))) { 
                
                if($index.PrimarySmtpAddress.IsValidAddress) {
                    Set-Mailbox -Identity $index.PrimarySmtpAddress.Address -RetentionPolicy $policy
                    Start-Sleep 2
                    # Тестовая замена
                    #$RP = 'Pol_In_Recovery'
                    $mail_tmpP = Get-Mailbox $index.PrimarySmtpAddress.Address
                    Write-HostAndLog "$($index.PrimarySmtpAddress.Address),  дата создания:$($index.WhenCreated) , рабочий?: $($mailuser.enabled). Политика хранения установлена: $($mail_tmpP.RetentionPolicy.Name)"
                    #Write-HostAndLog "$($mail_tmpP.PrimarySmtpAddress.Address),  дата создания:$($mail_tmpP.WhenCreated) , рабочий в AD?: $($mailuser.enabled). Политика хранения установлена: $RP"
                    # Создаем условия для отчета по статусу в AD
                    if( $mailuser.enabled) {
                        $tblHTMLstrF+= $("<tr "+$tdfont+">")
				        $tblHTMLstrF+= $("<td align=center>"+$k.ToString()+"</td><td bgcolor="+$colorSuccess+">&nbsp</td><td>"+$($mail_tmpP.PrimarySmtpAddress.Address)+"</td><td>"+$($mail_tmpP.RetentionPolicy.Name)+"</td><td align='center'>" + $($mail_tmpP.WhenCreated) +"</td>")
				        $tblHTMLstrF+= $("<td>$($mail_tmpP.Database)</td>")
				        $tblHTMLstrF+= "</tr>"
                    } else {
                        $tblHTMLstrF+= $("<tr "+$tdfont+">")
				        $tblHTMLstrF+= $("<td align=center>"+$k.ToString()+"</td><td bgcolor="+$colorError+">&nbsp</td><td>"+$($mail_tmpP.PrimarySmtpAddress.Address)+"</td><td>"+$($mail_tmpP.RetentionPolicy.Name)+"</td><td align='center'>" + $($mail_tmpP.WhenCreated) +"</td>")
				        $tblHTMLstrF+= $("<td>$($mail_tmpP.Database)</td>")
				        $tblHTMLstrF+= "</tr>"
                    }

                }
            } else {
                Write-HostAndLog "$($index.PrimarySmtpAddress.Address),  дата создания:$($index.WhenCreated) , рабочий в AD?: $($mailuser.enabled). Политика хранения была ранее установлена: $($index.RetentionPolicy.Name)"
                $tblHTMLstrF+= $("<tr "+$tdfont+">")
				$tblHTMLstrF+= $("<td align=center>"+$k.ToString()+"</td><td bgcolor="+$colorSuccess+">&nbsp</td><td>"+$($index.PrimarySmtpAddress.Address)+"</td><td bgcolor="+$colorWarning+">"+$($index.RetentionPolicy.Name)+"</td><td align='center'>" + $($index.WhenCreated) +"</td>")
				$tblHTMLstrF+= $("<td>$($index.Database)</td>")
				$tblHTMLstrF+= "</tr>"
            }
            $mailuser = $null
            $mail_tmpP = $null
        }
    }
    $tblHTMLstrF += $("</table>")
    Write-HostAndLog "В $zona : $k ящиков попало в обработку"
    return $tblHTMLstrF
}

Write-Host
Write-Host "IRK отчет"
[string]$tblHTMLstr_tmp=''
$tblHTMLstr_tmp += Find-MailPostPolycy -PostArray $tmpMailBoxes_ID -timeM $DataInterval -Zona 'IRK зона' -policy $policy
$tblHTMLstr += $tblHTMLstr_tmp; $tblHTMLstr_tmp='';

Write-Host
Write-Host "MSK отчет"
$tblHTMLstr_tmp += Find-MailPostPolycy -PostArray $tmpMailBoxes_MSK -timeM $DataInterval -Zona 'MSK зона' -policy $policy
$tblHTMLstr += $tblHTMLstr_tmp; $tblHTMLstr_tmp='';

Write-Host
Write-Host "LDN отчет"
$tblHTMLstr_tmp += Find-MailPostPolycy -PostArray $tmpMailBoxes_LDN -timeM $DataInterval -Zona 'LDN зона' -policy $policy
$tblHTMLstr += $tblHTMLstr_tmp; $tblHTMLstr_tmp='';

Write-Host
Write-Host "i33 отчет"
$tblHTMLstr_tmp += Find-MailPostPolycy -PostArray $tmpMailBoxes_I33 -timeM $DataInterval -Zona 'I33 зона' -policy $policy
$tblHTMLstr += $tblHTMLstr_tmp; $tblHTMLstr_tmp='';

$tblHTMLstr += $("</body></html>")

#Write-Host "$MBDatabase всего: $($tmpMailBoxes.length) ящиков "
Write-HostAndLog "End work: $(Get-Date)"

# отправим письмо
$emailFrom = "server@edigital"
$emailTo =  "****@edigital"
$emailBcc = "****@edigital"
$subj = "Уведомление о примененим политики Policy_In_Recovery для хранения новых ящиков 4х зон"
$body = $tblHTMLstr
$smtpServer = "mail.server"

#$att = new-object Net.Mail.Attachment($file)
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
$msg = new-object Net.Mail.MailMessage
$msg.IsBodyHTML = $true
$msg.From = $emailFrom
$msg.To.Add($emailTo)
#$msg.Cc.Add($emailCc)
$msg.Bcc.Add($emailBcc)
$msg.Subject = $subj
$msg.Body = $body
#$msg.Attachments.Add($att)

$smtp.Send($msg)
#$att.Dispose()

Write-HostAndLog "Letter Sended.. $(Get-Date)"
