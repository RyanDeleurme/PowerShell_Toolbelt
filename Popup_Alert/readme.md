# Alert Box

My work wanted a way to notify the whole building of an emergency if the email went down, this is what I came up with. It looks similar to Remote-Toast.ps1 in the PS_Toolbelt but with a few tweaks. This will popup a full screen image of the emergency on the remote computers specified. This is currently a test script, but add in the AD commands from Remote-Toast if you want to pull computers from AD. Make sure popup_box.ps1 is in a remote location that everyone can reach. Items to add: 
* `lines 8,28,50` preview image files for popup.
* `line 75` remote path for popup_box.ps1
* ` line 88` computers to test popup on.

On Popup_box.ps1, edit these items: 

* `lines 9,31,55` for image files.

Alert Form: 
![Alert_Form][logo]

[logo]: 
