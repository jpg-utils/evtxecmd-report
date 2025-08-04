#Get-loginstats.ps1
#Description: A powershell script that leverages the output of evtxecmd

$logins = Get-Content .\20250802191547_EvtxECmd_Output.csv `
    | ConvertFrom-Csv


$output = @"
<!doctype html>
<html lang="en-US">
  <head>
    <meta charset="utf-8" />
    <title>MUSA Login Audit</title>
    <style>
    body {text-align: center;}
    table {margin-left: auto; margin-right:auto;}
    td {padding-left: 8px; padding-right: 8px;}
    </style>
  </head>
  <body>

"@

#time user logged in
$output = $output + ($logins `
    | where eventid -eq 4624 `
    | where payloaddata2 -eq "LogonType 10" `
        | select timecreated, @{Name = "logon user";expression = {$psitem.payloaddata1 -replace "Target: ",""}} `
        |ConvertTo-Html -As Table -Fragment -PreContent "<h2>Desktop logon times</h2>" -PostContent "<br><br>")

#time user logged out
$output = $output + ($logins `
    | where eventid -eq 4634 `
    | where payloaddata1 -match (HOSTNAME.EXE) `
        | select timecreated, @{Name = "user logging out";expression = {$psitem.payloaddata1 -replace "Target: ",""}} `
        | ConvertTo-Html -as Table -Fragment  -PreContent "<h2>Desktop logout times</h2>" -PostContent "<br><br>")

#times of failed login
$output =$output + ($logins `
    | where eventid -eq 4625 `
        | select timecreated, username, @{Name ="Logon failure reason";expression={$psitem.payloaddata4 -replace "FailureReason2: ",""}} `
        | ConvertTo-Html -as Table -Fragment  -PreContent "<h2>Failed Authentication</h2>" -PostContent "<br><br>")

#access of network share or powershell remoting
$output = $output + ($logins `
    | where eventid -eq 4624 `
    | where payloaddata2 -eq "LogonType 3" `
        | select timecreated, @{Name = "logon user";expression = {$psitem.payloaddata1 -replace "Target: ",""}} `
        | ConvertTo-Html -as Table -Fragment  -PreContent "<h2>Powershell Logon or network share access</h2>" -PostContent "<br><br>")

#admin priv logon
$output = $output + ($logins `
    | where eventid -eq 4672 `
    | where username -match (HOSTNAME.EXE)  `
        | select timecreated, @{Name = "logon user";expression = {$psitem.username -replace "\([^)]*\)",""}} `
        | ConvertTo-Html -as Table -Fragment  -PreContent "<h2>Account Logins with Local Admin Rights</h2>" -PostContent "<br><br></body>")

$output | Out-File .\report.html

#other items to explore- 5140? Iffy for a musa
#Tasks scheduled 4698 enabled 4700 or deleted 4699?

#services -change to start type 7040, installed 4697


Invoke-Item .\report.html