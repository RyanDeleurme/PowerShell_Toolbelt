<#
The purpose of this script is to export the users from Azure active directory 
into a csv file stored c:\mypath\here with their first/last name, display name, 
user principal name, and emails. Then create AD users based off the properties and users
listed in that CSV file to provide members with one account to authenticate to YOUR applications
and services.
#>

Import-Module AzureAD
Import-Module ActiveDirectory
$username = "email@domain.com"
$message = "Type in the password for your O365 account"
$credentials = Get-Credential -UserName $username -message $message
$path = 'C:\path\folder'

#Create a variable for the date stamp on the csv file

$LogDate = get-date -f yyyy_MM_dd_hhmm

#Define CSV file path by adding on the name of the csv file to the user input path given above

$csvfile = $path + "AADUsers_$logDate.csv"
write-host "Your CSV file will be saved at this path location: '$csvfile' "

#Define global variables 
$AllAADUsers = @() #Array for Azure users pulled to CSV file
$newADUsers = @() #Array for configured properties of Azure AD users to be created into AD users
$domain = "@domain.onmicrosoft.com" 
$ADServer = 'AD.domain.local'
$OU = Get-ADOrganizationalUnit -server $ADServer ` -SearchBase "OU=AzureGuestAccounts,DC=domain,DC=local" -Filter *  #Specifies the OU that new users will be created in
Connect-AzureAD -Credential $credentials

#Pull guest users from Azure, with the listed properties below, then add these users to the AllAADUsers array
$AADUsers = Get-AzureADUser -Filter "Usertype eq 'guest'" -All $true | Select-Object DisplayName,GivenName, Surname, UserPrincipalName, mail, Othermails
$AllAADUsers += $AADUsers


#loop through each user stored in the AllAADUsers, pull the properties of each to modify for AD user creation.
foreach ($user in $AllAADUsers){
    $lastname = $user.surname 
    $firstname = $user.GivenName
    $REGemail = $user.Mail #inteded to hold the NCPA domain emails
    $ALTemail = $user.OtherMails #intended to hold the original member email
    $UserName = $user.userPrincipalName #used to link the AD and AAD profiles 
    $displayname = $user.DisplayName
    if ($firstname.length -lt 3){  #this if-statement checks to see if the first name property is null 
        $seperator = " "
        $name = $displayname.split($seperator) #if the property is null, we take the display name (we know that isnt null) and split it
        $user.givenname = $name[0] #assign first name from the first half of the split
        $user.surname = $name[1]   #assign last name from the second half of the split   
        if ($REGemail.length -lt 3){  #this if-statement checks to see if the email property is null
            $seperator = "@"
            $name = $ALTemail.split($seperator) #if email is null, alternate isnt. So we split the alternate email [test@yahoo.com = test    @yahoo.com]
            $user.Mail = $name[0] + $domain #here we slap on the ncpa email domain so each user has their original email and an NCPA email 
            $newADUsers += $user
        }elseif ($ALTemail.length -lt 3){  #this if-statement checks to see if the alternate email property is null
            $seperator = "@"
            $user.OtherMails = $REGemail  #copy the member email to the alternate email property. We are storing NCPA domain email in mail property
            $name = $REGemail.split($seperator)
            $user.Mail = $name[0] + $domain
            $newADUsers += $user
        }else{ #if both email fields are populated, slap on the ncpa domain for the mail property
            $seperator = "@"
            $name = $REGemail.split($seperator) 
            $user.Mail = $name[0] + $domain
            $newADUsers += $user #this line 
        }
    }
    $seperate = "@"
    $name = $UserName.split($seperate) #split the user principal name at the '@' to store in 'User Logon Name' in AD
    $user.UserPrincipalName = $name[0] + $domain
}

#below we generate a random password for the AD user, 16 characters long (x,y)  x=how long the password will be y=minimum number of non-aplhanumeric values included
$generator = [String][System.Web.Security.Membership]::GeneratePassword(16,2) 
$password = ConvertTo-SecureString -String $generator -asPlainText -Force  #without the convertto, -asPlainText, and -Force this might throw an error...


function AADUsersToADUsers { #this function pulls the properties of each user in newADUsers array to create new users in AD
    foreach ($user in $newADUsers) { 
        $ADlastname = $user.surname #defined for lastname to be used in AD
        $ADfirstname = $user.GivenName #defined for firstname to be used in AD
        $ADUserName = $user.UserPrincipalName #defined for UPN to be used in AD (logon)
        $ADemail = $user.OtherMails #their memeber email to be placed in AD
        $ADdisplayname = $user.DisplayName #define for displayname to be used in AD
        #creates new user with these conditions
        New-ADUser -Name "$ADdisplayname" -DisplayName "$ADdisplayname" -GivenName "$ADfirstname" -Surname "$ADlastname" -AccountPassword $password -Path $OU -EmailAddress "$ADemail" -ChangePasswordAtLogon $false -Enabled $true -UserPrincipalName $ADUserName -Description "$ADdisplayname on-prem AD account from Azure" -PasswordNeverExpires $true
    }
}
AADUsersToADUsers
write-host "Your .CSV file export is complete, check '$csvfile' "

$newADUsers |
			Select-Object @{Label = "First Name";Expression = {$_.GivenName}},
            @{Label = "Last Name";Expression = {$_.Surname}},
			@{Label = "Display Name";Expression = {$_.DisplayName}},
            @{Label = "User Name";Expression = {$_.UserPrincipalName}},
            @{Label = "Email";Expression = {$_.Mail}},
			@{Label = "Alternate Email";Expression = {$_.OtherMails}} |
			Export-Csv -Path $csvfile -NoTypeInformation
			
write-host "Your .CSV file export is complete, check '$csvfile' "   
