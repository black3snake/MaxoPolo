# Код который отменяет политку хранения почтовых писем на ящике
#
#
#Clear-Host
$ErrorActionPreference = "stop"
# Путь до кода
$PathToScript=$(Split-Path -Parent $MyInvocation.MyCommand.Path)+"\"
[string]$fileE = 'ExceptionMail.txt'
[array]$Exceptions_src = Get-Content -Path $($PathToScript+"$fileE")
[array]$Exceptions = @()

# Сделаем вывод в лог и консоль
Function Write-HostAndLog {
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = "Строка вывода",
            Position = 0,
            ValueFromPipeLine = $false)]
        [string]$FuncWHLText,
    
        [Parameter(Mandatory = $false,
            HelpMessage = "не \n\r",
            Position = 1,
            ValueFromPipeLine = $false)]
        [string]$OP
    )
    # консоль    
    if ([string]::IsNullOrWhitespace($OP)) {
        Write-Host $FuncWHLText
        # logFile
        Add-Content $PathToScript\logExPol.txt $FuncWHLText
    }
    else {
        Write-Host $FuncWHLText -NoNewline
        # logFile
        Add-Content $PathToScript\logExPol.txt $FuncWHLText -NoNewline
    }
}# Сделаем вывод в лог и консоль

Write-HostAndLog "Start: $(Get-Date)"

# проверка имени почтового ящика
function IsValidEmail {
    param([string]$Email)
    $Regex = '^[A-Za-z0-9 ?._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,7}$'
    try {
        $obj = [mailaddress]$Email
        if($obj.Address -match $Regex){
            return $True
        }
        return $False
    }
    catch {
        return $False
    }
}

[string]$str_tmp =''
foreach($z in $Exceptions_src) {
    $str_tmp = $z.Trim()
    #$str_tmp = $str_tmp -replace '^.+\\'
    if(IsValidEmail($str_tmp)) {
        $Exceptions += $str_tmp
    } else {
        Write-HostAndLog "Ошибка в имени почтового ящика"
    }
    $str_tmp = ''    
}

[array]$ExceptionsMailObj = @()
# Заполним массив оъектами почтовых ящиков 
foreach($E in $Exceptions) {
    $Error.Clear()
    try {
        $mail_tmp = Get-Mailbox -Identity $E
    } catch {
        $Err = $Error[0].Exception.Message
        Write-HostAndLog "$Err"
    }
    $ExceptionsMailObj += $mail_tmp; $mail_tmp = $null
}

#$ExceptionsMailObj

# Создадим таблицу для отчета на почту (Заголовок)
#$thfont = "style=""font-size: 11pt; color: Black"""
[string]$tblHTMLstr = "<html><body>"

<#
$tblHTMLstr += $("<br><table border=2 bordercolor=""Blue"">")
$tblHTMLstr += $("<tr " + $thfont + ">")
$tblHTMLstr += $("<th>№</th><th>ФИО</th><th>Должность</th><th>Предприятие</th><th>Почтовый ящик</th><th>Policy</th>")
$tblHTMLstr += $("</tr>")
#>

function Set-MailReport {
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = "Масив ",
            Position = 0,
            ValueFromPipeLine = $false)]
        [Array]$PostArray,
        
        [Parameter(Mandatory = $true,
            HelpMessage = "Зона",
            Position = 2,
            ValueFromPipeLine = $false)]
        [string]$zone
    
        )
    
    $colspan = 6
    $colorSuccess = "PaleGreen"
    $colorWarning = "silver"
    $colorError = "IndianRed"
    $tdfont = "style=""font-size: 10pt; color: Black"""    
    # Создадим таблицу для отчета на почту (Заголовок)
    $thfont = "style=""font-size: 11pt; color: Black"""
    [string]$tblHTMLstrF = ''

    $tblHTMLstrF += $("<br><table border=2 bordercolor=""Blue"">")
    $tblHTMLstrF += $("<tr "+$tbfont+">")
    $tblHTMLstrF += $("<td colspan="+$colspan+" align=""left""><b>"+$zone+"</b></td>")
    $tblHTMLstrF += $("</tr>")
    $tblHTMLstrF += $("<tr " + $thfont + ">")
    $tblHTMLstrF += $("<th>№</th><th>ФИО</th><th>Должность</th><th>Предприятие</th><th>Почтовый ящик</th><th>Policy</th>")
    $tblHTMLstrF += $("</tr>")

    
    [int]$k = 0

    foreach ($index in $PostArray) {
        $k++
        
        if(-not [string]::IsNullOrEmpty($($index.RetentionPolicy))) {
            Write-HostAndLog "$($index.PrimarySmtpAddress.Address),  дата создания:$($index.WhenCreated) , рабочий в AD?: $($mailuser.enabled). Политика хранения была ранее установлена: $($index.RetentionPolicy.Name)"
            $tblHTMLstrF += $("<tr " + $tdfont + ">")
            $tblHTMLstrF += $("<td align=center bgcolor=" + $colorWarning + ">" + $k.ToString() + "</td><td>" + $($index.CustomAttribute9) + "</td><td>" + $($index.CustomAttribute13) + "</td><td>" + $($index.CustomAttribute15) + "</td><td>" + $($index.PrimarySmtpAddress.Address) + "</td>")
            $tblHTMLstrF+= $("<td>$($index.RetentionPolicy.Name)</td>")
            $tblHTMLstrF += "</tr>"
            if($zone -eq 'OUTPUT2') {
                Set-Mailbox -Identity $index.PrimarySmtpAddress.Address -RetentionPolicy $null
            }

        } else {
            Write-HostAndLog "$($index.PrimarySmtpAddress.Address),  дата создания:$($index.WhenCreated) , рабочий в AD?: $($mailuser.enabled). Политики хранения нет: $($index.RetentionPolicy.Name)"
            $tblHTMLstrF += $("<tr " + $tdfont + ">")
            $tblHTMLstrF += $("<td align=center bgcolor=" + $colorSuccess + ">" + $k.ToString() + "</td><td>" + $($index.CustomAttribute9) + "</td><td>" + $($index.CustomAttribute13) + "</td><td>" + $($index.CustomAttribute15) + "</td><td>" + $($index.PrimarySmtpAddress.Address) + "</td>")
            $tblHTMLstrF+= $("<td>$($index.RetentionPolicy.Name)</td>")
            $tblHTMLstrF += "</tr>"
            if($zone -eq 'OUTPUT2') {
                Set-Mailbox -Identity $index.PrimarySmtpAddress.Address -RetentionPolicy $null
            }
        }
    
    
    }
    $tblHTMLstrF += $("</table>")
    Write-HostAndLog "В $zona : $k ящиков попало в обработку"
    if ($k -eq 0) { $tblHTMLstrF = '' }
    return $tblHTMLstrF

}


Write-Host
Write-Host "INPUT отчет"
[string]$tblHTMLstr_tmp = ''
$tblHTMLstr_tmp += Set-MailReport -PostArray $ExceptionsMailObj -zone 'INPUT'
$tblHTMLstr += $tblHTMLstr_tmp; $tblHTMLstr_tmp = '';

Write-Host
Write-Host "OUTPUT отчет"
[string]$tblHTMLstr_tmp = ''
$tblHTMLstr_tmp += Set-MailReport -PostArray $ExceptionsMailObj -zone 'OUTPUT'
$tblHTMLstr += $tblHTMLstr_tmp; $tblHTMLstr_tmp = '';


$tblHTMLstr += $("</table>")
$tblHTMLstr += $("</body></html>")

# Очистка файла содержащего названия почтовых ящиков
$fileIt = Get-Item -Path $($PathToScript+"$fileE")
if($fileIt.Length -gt 0) {
    Clear-Content -Path $($PathToScript+"$fileE") -Force -Confirm:$false
} else {
    Write-HostAndLog "Файл Исключений пустой в нем нет записей о именах почтовых ящиках"
} # Очистка файла содержащего названия почтовых ящиков

# отправим письмо
$emailFrom = "server@edigital"
$emailTo =  "*****@edigital"
#$emailTo = "******@edigital"
#$emailBcc = "****@edigital"
$subj = "Уведомление о отмене политики для хранения писем в почтовых ящиках"
$body = $tblHTMLstr
$smtpServer = "mail.server"

#$att = new-object Net.Mail.Attachment($file)
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
$msg = new-object Net.Mail.MailMessage
$msg.IsBodyHTML = $true
$msg.From = $emailFrom
$msg.To.Add($emailTo)
#$msg.Cc.Add($emailCc)
#$msg.Bcc.Add($emailBcc)
$msg.Subject = $subj
$msg.Body = $body
#$msg.Attachments.Add($att)


if ($tblHTMLstr -match "\w+@\w+\.\w+") {
    $smtp.Send($msg)
}
else {
    Write-HostAndLog "Почтовых ящиков не найдено(не будет отсылать письмо). $(Get-Date)"
    exit
}
#$smtp.Send($msg)
#$att.Dispose()

Write-HostAndLog "Letter Sended.. $(Get-Date)"