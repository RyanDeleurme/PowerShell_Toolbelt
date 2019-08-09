$domain = get-azureaduser -all $true | Where-Object {$_.userprincipalname -match "domain.com"} | Select-Object Objectid,userprincipalname,displayname

$membership = @()
$membership += foreach($user in $domain) #add the object we create to the membership array so we can export to CSV easily.
{ # azure uses object Ids to search for users and groups, so that is why we use it. 
    $test = Get-AzureADUserMembership -ObjectId $user.ObjectId | Select-Object displayname #the display name is the group name.
    [pscustomobject] @{ 
        "User" = $user.DisplayName
        "Memberships" = ($test.displayname | Out-String).Trim() #expands the excel row to make column easy to view
    }
}
$membership | Export-Csv -Path \\files\folder\path\user_groups.csv -NoTypeInformation