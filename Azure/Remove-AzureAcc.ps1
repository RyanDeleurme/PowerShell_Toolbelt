<#Delete Azure Users#>
Import-Module -AzureAD
connect-AzureAD
$array=@()
$csv = Import-Csv -Path "C:\path\folder\Remove\Azure.csv"
foreach($item in $csv) { 
#uses $item.name for first and last name or $item.Email for email address. checks to see if name is null, then can use the email address. 
if($item.name.length -gt 1) { 
$search =  Get-AzureADUser -All $true | Where-Object {$_.DisplayName -like "$($item.name)"} | select-object DisplayName,ObjectID
$array+=$search #add to array
$search.Displayname #echo the name that the search found
}
else {
    $searchemail= Get-azureaduser -All $true | where-object {$_.Mail -like "$($item.Email)"} | select-object DisplayName,ObjectID
    $array+=$searchemail
    $searchemail.displayname
    }
} 
$approval = Read-Host "Are these the correct users you would like to delete? [y/n]"

if ($approval -match "[Y|y|t|T]") {
    foreach($value in $array) {     
    Remove-AzureADUser -ObjectId "$($value.ObjectID)" #need object ID to remove user. 
    Write-Host -foregroundcolor Green "$($value.Displayname) has been removed from Azure. "
    }
}
write-warning "If you would like to restore the user, you may do so through the web portal." #reminder that if you need to restore account, have to do it through web portal. 

$date=Get-date -Format yyyy-MM-dd
$filepath = "C:\path\folder\Remove\"
$output=$filepath + "Removed_Azure_Accounts" + "_$date" + ".txt"

$array | select-object @{Label="Account Name";Expression={$_.DisplayName}}, 
@{Label="ObjectID";Expression={$_.ObjectID}} | out-file	 -filepath c:\PSSCRIPT\Azure2\Remove\$output -append

write-host "the log file will be located at $output"