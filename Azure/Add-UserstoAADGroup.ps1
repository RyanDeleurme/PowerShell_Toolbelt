<# Add multiple people to a group in Azure#>
#look these groups up in AD or AAD portal.
$To_add = Read-Host -Prompt "Group to add users to:"
$add_id = Get-AzureADGroup -SearchString $To_add | Select-Object -ExpandProperty objectid
#groups to pull users from and add to $to_add group in azure.
$groups = Get-Content -Path c:\files\path\groups.txt
$Ids = @()
$userIDS = @()
$already_in_group = @()
$added_to_group = @()
#get object IDs

$ids += foreach($group in $groups) { 
    Get-AzureADGroup -SearchString $group | Select-Object -ExpandProperty objectid
}
#get user object IDs to add to the group, this is how azure does this.
$userIDS += foreach($id in $Ids) { 
    Get-AzureADGroupMember -ObjectId $id | Select-Object displayname,objectid
}

foreach($user in $userIDS) { 
    try { 
    Add-AzureADGroupMember -ObjectId $add_id -RefObjectId $user.ObjectId -ErrorAction Stop
    $get_member = Get-AzureADGroupMember -ObjectId $add_id | Select-Object displayname
#we use -match so the if statement will check the whole array of names to see if the username matches the one in the group.
#the catch block adds them to another group.
    if($get_member -match $user.DisplayName) { 
            $added_to_group += $user
            Write-Host -ForegroundColor "User $($user.DisplayName) has been added to $to_add"
        }
    }
    catch [Microsoft.Open.AzureAD16.Client.ApiException] { 
        $already_in_group += $user
    }
}

$already_in_group | Out-GridView -Wait -Title "These users have already been added to the $to_add group."
$added_to_group | Out-GridView -Wait -Title "These Users have been added to the Azure group $to_add."

return $userIDS