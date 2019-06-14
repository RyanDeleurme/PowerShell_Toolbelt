<# Gets possibly retired computer accounts #>
$currentdate = Get-date -Format yyyy-MM-dd
$fileoutput = "Old_Computers_" + "$currentdate" + ".csv" 
$logfileoutput = "Error_message_On_" + "$currentdate" + ".log"
$filepath= "\\files\IT\path\script_outputs\Get-OldComputers\$fileoutput"
$logfilepath = "\\files\IT\path\script_outputs\Get-OldComputers\$logfileoutput"
$days = Read-Host -Prompt "days you want to search for computers, please put a `"-`" in front of the number to fetch older dates ex: -60"
$date = (get-date).AddDays($days) #gets the current date a month ago.

#use top level OU to fetch all computers
$test = "ou=TOPLEVELOU,DC=ncpa,DC=loc" | ForEach-Object {
    Get-ADComputer -Filter * -SearchBase $_ -Properties name,dnshostname,lastlogondate,passwordlastset,distinguishedname  | where-object {$_.distinguishedname -notmatch "OU=Training"} 
}
#declare retired computers array.
$retired = @()

#ping computers just incase they can still be up, this goes by pretty fast, use Test-Netconnection and NOT test-connection. The former is a better version of the ladder and is faster.
$retired += foreach($computer in $test) { 
    if($computer.LastLogonDate -lt $date) { 
        try { 
        $ping = Test-NetConnection -ComputerName $computer.Name -ErrorAction Stop | Select-Object Tcptestsucceeded
        } #catch errors, we expect the connection to fail so the erorr output really isnt needed.
        catch [System.Management.Automation.MethodInvocationException] {}
        finally { #make object for CSV file and readability.
        [pscustomobject] @{ 
        "Name" = $computer.name
        "DNS" = $computer.dnshostname
        "Reachable?" = $ping.TcpTestSucceeded
        "last login" = $computer.lastlogondate
        "Last password" = $computer.passwordlastset
        "AD Location" = $computer.distinguishedname
            }
        #send error output to log file.
        $error | Out-File -FilePath $logfilepath
        }
    }
}

# no type info eliminates # type header on CSV file.
$retired | Export-Csv $filepath -NoTypeInformation 

Write-Host "================================================"
Write-Host " CSV file can be found at $filepath"

Read-Host -Prompt "Press any button to continue..."