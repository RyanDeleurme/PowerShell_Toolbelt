function Set-OfficeProductKey { 
    param(
        [parameter(Mandatory=$false,Position = 1)]
        [string]
        $remotecomputer,
        [parameter(Mandatory=$true,Position=0,HelpMessage = "Enter your  username so we can use PSremoting ")]
        [ValidateNotNull]
        [string]
        $WRKusername
    )
#this helps the user search for a user comptuer in AD, use -le 3 since $null will not work
if ($remotecomputer.Length -le 3) { 
    $approval = Read-Host -Prompt "Would you like to search for a computer in AD? [y/n] "
if ($approval -match "[Y|y|T|t]") { 
    $search = Read-Host -Prompt "ex: use first name only or firstname last initial (johnd;etc...)" 
    Get-ADComputer -Filter * | Where-Object{$_.Name -match "$search"} | Select-Object -ExpandProperty Name #keep expand property so it will display the full output
    Read-Host -prompt "now copy the computer you would like to renew the product key on, press any key to exit this prompt..."
    }
} 
$remotecomputer = Read-Host -Prompt "remote computer?"
$password = read-host -AsSecureString "password?"
$login = new-object System.Management.Automation.PSCredential -argumentlist $wrkusername,$password
$office32bitpath = Test-Path  "C:\Program Files (x86)\Microsoft Office\Office16"
$office15path32 = Test-Path "C:\Program Files (x86)\Microsoft Office\Office15"
$office15path64 = Test-Path "C:\Program File\Microsoft Office\Office15"
#the status is a batch command, this helps install the product key and the VBscript can be found at one of the file locations above
#lspp.vbs output looks like this 
<# 
---Processing--------------------------
---------------------------------------
PRODUCT ID: XXXXX
SKU ID: XXXX
LICENSE NAME: Office 16, Office16O365ProPlusR_Subscription1 edition
LICENSE DESCRIPTION: Office 16, TIMEBASED_SUB channel
LICENSE STATUS:  ---Licensed---
Last 5 characters of installed product key: XXXXX
---------------------------------------
---------------------------------------
---Exiting-----------------------------#>
function set-32bitoffice16key { 
    Invoke-Command -ComputerName $remotecomputer -Credential $login -ScriptBlock { 
        Set-Location "C:\Program Files (x86)\Microsoft Office\Office16"
        Write-Host "Preparing to update Office Product Key..."
        Start-Sleep -Seconds 3
        cscript ospp.vbs /inpkey:XXXXX-XXXXX... #could not make the key a variable because the command would not work
        $status = cscript ospp.vbs /dstatus | Select-String -Pattern "---LICENSED---"
    if ($status.count -eq 2 -or $status.count -eq 1) { #this helps again validate if the key installed successfully, the count is 2 because with select string, it outputs two linces of LICENSED
        Write-Host -ForegroundColor Green "The office product key installion is successful."
        Start-Sleep -Seconds 3 | Exit-PSHostProcess
            }    
        }
    }
function set-64bitoffice16key { 
    Invoke-Command -ComputerName $remotecomputer -Credential $login -ScriptBlock { 
        Set-Location "C:\Program Files\Microsoft Office\Office16"
        Write-Host "Preparing to update Office Product Key..."
        Start-Sleep -Seconds 3
        cscript ospp.vbs /inpkey:$productkey
        $status = cscript ospp.vbs /dstatus | Select-String -Pattern "---LICENSED---"
    if ($status.count -eq 2 -or $status.count -eq 1) { 
        Write-Host -ForegroundColor Green "The office product key installion is successful."
        Start-Sleep -Seconds 3 | Exit-PSHostProcess
            }
        }   
    }
function Set-32bitOffice15key { 
    Invoke-Command -ComputerName $remotecomputer -Credential $login -ScriptBlock { 
        Set-Location "C:\Program Files (x86)\Microsoft Office\Office15"
        Write-Host "Preparing to update Office Product Key..."
        Start-Sleep -Seconds 3
        cscript ospp.vbs /inpkey:$productkey
        $status = cscript ospp.vbs /dstatus | Select-String -Pattern "---LICENSED---"
    if ($status.count -eq 2 -or $status.count -eq 1) { 
        Write-Host -ForegroundColor Green "The office product key installion is successful."
        Start-Sleep -Seconds 3 | Exit-PSHostProcess
            }    
        } 
}
function Set-64bitoffice15key { 
    Invoke-Command -ComputerName $remotecomputer -Credential $login -ScriptBlock { 
        Set-Location "C:\Program Files\Microsoft Office\Office15"
        Write-Host "Preparing to update Office Product Key..."
        Start-Sleep -Seconds 3
        cscript ospp.vbs /inpkey:$productkey
        $status = cscript ospp.vbs /dstatus | Select-String -Pattern "---LICENSED---"
    if ($status.count -eq 2 -or $status.count -eq 1) { 
        Write-Host -ForegroundColor Green "The office product key installion is successful."
        Start-Sleep -Seconds 3 | Exit-PSHostProcess
            }    
        }
}
#if statements for all the different paths
if ($office32bitpath -eq $true) { 
set-32bitoffice16key
    }
elseif ($office15path32 -eq $true) {
    Set-32bitOffice15key
    }
elseif ($office15path64 -eq $true) {
    Set-64bitoffice15key

    }
else { 
    set-64bitoffice16key
    }
}
Set-OfficeProductKey