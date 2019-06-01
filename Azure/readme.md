# Azure
These are different scripts that involve Azure and have been useful to me in my work. See below on how to use each script.

## AAD-to-AD_Users
This is used to convert Azure accounts to on-prem AD accounts. I used this in an environment where we had a hybrid topology and needed
to append a different domain onto the email from the Azure account.
There are simple items to edit such as your email, domain,and AD servers in the file. Overall, this will create a user, generate a password
for them, and have the output generated to a CSV file for logging. The CSV file will look something like this: 

|Firstname   |Lastname   |Displayname   |Username   |Email   |Alt Email   |
|---|---|---|---|---|---|
|John   | Doe   |John Doe   |Johnd   |jond@domain.com   |johnd@domain.onmicrosoft.com   |

## Remove-AzureAcc
This script uses a CSV file that contains the name or the email of user you want to delete. The CSV is formatted like this: 

```CSV
name,email
john doe,johnd@domain.com
,johnd@domain.com
john doe,
```
You can put both fields in, or one of the fields in, the script will know if the name or email is NULL. Edit items such as log file path and 
CSV path.
