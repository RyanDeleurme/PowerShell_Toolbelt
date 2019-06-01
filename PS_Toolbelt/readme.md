## Install-RemoteMSI
Installs MSI files remotely, however not all MSI files work. Items to edit: 
* `line 6` for the root path of the installs folder. We use this to "frankenstein" the UNC path for the install (if install is from a 
shared network folder)
* `line 25` Root path for installs network share

## New-Apps
Just a hodge podge of different changes I make on workstations that vary from company to company. Browse through the file to see if you would like to implement any 
of the functions into your own scripts. 

## Remote-Install_Printer

Brings up a GUI box that will install a printer to a remote machine for a all users. It will look like this: 

![remote printer][logo]

[logo]: https://github.com/RyanDeleurme/PowerShell_Toolbelt/blob/master/images/form.png "Form"

Items to edit: 
* `line 1` for the print servers, do not add \\\ to them, just the name

## Set-WindowsKey

Sets a windows key to a remote machine, works for Enterprise only. You can edit the file as well to fit other versions of windwos as well since it only looks for the enterprise string. You can do multiple computers to change the key on or just one. IF you would like to do multiple computers, make a textfile of just the names like: 

```txt
comptuer1
computer2
computer3
```
Items to edit: 

* `line 11` for text file (if it lives on a shared folder.)
* `line 52` for windows enterprise key.

## Remote-Toast

Make personalized message and send it to all computers that are specified. Will make a toast message on the remote computer. This works on both Windows 10 and Windows 7. Make sure test_popup.ps1 is on a network share that everyone is able to get to. 

Form Layout: 
![layout][logo3]

[logo3]: https://github.com/RyanDeleurme/PowerShell_Toolbelt/blob/master/images/toast_form.PNG  "Toast Form"
<br/>
Toast Message: 
![toast][logo2]

[logo2]: https://github.com/RyanDeleurme/PowerShell_Toolbelt/blob/master/images/toast_msg.PNG

Items to edit: 
* `line 53` Edit UNC path for test_popup.ps1.
* `line 66` edit different AD paths for the computers you would like to see the toast message on.

## RemoteEXE

Installs EXE files remotely, however not all EXE files work. Items to edit: 
* `line 6` for the root path of the installs folder. We use this to "frankenstein" the UNC path for the install (if install is from a 
shared network folder)
* `line 25` Root path for installs network share

## Restart-Printspooler

Restarts printspooler on remote computer. Requires Computername of the remote computer. Do not need to edit the ps1 file. 

## Set-OfficeKey

Sets office product key on remote computer, looks for office15/16 32/64 bit. Uses a vbs script provided in teh same folder the Office install lives at. Download and install teh module from the folder that the download put the ps1 file in. Use example: 

```Powershell
Set-OfficeProductKey JohndAdmin remotePC
```
Items to edit: 
* `lines 45,58,71,84` for the office key. 
