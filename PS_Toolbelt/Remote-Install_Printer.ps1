$servers = @("printservername1","printservername2" )
$printers = @()
$printers += foreach ($server in $servers) { 
    Get-Printer -ComputerName "$server" | sort-object  | Select-Object ShareName #this will fill the printers array from all the print servers
}

$VerbosePreference = 'silentlycontinue' #will suppress erorr messages
function Add-RemotePrinter {
    # Parameter help description
    $login = new-object System.Management.Automation.PSCredential -argumentlist $username,$password #creates login for PSremoting so the gui box does not pop up
    Invoke-Command -ComputerName "$Remote" -Credential $login -ScriptBlock { 
        Stop-Service -Name Spooler #stops print spooler so the printer installs correctly
        Write-Host -ForegroundColor Red -BackgroundColor Black "The print spooler service has stopped, removing current entries..." 
        Start-Sleep -Seconds 3
        Get-ChildItem "\\$Using:Remote\C`$\windows\system32\spool\printers" | Remove-Item #removes current entries in print spooler
        #installs printer chosen from the dropdown box
        #the using variable needs to be passed since the scriptblock scope is local, and you need to explicity state to use the global variable, if you do not, it will be null
        write-host "Installing printer "$Using:Box" on "$Using:Remote" " 
        Start-Service -Name Spooler
        rundll32 printui.dll PrintUIEntry /ga /n"\\$Using:Server\$Using:Box" /q /u <#installs printer per computer, NOT profile specific, /ga installs the printer, /n specifies the computer name
        /q is quiet so nothing pops up on the remote computer, /u uses the current drivers for the printer if they are already on the remote computer#>
        Write-Host -ForegroundColor Green -BackgroundColor Black "The Print Spooler Service is now running..." 
        Start-Sleep -Seconds 3
        Write-Host "$Using:box printer has been installed on $Using:remote."
        Start-Sleep -Seconds 5
         } 
}

function MessageBox { 
    Add-Type -AssemblyName PresentationCore,PresentationFramework
    $ButtonType = [System.Windows.MessageBoxButton]::OkCancel
    $MessageIcon = [System.Windows.MessageBoxImage]::Asterisk
    $MessageBody = "You have installed $Global:box printer on $Global:remote. If you do not wish to continue, please close out of both boxes."
    $MessageTitle = "Confirmation"
     
    $Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
if ($Choice -eq "ok")
    {    
    $form.dispose() } 
    Write-Host "$Result"
}
#creates form

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")  
$Form = New-Object System.Windows.Forms.Form    
$Form.Size = New-Object System.Drawing.Size(300,400)  
$Form.text = "Form Text Name"
$form.ShowInTaskbar  = $true
$Icon = [system.drawing.icon]::ExtractAssociatedIcon($PSHOME + "\powershell.exe") #PSHOME is the defualt directory for powershell (c:\windows\system32)
$Form.Icon = $Icon
$form.AcceptButton = $Button #sets the enter key to do the same thing as the button


#creates drop down box for printers array

#Print server dropdown box

$DropDownBox2 = New-Object System.Windows.Forms.ComboBox
$DropDownBox2.Location = New-Object System.Drawing.Size(20,50)
$DropDownBox2.Size = New-Object System.Drawing.Size(180,20)
$DropDownBox2.DropDownHeight = 200
$DropDownBox2.FlatStyle = 'Standard' 

foreach($server in $servers) { 
    $DropDownBox2.Items.Add($server) | Out-Null #populates the dropdownbox, specify out-null cause the console will output the count of the array
}
$form.controls.add($DropDownBox2)

#server dropdown box label

$labelserver = New-Object System.Windows.Forms.Label
$labelserver.Location = New-Object System.Drawing.Size(20,25) 
$labelserver.Text = "Print Server"
$labelserver.AutoSize | Out-Null
$form.controls.Add($labelserver)

$DropDownBox = New-Object System.Windows.Forms.ComboBox #creating the dropdown list
$DropDownBox.Location = New-Object System.Drawing.Size(20,100) #location of the drop down (px) in relation to the primary window's edges (length, height)
$DropDownBox.Size = New-Object System.Drawing.Size(180,20) #the size in px of the drop down box (length, height)
$DropDownBox.DropDownHeight = 200 #the height of the pop out selection box
$DropDownBox.FlatStyle = 'standard'
$form.controls.Add($DropDownBox) 

foreach($printer in $printers) { 
$DropDownBox.Items.Add($printer.ShareName)
}
#dropdownbox label 

$labelprinter = New-Object System.Windows.Forms.Label
$labelprinter.Location = New-Object System.Drawing.Size(20,75)
$labelprinter.Text = "Printers"
$labelprinter.AutoSize | Out-Null
$form.controls.Add($labelprinter) #this add the control to the form

#username Label

$labelusername = New-Object System.Windows.Forms.Label
$labelusername.Location = New-Object System.Drawing.Size(20,125) 
$labelusername.Text = "WRK Username"
$labelusername.AutoSize | Out-Null
$form.controls.Add($labelusername)

#username text box

$BoxUsername = New-Object System.Windows.Forms.TextBox
$BoxUsername.Size = New-Object System.Drawing.Size(180,20)
$BoxUsername.AcceptsTab = $true
$BoxUsername.Location = New-Object System.Drawing.Size(20,150) 
$form.Controls.add($BoxUsername)

#Password text box

$BoxPassword = New-Object System.Windows.Forms.MaskedTextBox #creates secure string textbox
$BoxPassword.Size = New-Object System.Drawing.Size(180,20)
$BoxPassword.AcceptsTab = $true
$BoxPassword.Location = New-Object System.Drawing.Size(20,200)
$BoxPassword.UseSystemPasswordChar = $true #hides plaintext to the user
$form.Controls.add($BoxPassword)

#password label

$labelpassword = New-Object System.Windows.Forms.Label
$labelpassword.Location = New-Object System.Drawing.Size(20,175) 
$labelpassword.Text = "Password"
$labelpassword.AutoSize | Out-Null
$form.controls.Add($labelpassword)

#remote computer textbox

$BoxRemote = New-Object System.Windows.Forms.TextBox
$BoxRemote.Size = New-Object System.Drawing.Size(180,20)
$BoxRemote.AcceptsTab = $true
$BoxRemote.Location = New-Object System.Drawing.Size(20,250)
$form.Controls.add($BoxRemote)

#remote computer label

$labelremote = New-Object System.Windows.Forms.Label
$labelremote.Location = New-Object System.Drawing.Size(20,225) 
$labelremote.Text = "Remote Computer"
$labelremote.AutoSize | Out-Null
$form.controls.Add($labelremote)

#button to work

$Button = New-Object System.Windows.Forms.Button 
$Button.Location = New-Object System.Drawing.Size(20,300) 
$Button.Size = New-Object System.Drawing.Size(80,30) #(x,y) length,height
$Button.Text = "Map"
$Button.Add_click({
    $Global:username=$BoxUsername.Text;
    $Global:remote =$BoxRemote.Text;
    $Global:Password = $BoxPassword.Text | ConvertTo-SecureString -AsPlainText -Force;
    $Global:Box = $DropDownBox.SelectedItem.tostring();
    $Global:server = $DropDownBox2.SelectedItem.ToString();
    Add-RemotePrinter;
    MessageBox
}) <#these global variables are created once the button is clicked, will take the text and selected objects from the form and use them in the scriptblock, need to use $Using:$myvariable
   so the variables will be inside the scope of the function, will be NULL unless you specify $Using in the scriptblock #>

#Enter key input for the remote computer text box

$BoxRemote.Add_Keydown({
    if ($_.KeyCode -eq "Enter") { 
        $Global:username=$BoxUsername.Text;
        $Global:remote =$BoxRemote.Text;
        $Global:Password = $BoxPassword.Text | ConvertTo-SecureString -AsPlainText -Force;
        $Global:Box = $DropDownBox.SelectedItem.tostring();
        $Global:server = $DropDownBox2.SelectedItem.ToString();
        Add-RemotePrinter;
        MessageBox
    }
})
 #this is another way to do the enter button for the textbox, but the example in the Form is easier

$button.Suspresskeypress = $true | Out-Null #will not make windows sound when pressed
$form.Controls.Add($Button) 

[void]$Form.showdialog() 