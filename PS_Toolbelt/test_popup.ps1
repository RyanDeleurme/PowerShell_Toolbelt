param ( 
    [string]$text,
    [string]$MessageType #these are parameters to help pass the variables from Remote-Toast.ps1

)
if($MessageType -like "Informational") { 
    Add-Type -AssemblyName PresentationCore,PresentationFramework
    $ButtonType = [System.Windows.MessageBoxButton]::OkCancel
    $MessageIcon = [System.Windows.MessageBoxImage]::Asterisk
    $MessageBody = "this is a test."
    $MessageTitle = "Confirmation"
     
    [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
} 
elseif ($messagetype -like "Error") {
    Add-Type -AssemblyName System.Windows.Forms 
            $global:balloon = New-Object System.Windows.Forms.NotifyIcon
            $path = (Get-Process -id $pid).Path
            $balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
            $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Error
            $balloon.BalloonTipText = "$text"
            $balloon.BalloonTipTitle = "Attention $env:USERNAME"
            $balloon.Visible = $true 
            $balloon.ShowBalloonTip(10000000)
}
else { #warning
    Add-Type -AssemblyName System.Windows.Forms 
            $global:balloon = New-Object System.Windows.Forms.NotifyIcon
            $path = (Get-Process -id $pid).Path
            $balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
            $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
            $balloon.BalloonTipText = "$text"
            $balloon.BalloonTipTitle = "Attention $env:USERNAME"
            $balloon.Visible = $true 
            $balloon.ShowBalloonTip(10000000)
}