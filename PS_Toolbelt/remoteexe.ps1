Write-Warning -Message "Not all programs will work using this script."
#creates automated login
$WRKusername = Read-Host "username?"
$password = read-host -AsSecureString "password"
$login = New-object System.Management.Automation.PSCredential -ArgumentList $WRKusername,$password
$Root = "\\files\installs\all_software_installs" #root path so we can concatenate the strings for copying the install file, use this if you have installs on a shared folder
#dialog box
Add-Type -AssemblyName System.Windows.Forms
$browser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    Multiselect = $false
    Filter = 'EXE Files (*.exe)|*.exe' #only searches for exe files
    Title = "Choose the file you would like to install"
    InitialDirectory = $true
}
#prompts for dialog box
[void]$browser.showdialog()
#saves path and filename for the file selected
$filepath = $browser.Filename; #saves path of file, the path will no tbe UNC ex: will save as T:\software\installs\...
$Global:name = $browser.SafeFileName; #saves name of file 
$split,$realinstall = $filepath -split "installs" #split and combine with the $root variable to frankenstein the UNC path, each domain is different so you will have to change it
$GLobal:fullpath = "$Root"  + "$realinstall"
$computername = read-host "remote computer?" 
$session = New-PSSession -ComputerName "$computername" -Credential $login #need to create session and pre copy file to avoid double hop problem (another solution explained below)
Invoke-Command -ComputerName $computername -Credential $login { 
    New-PSDrive -Name "T" -Root "\\files\installs\" -PSProvider FileSystem
    $testpath = Test-Path -Path "c:\temp"
    if (!($testpath -eq $true)) { #if they do no have a folder temp, this will make one
        New-Item -ItemType Directory -Path "c:\temp\"
    }
}
Copy-Item -Path "$fullpath" -ToSession $session -Destination "c:\temp" -Force #after testing, without -force sometimes the whole file will not copy correctly, not sure if this needs a -credential switch or not. 
Start-Sleep -Seconds 3
write-host "installing program..."
invoke-command -ComputerName $computername -Credential $login {
    $installer = Start-Process -filepath "C:\temp\$Using:name" -wait -PassThru #use passthru so it will generate the exitcode
    if ($installer.ExitCode -eq 0) { 
        Write-Host -ForegroundColor Green "Installion has been successful...verify with the user as well to see if the program installed."
    } #if this does not work, PS will spit out more helpful error commands then "this thing did not install..."
} 
Start-Sleep -Seconds 3
Remove-PSSession $session