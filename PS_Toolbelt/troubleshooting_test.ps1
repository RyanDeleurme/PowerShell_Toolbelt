Function Fix_Problems { 
    #this will use the troubleshootingpack module made from the scritping guy and it is approved by microsoft.
    #I will link the full artile on the cmdlet: https://devblogs.microsoft.com/scripting/use-powershell-to-troubleshoot-your-windows-7-computer/
    Import-Module -Name TroubleshootingPack

    $currentdate = Get-date -Format yyyy-MM-dd
    $packs = @("Power","Printer","WindowsUpdate") #troubleshooting packs that I think will work the best.
    $result_name = "$Env:computername" + "_$currentdate"
    Write-Host -ForegroundColor Green "Analyzing Issues..."

    foreach($pack in $packs) {
        $Diag_path = "C:\Windows\diagnostics\system\$pack"

        switch($pack) { 
            "Power" { 
                [System.IO.Directory]::CreateDirectory("\\files\folder\path\$result_name\$pack")
                Get-TroubleshootingPack -Path $Diag_path | Invoke-TroubleshootingPack -Result "\\files\folder\path\$result_name\$pack" -Unattended
            }
            "Printer" { 
                [System.IO.Directory]::CreateDirectory("\\files\folder\path\$result_name\$pack")
                Get-TroubleshootingPack -Path $Diag_path | Invoke-TroubleshootingPack -Result "\\files\folder\path\$result_name\$pack" -Unattended
            }
            "Windowsupdate" { 
                [System.IO.Directory]::CreateDirectory("\\files\folder\path\$result_name\$pack")
                Get-TroubleshootingPack -Path $Diag_path | Invoke-TroubleshootingPack -Result "\\files\folder\path\$result_name\$pack" -Unattended
            }
        } 
        #result pipes the result files out to the location specified, unattented runs the troubleshoot without user input.
        #you can do user input, but for now I would like to test the script without it
    }
    #will remove temp files.
    Remove-Item -Path $env:TEMP -Recurse -Force -ErrorAction SilentlyContinue
    start-sleep -Seconds 2
    #sleep so it looks like the program is working hard
    Write-Host -ForegroundColor Green "Your workstation has been anaylzed for potential issues. Restarting you computer now...."
    start-sleep -Seconds 3
    #Restart-Computer -Force 
}

Function Log-Description { 
#this function logs the descrition of the issue they were having so we can look at it.
$currentdate = Get-date -Format yyyy-MM-dd
$fileoutput_name = "Log_$env:COMPUTERNAME" + "_$currentdate" + ".txt"
$result_name = "$Env:computername" + "_$currentdate"
$path = "\\files\folder\path\$result_name\$fileoutput_name"
#create directory to live
[System.IO.Directory]::CreateDirectory("\\files\folder\path\$result_name")

$value = @"
Computer:$env:COMPUTERNAME user:$env:USERNAME
Description: 
$Global:Description_TextBox
"@ #do not move this string operator over, it cannot have whitespace in front of it. (it will break)
#will create the file and place the description body from the GUI in the file.
Set-Content -Path $path -Value $value 
}

function MessageBox { 
    Add-Type -AssemblyName PresentationCore,PresentationFramework
    $ButtonType = [System.Windows.MessageBoxButton]::OkCancel
    $MessageIcon = [System.Windows.MessageBoxImage]::Asterisk
    $MessageBody = "This will restart your computer. Please make sure all of your documents and programs are saved before running.Click cancel if you do not want to run the potential fixes" 
    $MessageTitle = "WARNING"
    $Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
# This handles the ok/cancel buttons and decides the actions to happen, use the result variableto obtain the ok/cancel output.

Switch ($Result) { 
    "Ok" {
        Write-Host "you clicked ok. this is supposed to run a script now"
        Log-Description
        Fix_Problems
    }
    "Cancel" { 
        Write-Host "This will now close..."
        Start-Sleep -Seconds 2
        [void]$form.dispose()
    }
}

}
<# GUI, go to poshgui.com to build an easy gui for powershell#>
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '450,171'
$Form.text                       = "Self Help Analyzer"
$Form.TopMost                    = $false

$Description_TextBox             = New-Object system.Windows.Forms.TextBox
$Description_TextBox.multiline   = $true
$Description_TextBox.width       = 303
$Description_TextBox.height      = 102
$Description_TextBox.location    = New-Object System.Drawing.Point(18,39)
$Description_TextBox.Font        = 'Segoe UI,10'

$Descripttion_Label              = New-Object system.Windows.Forms.Label
$Descripttion_Label.text         = "Describe the issue you are experiencing"
$Descripttion_Label.AutoSize     = $true
$Descripttion_Label.width        = 25
$Descripttion_Label.height       = 10
$Descripttion_Label.location     = New-Object System.Drawing.Point(22,18)
$Descripttion_Label.Font         = 'Segoe UI,10,style=Underline'

$Restart_Button                  = New-Object system.Windows.Forms.Button
$Restart_Button.text             = "Analyze"
$Restart_Button.width            = 97
$Restart_Button.height           = 79
$Restart_Button.location         = New-Object System.Drawing.Point(338,51)
$Restart_Button.Font             = 'Segoe UI,10,style=Bold'

$Form.controls.AddRange(@($Description_TextBox,$Descripttion_Label,$Restart_Button))

<# Event Handlers#>

$Restart_Button.Add_click({
    $Global:Description_TextBox = $Description_TextBox.Text;
    Messagebox
})

[void]$form.ShowDialog()