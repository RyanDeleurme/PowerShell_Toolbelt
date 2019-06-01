<# Install Windows key remotely #>

#$ErrorActionPreference = 'silentlycontinue' #this was the only way to suppress the output of net use, other methods did not work.
#I handled other errors with specific outputs, so this should not be too much of an issue.

Write-Warning "THIS IS MADE FOR WINDOWS ENTERPRISE ONLY."

Write-Warning "To do this on multiple computers, please make a text file with just a computer name on each line, see computesr_template.txt for more."
#need to map these since the filepath that windows explorer grabs is not unc path (looks like J:\temp\user\file.txt and not \\files\temp\user\file.txt)
#do this if the text file lives at a UNC path.
New-PSDrive -name "T" -PSProvider FileSystem -Root "\\files\folder\i_live_here\" -Persist


function Set-Windowskeys { 
    #grab txt file to parse, brings up a windows explorer
    Add-Type -AssemblyName System.Windows.Forms
    $browser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    Multiselect = $false
    Filter = 'TXT Files (*.txt)|*.txt'
    Title = "Choose the text file you would like to use"
    InitialDirectory = $true
    }
#Filename is the path for the file, Filenames property is the name of the file. (WHY MICROSOFT)
[void]$browser.ShowDialog();
$filepath = $browser.FileName;

$content = Get-Content -Path $filepath 
$lines = Get-Content -Path $filepath | Measure-Object -Line #gets number of lines so we can use that number for the progress bar
$i = 0 #counter for progress bar

foreach($computer in $content) { 
    Invoke-Command -ComputerName $computer -Credential $login -ScriptBlock { 
        slmgr -ipk $key #batch cmd, just google slmgr for more details
        $test_new_key = Get-ciminstance -ComputerName $computer -ClassName Win32_OperatingSystem | Select-Object caption
        }

        if($test_new_key -match "Enterprise") { 
        write-host -ForegroundColor Green "The key installation is successful on $computer."
            }
        elseif($test_new_key.caption.Length -lt 1) { #if psremoting fails out.
            write-host -ForegroundColor Red "$computer workstation was not reachable. Please make sure you can ping the computer
            and that it is turned on."
            }
        else { #if product key is different that microsoft windows 10 enterprise.
        Write-Host -ForegroundColor Red "$computer still has $($test_new_key.caption) as its current windows license."
        }
        $i++ #progress bar for user feedback
        Write-Progress -Activity "Installing Windows Keys..." -Status "installed $i of $($lines.lines) windows keys" -CurrentOperation $computer -PercentComplete (($i / $lines.Lines) * 100)
    }
}

$key = "windows-key-here"

#makes login for PSremoting
$username = read-host -Prompt "Username"
$password = read-host -AsSecureString "password"
$login = New-object System.Management.Automation.PSCredential -ArgumentList $username,$password

#the ini file will allow you to remote into multiple Pcs and make new lists without having to edit the main code each time.
$approval = Read-Host -Prompt "Use ini file to add windows key on multiple machine? [y/n]"

#sometimes I fat finger the y key, this helps us fat fingered people :) 
if($approval -match "Y|y|T|t|U|u") { 
    Set-Windowskeys
}
else {
    $computer = Read-Host -Prompt "computername? ex:computer-assetcodeXXX"
    Invoke-Command -ComputerName $computer -Credential $login -ScriptBlock { 
         slmgr.vbs -ipk $key
         $test_new_key = get-ciminstance -ComputerName $computer -ClassName Win32_OperatingSystem | Select-Object pscomputername,caption
    }
    if($test_new_key -match "Enterprise") { 
        write-host -ForegroundColor Green "The key installation is successful on $computer."
    }
    elseif($test_new_key.caption.Length -lt 1) { 
            write-host -ForegroundColor Red "$computer workstation was not reachable. Please make sure you can ping the computer
            and that it is turned on."
            }
    else {
        Write-Host "this host still has $($test_new_key.caption) as its current windows license."
    }
}

read-host -prompt   "press any key to continue..."