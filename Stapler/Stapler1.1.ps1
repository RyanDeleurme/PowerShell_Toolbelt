<#Stapler 1.1
--------------
Please ready stapler_1.1 template for information on how to make the ini file. 
#>
param(
[Parameter(Mandatory=$false,ValueFromRemainingArguments=$true)]
[string]
$inipath
)
#grab ini file to parse.
Add-Type -AssemblyName System.Windows.Forms
$browser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    Multiselect = $false
    Filter = 'INI Files (*.ini)|*.ini'
    Title = "Choose the ini file you would like to use"
    InitialDirectory = $true
}
#prompts for dialog box is the parameter is not met. 
if($inipath.Length -lt 1) { 
[void]$browser.showdialog()
#saves path for file selected.
$inipath = $browser.Filename;
} 
$ErrorActionPreference="silentlycontinue"
function Services {
  foreach($key in $ini.Services.Keys) { 
    $currentstatus = Get-Service -Name $key | Select-Object Name,Status
    if ($currentstatus.Status -eq $ini.Services.$key) {
        Write-Host -ForegroundColor Green "The $key service current status is $($currentstatus.Status)"
      }
    else { 
      Write-Host -ForegroundColor Red "$key current status is $($currentstatus.Status), when it should be $($ini.Services.$key)"
      }
    } 
}

function Services_Startup { 
  foreach ($servicestartup in $ini.services_startup.keys) { 
    $startup = Get-Service -Name $servicestartup | Select-Object Name,StartType
    if($Startup.StartType -eq $ini.Services_Startup.$servicestartup) { 
      Write-Host -ForegroundColor Green "The $servicestartup service startup type is $($startup.starttype)."
    }
    else {
      Write-Host -ForegroundColor Red "The $servicestartup service startup type is $($startup.starttype), when it should be $($ini.services_startup.$servicestartup)."
    }
  }
}

function Mapped_Drives { 
  foreach($MDKey in $ini.Mapped_Drives.Keys) { 
    $current_share_drive = Get-PSDrive -Name "$MDKey" -PSProvider FileSystem -ErrorAction SilentlyContinue | Select-Object DisplayRoot 
    if ($current_share_drive.DisplayRoot -eq $ini.Mapped_Drives.$MDKey) { 
      Write-Host -ForegroundColor Green "The $MDkey`: drive is currently mapped. The root is $($ini.Mapped_Drives.$MDKey)."
    } 
    else {
      Write-Host -ForegroundColor Red "The $MDKey`: drive is not currently mapped."
    }
  }
}

function Directory_Paths { 
  foreach($pathkey in $ini.Directory_Paths.Keys) { 
    $testpath = Test-path -Path "$pathkey"
    if ($testpath -eq $ini.Directory_Paths.$pathkey) { 
      Write-Host -ForegroundColor Green "The $pathkey Directory is present on this machine."
    }  
    else { 
      Write-Host -ForegroundColor Red "The $pathkey directory is not present on this machine."
    }
  }
}

function File_Paths  { 
  foreach($filekey in $ini.File_Paths.Keys) { 
    $testfile = test-path -Path "$filekey"
    if($testfile -eq $ini.File_Paths.$filekey) { 
      Write-Host -ForegroundColor Green "The $filekey file is present on this machine."
    }
    else { 
      Write-Host -ForegroundColor Red "The $filekey file is not present on this machine."
    }
  }
}

function Programs { 
  foreach($programkey in $ini.Programs.Keys) { 
    $testprogram = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "$programkey"} | Select-Object Displayname,DisplayVersion
    if ($testprogram.DisplayVersion.length -gt 1 -or $testprogram.DisplayName.length -gt 1 ) { 
      Write-Host -ForegroundColor Green "$programkey is installed on this machine."
    }
    elseif(!($testprogram.length -gt 1)) { 
        $testprogram = get-ciminstance -ClassName win32_product | Select-Object Name
        if ($testprogram.Name -like "$programkey") { 
            Write-Host -ForegroundColor Green "$programkey is installed on this machine."
            } 
        else { 
        Write-Host -ForegroundColor Red "$programkey is not installed on this machine."
        }  
        }
    else {
      Write-Host -ForegroundColor Red "$programkey is not installed on this machine."
    }
  }
}

function Sched_Tasks { 
  foreach($STkey in $ini.Sched_Tasks.Keys) { 
    $testtask = Get-ScheduledTask -TaskName "$STkey" | Select-Object State
    if($testtask.State -eq $ini.Sched_Tasks.$STkey) { 
      Write-Host -ForegroundColor Green "The state of the task $STKey is $($testtask.state)."
    }
    else {
      Write-Host -ForegroundColor Red "The state of the task $STkey is $($testtask.state), when it should be $($ini.Sched_Tasks.$STkey)."
    }
  }
}

Function Firewall { 
  foreach($FirewallKey in $ini.Firewall.Keys) { 
  try { 
    $testfirewall = Get-NetFirewallRule -DisplayName "$FirewallKey" | sort-object -unique Enabled
        if($testfirewall.Enabled -eq $ini.Firewall.$FirewallKey) {
      Write-Host -ForegroundColor Green "The $firewallkey rule status is $($testfirewall.enabled)."
    }
  else  { 
    write-host -foregroundcolor Red "The $firewallkey rule status is $($testfirewall.enabled), when it should be $($ini.Firewall.$firewallKey)."
}
}
  catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException]{ 
      Write-Host -ForegroundColor Red "There is no firewall rule for $firewallkey. Check the firewall to verify."
    }
  }
}
function assoc { 
  foreach ($extensionkey in $ini.assoc.keys) { 
    $testassoc = cmd /c assoc $extensionkey
    $extension,$type = $testassoc -split "="
    if($type -eq $ini.assoc.$extensionkey)  {
      Write-Host -ForegroundColor Green "The association of $extension is $type."
    }
    else {
      Write-Host -ForegroundColor Red "the association of $extension is $type, when it should be $($ini.assoc.$extensionkey)."
    }
  }
}

function ftype { 
  foreach($filetype in $ini.ftype.keys) { 
    $testftype = cmd /c ftype $filetype
    $extension2,$dummytype2 = $testftype.split("=")
    $anotherdummytype2 = $dummytype2 -replace '%1', '' #output gives us a %1 or a "%1", this takes out the %1
    $replacedummytype2 = $anotherdummytype2 -replace '"','' #this takes out the quotes of the %1 and the quotes on some of the outputs of the file types. 
    $type2 = $replacedummytype2.trim() #removes extra whitespace in output. 
    if ($type2 -like $ini.ftype.$filetype) { 
      Write-Host -ForegroundColor Green "the filetype of $extension2 is $type2."
    }
    else {
      Write-Host -ForegroundColor Red "The filetype of $extension2 is $type2, when it should be $($ini.ftype.$filetype)."
    }
  }
}

function Processes { 
  foreach($process in $ini.Processes.Keys) { 
    $testprocess = Get-Process -Name $process -ErrorAction SilentlyContinue | Sort-Object -Unique StartInfo,StartTime
    if ($null -eq $testprocess) { 
      Write-Host -ForegroundColor Red "The $process is not running."
    }
    else { 
      Write-Host -ForegroundColor Green "The $process  has been running since $($testprocess.starttime)."
    }
  }
}

function env_var { 
  foreach($var in $ini.env_var.Keys){ 
    $returnvar = Get-ChildItem env:$var | Select-Object -ExpandProperty Value
    if($returnvar -eq $ini.env_var.$var) { 
    Write-Host -ForegroundColor Green "$var=$returnvar"
    }
    else {
      Write-host -ForegroundColor Red "There is no environment variable for $var."
    }
  }
}

function nic { 
  foreach($adapter in $ini.nic.Keys) { 
    if($adapter -like "list") { 
      Get-NetAdapter | Format-List Name,InterfaceDescription,MacAddress,Status,MediaConnectionstate,DriverInformation
      break
    }
    $testadapter = Get-NetAdapter -Name "$adapter" | Select-Object MediaConnectionState
    if($testadapter.MediaConnectionState -eq $ini.nic.$adapter) { 
      Write-Host -ForegroundColor Green "The $adapter NIC is currently $($testadapter.Mediaconnectionstate)."
    }
    else {
      Write-Host -ForegroundColor Red "The $adapter NIC is currently $($testadapter.Mediaconnectionstate), when it should be $($ini.nic.$adapter)."
    }
  }
}

function registry { 
  foreach($regval in $ini.registry.Keys) { 
    try {
    $reg,$strval = "$regval" -split "[.]"
    $testreg = (Get-ItemProperty -Path "Registry::$reg").$strval
    if($testreg -eq $ini.registry.$regval) { 
      Write-Host -ForegroundColor Green "There is a key entry for $reg, $strval=$testreg."
    }
    else {
      Write-Host -ForegroundColor Red "There is a key entry for $reg, but $strval is not $($ini.registry.$regval), it is $strval."
      }
    } #error message for when the path is no found. 
  catch [Microsoft.PowerShell.Commands.GetItemPropertyCommand] { 
    Write-Host -ForegroundColor Red "There is no path for $reg in the current registry. Please check your ini file to see if you formatted the path correctly. See config_template.ini for more details."
    }
  }
}

  $ini = @{}
  $file = "$inipath"

  switch -regex -file $file {
    "^\[(.+)\]\s*$" {
      $section = $matches[1].Trim()
      $ini[$section] = @{}
    }
    "^\s*([^#].+?)\s*=\s*(.*)" {
      $Key,$value = $matches[1..2].Trim()
      <#if($key -contains "OracleService") { 
        $ini.Services["$key$env:ora_db_name"] = $value 
      }
      if($key -contains "OracleService") { 
        $ini.Services_startup["$key$env:ora_db_name"] = $value
        }
        if you have environment variables in the ini file, speicific situation
       skip comments that start with semicolon:#>
      if (!($Key.StartsWith(";"))) {
        $ini[$section][$Key] = $value.Trim()
      }
    }
  }
  #removes spooler entry so we can concatonate an env variable. 
  <#$ini["Services"].Remove("OracleService") | out-null
  $ini["Services_startup"].Remove("OracleService") | out-null
  if you want to remove certain keys from the sections. 
  #>
  $ini 
$blankline 
$blankline
#services function
$blankline = Write-Output "" #creates a blank line to have a better looking output. 
$sectiontest = $ini.Keys #this tests if the section is in the ini file. 

if ($sectiontest -like "Services") {
  Write-Output "Testing Services
----------------" 
  Services 
  $blankline 
}
else { 
    Write-Host "There is no section for services in this ini file."
    $blankline 
}

if ($sectiontest -like "Services_Startup") { 
  Write-Output "Testing Services Startup 
----------------------"
Services_Startup
  $blankline
}
else {
  Write-Host "there is no section for Services_Startup in this ini file."
  $blankline
}

#mapped_drives function
if ($sectiontest -like "Mapped_Drives") {
  Write-Output "Testing Mapped Drives
---------------------" 
  Mapped_Drives 
  $blankline 
}
else { 
  Write-Host "There is no section for MApped_Drives in this ini file."
  $blankline 
}

#Directory_Paths function
if ($sectiontest -like "Directory_Paths") { 
  Write-Output "Testing Directory Paths
-----------------------" 
  Directory_Paths 
  $blankline 
}
else { 
  Write-Host "There is no section for Directory_Paths in this ini file."
  $blankline 
}

if ($sectiontest -like "File_Paths") { 
  Write-Output "Testing File Paths
------------------" 
  File_Paths 
  $blankline 
}
else { 
  Write-Host "There is no section for File_Paths in this ini file."
  $blankline 
}

if ($sectiontest -like "Programs") { 
  Write-Output "Installed Programs
------------------" 
  Programs 
  $blankline 
}
else { 
  Write-Host "There is no section for Programs in this ini file."
  $blankline 
}

if($sectiontest -like "Sched_Tasks") { 
  Write-Output "Testing Scheduled Tasks
-----------------------" 
  Sched_Tasks 
  $blankline 
}
else { 
  Write-Host "There is no section for Sched_Tasks in this ini file."
  $blankline 
}

if($sectiontest -like  "Firewall") { 
  Write-Output "Testing Firewall Rules
----------------------" 
  Firewall 
  $blankline 
}
else { 
  Write-Host "There is no section for Firewall in this ini file."
  $blankline 
}

if($sectiontest -like "assoc") { 
  Write-Output "Testing File Associations
----------------------"
  assoc
  $blankline
}
else {
  Write-Host "There is no section for assoc in this ini file."
  $blankline
}

if ($sectiontest -like "ftype") { 
  Write-Output "Testing File Types
----------------------"
  ftype
  $blankline
}
else {
  Write-Host "there is no section for ftype in this ini file."
  $blankline
}

if ($sectiontest -like "Processes") { 
  Write-Output "Testing Processes
----------------------"
  Processes
  $blankline
}
else {
  Write-Host "there is no section for Processes in this ini file."
  $blankline
}
if($sectiontest -like "env_var") { 
  Write-Output "Testing Env. Variables
--------------------------"
env_var
$blankline
}
else{
  Write-Host "There is no section for env_var in this ini file."
}

if($sectiontest -like "nic") { 
  Write-Output "Testing NICS
-------------------"
nic
$blankline
}
else{
  Write-Host "There is no section for env_var in this ini file."
}

if($sectiontest -like "registry") { 
  Write-Output "Testing Registry Keys
--------------------------"
registry
$blankline
}
else{
  Write-Host "There is no section for Registry in this ini file."
  $blankline
}

Read-Host -Prompt "Press any key to continue..."