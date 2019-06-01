## Cert.Loop.Final
Script to find all expected to expire computer certificates, I built this when implementing wired 802.1x authentication and wanted
a heads up if computer certs were about to expire and were not being re-enrolled with group policy.Items to edit: 

* `line 2-3` for username and password (see `line 1` on how to get encrypted password)
* `line 10` to adjust OU paths in AD
* `line 19-20` for file path outputs
* `line 27` for throttle limit on PSremoting
>Throttle limit is optional
* `line 72` different email properties like to,from,SMTP server

CSV File: 

|Computer_name   |Issuer   |Subject   |NotAfter   |Thumbprint   |Expires in (Days)   |
|---|---|---|---|---|---|
|mycomputer-AXXX   |CN=company,OU=this OU,O= my company inc,C=US   |CN=xxx-xxxx-xxx...   |10/5/2019 7:46:16 PM   |SJJJKJKNKV8958347583402   |165   |

## User.Store.Certs.Final
This script will pull **USER** store certificates, not *local machine* store certificates like the last script. This needs to be ran as a 
scheduled task from the user that you would like the user certificates from. For example, if I want to know Johnd's user certificates, 
Johnd needs to be the author of the scheduled task. Items to edit: 

* `line 8` file path output
* `line 42` for email settings.
The CSV will look like: 

|Computer_name   |Issuer   |Subject   |NotAfter   |Thumbprint   |Expires in (Days)   |
|---|---|---|---|---|---|
|mycomputer-AXXX   |CN=company,OU=this OU,O= my company inc,C=US   |CN=xxx-xxxx-xxx...   |10/5/2019 7:46:16 PM   |SJJJKJKNKV8958347583402   |165   |
