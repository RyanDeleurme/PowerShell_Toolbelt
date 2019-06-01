<# user script to pull certificates from current user store---------------------------------------------------------------
NOTE: this has to be ran as a scheduled task with the author being the user you want the certs pulled from.---------------
ex: if I want to pull scripts from the currentuser johnd store, I need to have the author of the scheduled task be johnd#>

$closetoexpiration = (get-date).AddDays(90) #date the certificate expires (in your given timeframe)
$currentdate = Get-date -Format yyyy-MM-dd
$certificatefileoutput = "Expired_Certificates_" + "$currentdate" + ".csv" 
$filepath= "\\files\path\johnd\$certificatefileoutput"

#gets certificates and the properties wanted. 

Get-ChildItem -Path Cert:\currentuser\My | ForEach-Object { 
    If ($_.NotAfter -le $closetoexpiration) { $info = $_ | Select-Object Pscomputername, Issuer, Subject, NotAfter, Thumbprint, @{Label="Expires In (Days)";Expression={($_.NotAfter - (Get-Date)).Days}}
    }
}

#formatting for CSV file
$info | Select-Object @{Label="Computer_Name";Expression={$_.Pscomputername}},
@{Label="Issuer";Expression={$_.Issuer}},
@{Label="Subject";Expression={$_.Subject}},
@{Label="NotAfter";Expression={$_.NotAfter}},
@{Label="Thumbprint";Expression={$_.Thumbprint}}, 
@{Label="Expires In (Days)";Expression={($_.NotAfter - (Get-Date)).Days}} | Export-Csv -Path $filepath -NoTypeInformation

<# Email Settings#>

#import the CSV and convert to html formatting for the email
$import = import-csv -Path $filepath | Select-Object Issuer,"Expires In (Days)",NotAfter | ConvertTo-Html -Fragment
<# </br> add a line break to the HTML message, <b> makes text bold. <u> underlines text. font changes the color, font type (face) and size of the font.  #>
$mailBody = 
@"
<font color='186697' face='Calibri' size=5><b><u>Attention,</u></b></font></br>
</br>
<font face='Calibri'>The CSV file attached ($filepath) is a list of the certificates expiring soon that should be renewed.
Please update the certificates accordingly.</font></br>
</br>
$import</br>
<font face='Calibri'>Thanks,</font></br>
<font face='Calibri' size=5><b>The Certificate Script</font></b>
"@

Send-MailMessage -From 'fromemail@domain.com' -To 'Toemail@domain.com' -Subject "Expired Certificates" -Body $mailBody -BodyAsHtml -SmtpServer "smtp.domain.com" -Attachments $filepath
