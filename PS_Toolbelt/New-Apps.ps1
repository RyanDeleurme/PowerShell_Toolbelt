<# script template to automate settings on new computers, good if you have a bad image, dont have SCCM running
or need a quick setting configuration.#>
function MessageBox { 
    Add-Type -AssemblyName PresentationCore,PresentationFramework
    $ButtonType = [System.Windows.MessageBoxButton]::OkCancel
    $MessageIcon = [System.Windows.MessageBoxImage]::Asterisk
    $MessageBody = "Please update JAVA" 
    $MessageTitle = "Reminder"
     
    $Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)

if ($Choice -eq "ok")
    {    
    $form.dispose() } 
    Write-Host "$Result"
}

function LaptopPower { 
Write-Host "lid settings changed to not sleep when docked." #this change lid settings because when docked, the laptop will sleep when the user closes the laptop, resulting in a bad display. I ripped these valeus off of stack overflow after testing them...
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0

}


#Make sure to run this as your workstation account so you can be able to copy the files straight to the C: drive later. 
 function 32officekey { 
     Set-Location -Path "C:\Program Files (x86)\Microsoft Office\Office16\"
    Write-Host "Installing Office 2016 32-bit Key."
    Start-Sleep -Seconds 3
    cscript ospp.vbs /inpkey:XXXX...
    $status = cscript ospp.vbs /dstatus | Select-String -Pattern "---LICENSED---"#could not make the key a variable because the command would not work
if ($status.count -eq 2) { 
    Write-Host -ForegroundColor Green "The office product key installion is successful."#this helps again validate if the key installed successfully, the count is 2 because with select string, it outputs two linces of LICENSED
    } 
}
 
#64 bit install office key
function 64officekey { 
    Set-Location -Path "C:\Program Files\Microsoft Office\Office16"
   Write-Host "Installing Office 2016 Key."
   Start-Sleep -Seconds 3
   cscript ospp.vbs /inpkey:F9VX7-NX86R-GG3W6-DKF32-2DKYB
   $status = cscript ospp.vbs /dstatus | Select-String -Pattern "---LICENSED---"#could not make the key a variable because the command would not work
if ($status.count -eq 2) { 
   Write-Host -ForegroundColor Green "The office product key installion is successful."#this helps again validate if the key installed successfully, the count is 2 because with select string, it outputs two linces of LICENSED
   Start-Sleep -Seconds 3 | Exit-PSHostProcess
   } 
}
#maps share drives on computer if no netlogon script
net use Z: \\files\Accounting

 #all the apps, change the location of the install (could be local or over the network, your decision)
 write-host -ForegroundColor Cyan -BackgroundColor Black "Installing Standard Apps" 
<#
put the name of the application as the key and path to the install as the value. 
#>
$Applications = @(
@{title='Adobe Acrobat Reader DC' ; application = 'c:\path\install.exe'} 
@{title='Microsoft Any Connect' ; application = 'https://www.java.com/inc/BrowserRedirect1.jsp?locale=en'} 
@{title='Oracle 12' ; application = 'c:\path\install.cmd'} 
) 

foreach ($application in $applications){ 
    $Applicationname = $application.title
    $applicationpath = $application.application
    $installer = Start-Process -FilePath $applicationpath -Wait -passthru
    if ($installer.ExitCode -eq 0){ 
        Write-Host -ForegroundColor Green "$applicationname has successfully installed..." 
    } #if you want to do webrequests
    if($applicattionname -eq "Java"){
        $dest = "$PSScriptRoot\java.exe"
        Invoke-WebRequest -uri $applicationpath -OutFile $dest
        $installer = Start-Process -FilePath $dest -Wait -PassThru
        Write-Host -ForegroundColor Green "$applicationname has successfully installed..." 
    } 
} 


# this will enroll the workstation with the workstation certificate, can change the template to others if you want as well (same goes with path). 

set-location -path cert:localmachine\my 
get-certificate -Template Mytemplate
#confirmation
$testcert  = Get-ChildItem -Path Cert:\LocalMachine\My
if($testcert.IssuerName -like "CN=MY.CA, DC=domain, DC=local") { 
    Write-Host -ForegroundColor Green " Workstation Certificate has been successfully installed" 
}

#installs office key automatically with the functions at the beginning
32officekey

#sets lid power settings when docked so the laptop will no go to sleep when docked. 
$approval = Read-Host -Prompt "Is this workstation a laptop?[y/n]"
if ($approval -match "[Y|y|T|t|U|u]") { 
    LaptopPower
} 


set-executionpolicy remotesigned
MessageBox