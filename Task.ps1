    # Create a scheduled task to run the script every day, at every startup or at logon
    $taskTriggers = @( 
        New-ScheduledTaskTrigger -Daily -At 00:01
        New-ScheduledTaskTrigger -AtStartup
        New-ScheduledTaskTrigger -AtLogon
    )
    $taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File $($MyInvocation.MyCommand.Path)"

    Register-ScheduledTask -TaskName 'NASA-pic' -Trigger $taskTriggers -Action $taskAction -User "NT AUTHORITY\SYSTEM"
