<# Test Site Ports Revised 1.0#>
#change this to the path you want, see site.connections.prod.ini on how to format (site_name = port #)
$inipath =  "\\files\path\folder\site.connections.prod.ini"
#declare hashtable

$ini = @{}
#regular expression from Stapler that will create and make hashtable simple.
  switch -regex -file $inipath {
    "^\[(.+)\]\s*$" {
      $section = $matches[1].Trim()
      $ini[$section] = @{}
    }
    "^\s*([^#].+?)\s*=\s*(.*)" {
      $Key,$value = $matches[1..2].Trim()
      # skip comments that start with semicolon:
      if (!($Key.StartsWith(";"))) {
        $ini[$section][$Key] = $value.Trim()
      }
    }
  }
#declare results array
$results = @()
$i = 0 #counter for progress bar

#we feed the foreach loop to the array since it is faster and will get every output, if you feed the array inside the loop, it will only save the first output and not the rest.
#if that makes sense ¯\_(ツ)_/¯, read this article for more: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_arrays?view=powershell-6
#the connection is the key, the $ini.connections.$connection is the value

$results += foreach($connection in $ini.Connections.Keys) {
Test-NetConnection -ComputerName $connection -port $ini.connections.$connection | select-object -property ComputerName, RemoteAddress, TcpTestSucceeded, RemotePort, InterfaceAlias
$i++
Write-Progress -Activity "Testing Site Connection Locations..." -Status "Scanned $i of $($ini.Connections.Count) connections" -CurrentOperation $connection -PercentComplete (($i / $ini.Connections.Count) * 100)
}
#declare more arrays for end output
$success = @()
$failure = @()

#fill arrays if the test succeeded or not

foreach($test in $results) { 
if($test.TcpTestSucceeded -eq "true") { 
    $success += $test | Select-Object ComputerName, RemoteAddress, TcpTestSucceeded, RemotePort, InterfaceAlias
}
else { 
    $failure += $test | Select-Object ComputerName, RemoteAddress, TcpTestSucceeded, RemotePort, InterfaceAlias
  }
}
#output arrays, use -wait to prevent both boxes closing when running script

$success | Out-GridView -Title "Successful Site Connections" -Wait 
$failure | Out-GridView -Title "Failed Site Connections" -Wait


#another way to do this with objects instead of ini files
<#
$object = [pscustomobject] @{ 
  name = "isstudent-e1453","Chuckc-a00210"
  port = 3389,3389
}
$results = @()
$results += foreach($connection in $object) {
Test-NetConnection -ComputerName $connection.name -port $connection.port | select-object -property ComputerName, RemoteAddress, TcpTestSucceeded, RemotePort, InterfaceAlias
}
$results #>