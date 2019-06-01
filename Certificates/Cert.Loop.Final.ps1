#these create a secure credential, i used this command to get the long encrypted password: (Get-Credential).Password | ConvertFrom-SecureString
$user = "domain\user" #password will not look pretty, will be longer thatn my example
$pass = "000000238490274327502859028jf0mmda902357jjndas9089248209482093483290482904832904829304829038249082klmjbn10480582923852" | Convertto-SecureString
$MyCredential= New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User,$pass

#specifying the parameters for the timeframe and WRk account
#Specifies the file name that you want, creates secure credentials so it does not bring up the GUI box for credentials 
#queries the OUs that you want computers from, will save it to a network drive with a name you specify, 
#you have to pipe all fo the OUs because SearchBase cannot take an array
$loop = "ou=marketing,ou=Departments,DC=domain,DC=local",
"ou=admins,ou=IT,DC=domain,DC=local",
"ou=management,ou=accoutning,DC=domain,DC=local"  | ForEach-Object { Get-ADcomputer -filter * -SearchBase $_  |  where-object {$_.distinguishedname -notlike "*OU=Ignoreme*"} | select-object Name}

# this formats the list so the loop will query the computers correctly, then saves the file again
$closetoexpiration = (get-date).AddDays(30) #date the certificate expires (in your given timeframe)
$currentdate = Get-date -Format yyyy-MM-dd
$certificatefileoutput = "Expired_Certificates_" + "$currentdate" + ".csv" 
$logfileoutput = "Error_message_On_" + "$currentdate" + ".log"
$filepath= "\\files\path\IT\Certificates\$certificatefileoutput"
$logfilepath = "\\files\path\it\certificates\$logfileoutput"
<#gathers certificate information from the workstations personal folder, labels when the certificate will expire (if it is in the timeframe). 
Format the date so it does not output "xx/xx/xxxx"(wont be able to save the path correctly).
#>
$i = 0
  foreach($computer in $loop.Name) { 
      try { #adjust throttle for how many computers after the AD search
  Invoke-command -ComputerName $computer -Credential $MyCredential -ThrottleLimit 100 { Get-ChildItem -Path Cert:\localmachine\My } | ForEach-Object { 
        If ($_.NotAfter -le $closetoexpiration) { $info = $_ | Select-Object PScomputername, Issuer, Subject, NotAfter, Thumbprint, @{Label="Expires In (Days)";Expression={($_.NotAfter - (Get-Date)).Days}}
        $removed+=$info
        $removed
        }
    }
    #progress bar
$i++
Write-Progress -Activity "Scanning for Certificates..." -Status "Scanned $i of $($loop.count) computers" -CurrentOperation "$computer" -PercentComplete (($i / $loop.count) * 100)
start-sleep -milliseconds 100 #shows progress bar since this will take a long time to complete
}
    catch [System.Management.Automation.Remoting.PSRemotingTransportException] { #psremoting fail
    Write-Host -ForegroundColor Red -BackgroundColor Black "unable to reach $computer."
    }
    catch { #catches other erorrs
        Write-Host -ForegroundColor Red -BackgroundColor Black "$computer was not reachable."
    }
    Finally { 
        # $error captures all error messages in the current console, more verbose log file, cleans up host screen
        $error | Out-File -FilePath $logfilepath -Append
    }
}
$removed | Select-Object @{Label="Computer_Name";Expression={$_.Pscomputername}},
@{Label="Issuer";Expression={$_.Issuer}},
@{Label="Subject";Expression={$_.Subject}},
@{Label="NotAfter";Expression={$_.NotAfter}},
@{Label="Thumbprint";Expression={$_.Thumbprint}}, 
@{Label="Expires In (Days)";Expression={($_.NotAfter - (Get-Date)).Days}} | Export-Csv -Path $filepath -NoTypeInformation
#email settings


$import = import-csv -Path $filepath | Select-Object Computer_Name,"Expires In (Days)",NotAfter | ConvertTo-Html -Fragment
<# </br> add a line break to the HTML message, <b> makes text bold. <u> underlines text. font changes the color, font type (face) and size of the font.  #>
$mailBody = 
@"
<font color='186697' face='Calibri' size=6><b><u>Attention,</u></b></font></br>
</br>
<font face='Calibri'>The CSV file attached ($filepath) is a list of the certificates expiring soon that should be renewed.
Group policy should renew these workstation certificates once the certificate has 6 weeks left of life.</font></br>
</br>
$import</br>
<font face='Calibri'>Thanks,</font></br>
<font face='Calibri' size=5><b>The Certificate Script</font></b>
"@

Send-MailMessage -From 'email@domain.com' -To 'email@domain.com' -Subject "Expired Workstation Certificates" -Body $mailBody -BodyAsHtml -SmtpServer "smtp.domain.local" -Attachments $filepath

Read-Host "press any button to continue..."