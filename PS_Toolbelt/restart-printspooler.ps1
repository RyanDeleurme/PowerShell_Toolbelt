#restarts print spooler remotely
$wrkusername = Read-Host -Prompt "Username?"
$password = Read-Host -AsSecureString "password?"

$approval = Read-Host -Prompt "Would you like to search for a computer in AD? [y/n] "
if ($approval -match "[Y|y|T|t]") { 
    $search = Read-Host -Prompt "ex: use first name only or firstname last initial (johnd,etc...)" 
    Get-ADComputer -Filter * | Where-Object{$_.Name -match "$search"} | Select-Object -ExpandProperty Name #keep expand property so it will display the full output
    Read-Host -prompt "now copy the computer you would like to remote to, press any key to continue..."
}
$computer = Read-Host "remote computer?"
$login = new-object System.Management.Automation.PSCredential -argumentlist $wrkusername,$password #creates login for PSremoting 

Invoke-Command -ComputerName $computer -Credential $login -ScriptBlock { 
    Stop-Service -Name Spooler #stops print spooler so the printer installs correctly
    Write-Host -ForegroundColor Red -BackgroundColor Black "The print spooler service has been stopped..." 
    Start-Sleep -Seconds 3
    Start-Service -Name Spooler #starts again
    $test = Get-Service -Name Spooler | Select-Object -Property Status
    if($test.Status -eq "Running") { 
        Write-Host -ForegroundColor Green "The print spooler has been resetted successfully..."
        Start-Sleep -Seconds 3
    }
    else {
        Write-Host -ForegroundColor Red -BackgroundColor Black "The print spooler did not restart successfully. Please try again."
        Start-Sleep -Seconds 3
    }
}