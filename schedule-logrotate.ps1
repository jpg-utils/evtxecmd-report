#schedule-logrotate.ps1
#Description: schedules the weekly rotation of log files of a standalone system to a specified directory,
#uses evtxecmd to create a full and an abbreviated csv,
#then uses getlogins.ps1 to format an html report.

#report location. Set to c:\temp\ for testing purposes. Should be set to a location only accessible by security and sysadmins
$reportdir = "c:\temp"

#script location- used to store scripts used for scheduled tasks. should be set to a location only accessible by security and sysadmins
$scriptdir = "c:\scripts\"

if (!(Test-Path $scriptdir)){
    "Script directory not found. Exiting"
    exit 1
}
Copy-Item .\new-loginreport.ps1 -Destination $scriptdir




#principal defines who the job runs as. Advise a service account- must have administrator permissions
$cred = Get-Credential -Message "Enter the account this will run as"


#$principal = New-ScheduledTaskPrincipal -userid "$(HOSTNAME.EXE)\$username" -LogonType Password 
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 3am
$settings = New-ScheduledTaskSettingsSet




$script = @'
    $date = Get-Date -Format ddMMMyy
    mkdir {{reportdir}}\$date
    wevtutil.exe cl application /bu:{{reportdir}}\$date\appplication$date.evtx
    wevtutil.exe cl system /bu:{{reportdir}}\$date\system$date.evtx
    wevtutil.exe cl security /bu:{{reportdir}}\$date\security$date.evtx

    #if evtxecmd is in path - make whole and abbreviated csv
    if (where.exe evtxecmd.exe){
    EvtxECmd.exe --inc 4624,4634,4625,4672,4648,4799,4720,4732,4724,1102,7045,104,4722 -d {{reportdir}}\$date --csv {{reportdir}}\$date\ --csvf abbreviatedcsv$date.csv
    EvtxECmd.exe -d {{reportdir}}\$date --csv {{reportdir}}\$date\ --csvf fullcsv$date.csv
    cd {{scripts}}
    .\new-loginreport.ps1 -csvpath {{reportdir}}\$date\abbreviatedcsv$date.csv -reportpath {{reportdir}}\$date\
}

'@

$script -replace "{{reportdir}}", $reportdir -replace "{{scripts}}", $scriptdir  | Out-File $scriptdir\test.ps1

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument " -file $scriptdir\test.ps1"

$task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings
Register-ScheduledTask RotateLogs_test -InputObject $task -User $cred.UserName -Password $cred.GetNetworkCredential().Password
