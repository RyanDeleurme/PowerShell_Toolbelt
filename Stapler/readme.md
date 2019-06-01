# Stapler
Stapler is a tool that helps daily automation checks, initial server deployment checks, and troubleshooting tool. You do not need to have every section in your template file, the script will skip over sections that are not in the ini file. Read Stapler1.1_template.ini on how to use Stapler, or see below on how to format the ini file and what you can do.

```ini
; Stapler 1.0 
; -----------
; Formatting an ini file for Stapler 1.0: 
;   Blank lines are ignored.
;   everthing with a ; is ignored as well. 
;   Sections are specified with brackets and will follow the same format below. 
;   If you are modifying the Stapler script, the functions are the same name as the sections.
;   key and value pairs should be specified as key=value, the sections below will explain how to format each key and value.
;   You should NEVER put "" around anything in the ini file, the regular expressions will read it as a string even if the key or value has spaces. 
;   Do not worry about having whitespace in the key=value pair.
;
; Valid sections that Stapler 1.0 can use: 
; ----------------------------------------
;
;    [Services] - This verifys the current state of the service specified along with the value in the ini file. Values could be "Running" "stopped" or "paused"
;                 Use the actual name of the service and NOT the display name (there is a difference).
;                 example: Spooler=Running
;
;    [Services_Startup] - this verifys the current startup type of the service specified along with the value in the ini file. Values could be Automatic, Disabled, or manual
;                         Use the actual name of the service and NOT the display name (there is a difference).
;                         cmdlet used: get-service -name
;                         Ex: Spooler=Disabled
;
;    [Mapped_Drives] - Checks to see if the current network drives are present and persistent. DO NOT include the colon (:) with the drive letter. Put the network path for the value
;                      ex: J = \\files\temp
;
;    [Directory_Paths] - Check to see if the directory is present, DO NOT put file paths here. You DO NOT need to worry about spaces in the file path, the regular expression will wrap everything as a string.
;                        Specify "true" or "false" if you want the path to be present or not
;                        cmdlet used: test-path -path 
;                        ex: c:\users\ryand\I have spaces\=true
;
;    [File_Paths] - Checks to see if the file is present in the directory. Again, you DO NOT need to worry about having spaces in the path.Specify "true" or "false" if you want the file to be present or not
;                   cmdlet used: test-path -path 
;                   ex: c:\users\ryand\I have spaces\myfile.exe=true
;
;    [Programs] - Checks to see if the program is installed on the machine. The program name has to be EXACTLY like shown in appwiz.cpl. You may use the wildcard character (*) in the ini file as well. 
;                 If the program is 7-zip and appwiz.cpl reads 7-zip 16.02, put the program as 7-zip 16.02 or 7-zip*. The value does not really matter, just put installed. 
;                 this uses the registry and Get-ciminstance to find the program
;                 cmdlet used: get-itemproperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* , get-ciminstance -classname win32_product
;                 ex: myprogram*=installed | myprogram 1.3 (x64)=installed.
;
;    [Sched_Tasks] - Checks to see what the status is of the scheduled task. The name of the task is the key, value can be Running,Stopped, or Disabled.
;                    cmdlet used: Get-ScheduledTask -Name
;                    ex: Abobe Acrobat update task = Stopped
;
;    [Firewall] - Gets current windows firewall rules, use the FULL Displayname for the rule, then "true" or "false". Do not use a firewall group name as the rule, that will not work. 
;                 cmdlet used: Get-NetFirewallRule -Displayname
;                 ex: File and Printer Sharing (Echo Request - ICMPv4-In) = false 
;
;    [assoc] - gets the file extension association. Same as the batch assoc command, see assoc /? for more. 
;              cmdlet used: cmd /c assoc ________
;              ex: .log=txtfile | .txt=regfile
;
;    [ftype] - gets file type execuction associations. Shows the program the file type will open with. uses the ftype batch command, see ftype /? for more.
;              cmdlet used: cmd /c ftype _______
;              ex: txtfile=C:\Program Files (x86)\NotePad++\Notepad++.exe
;
;    [Processes] - gets the running process that is specified. Use the name that is listed in task manager, sometimes you need to put .exe on the end of the process and other times you do not.
;                  Specify running on the right, the script does not check the value, we just need something as the value.
;                  cmdlet used: get-process -Name -ErrorAction Silentlycontinue
;                  ex: powershell.exe=running
;
;    [env_var] - Checks the environment variables listed. Use the environment var. name on the left and the value on the right. can run "get-child item env:" to see all variables.
;                cmdlet used: get-childitem env:$_____
;                ex: USERDOMAIN=Mydomain
;
;    [nic] - gets the nics that are specified, can also use list=all to get all the nics and their information. NOTE: using list=all will take precedence over the other keys and values in thsi section.
;            specify whether you want the nic to be "connected" or "disconnected"
;            cmdlet used: get-netadapter -Name , Get-NetAdapter | Format-List Name,InterfaceDescription,MacAddress,Status,MediaConnectionstate,DriverInformation
;            ex: list=all , Ethernet0=connected
;
;    [Registry] - gets a registry property and sees if it has the intended value. This section can be a little confusing with the formatting of the key. First, put the file path to all the values (or properties whatever floats you boat).
;                 this could be specified as HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters. Now choose the value you would like (I am going to use Ntpserver.)
;                 instead of putting a \ after parameter, use a ".". see: HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters.NtpServer
;                 For the value, use the value you would like as NtpServer. This wierd formatting is due to powershell storing these values in the path as properties. 
;                 Do not worry about spaces in the registry path.
;                 ex: HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters.NtpServer=AD2.domain.com,0x1 AD1.domain.com,0x2
;                 cmdlet used: (get-itemproperty -path "$reg").$strval

;    Green output is good, Red is bad. Do not worry about spaces in the ini file, the regularexpressions will catch whitespace and put everything in a string.
;    See dummy.ini if you want more examples.

; Template
; --------

[Services]
; service_name=running
; service_name=stopped
; service_name=paused

[Services_Startup]
; service_name=Automatic
; service_name=Disabled
; service_name=manual

[Mapped_Drives]
; drive_letter= \\my\path\here

[Directory_Paths]
; c:\users\ryand\path\anotherpath=true

[File_Paths]
; c:\users\ryand\path\anotherpath\myfile.ps1=true

[Programs]
; another reminder, use the exact name of the program (from appwiz.cpl), you can use the * character as well.
; 7-zip*=installed
; myprogram 16.02=installed

[Sched_Tasks]
; my_task=stopped
; my_task=running
; my_task=disabled

[Firewall]
; reminder to use the full displayname of the rule, do not use firewall groups as well. 
; use true or false if you want the rule to be on or off.
; my firewall rule=true 
; my firewall rule=false

[assoc]
; .txt=textfile
; .sql=textfile

[ftype]
; txtfile=C:\Program Files (x86)\NotePad++\Notepad++.exe

[Processes]
;use name that displays on task manager, can depend on useing the extension in the name or not.
;program=running
;program.exe=running

[env_var]
; variable_name=variable_value
; USERDOMAIN=Mydomain

[nic]
; using list=all will take precedence and will list all the nics, do not put if you just want to get specific nics. 
; specify connected or disconnected
; list=all
; Ethernet0=connected
; Ethernet0=disconnected.

[Registry]
; read valid sections if you are confused about formatting in this section.
; HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters.NtpServer=AD2.domain.com,0x1 AD1.domain.com,0x2
```
