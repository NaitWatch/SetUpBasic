#EasyTaskscheduler -Name "Once1" -Program "C:\base\github.com\NaitWatch\PwshSrvConfigHelper\common.ps1" -Arguments @("hello") -Time "04:00:00" -day @("Sunday")
#EasyTaskscheduler -Name "Once2" -Program "C:\base\github.com\NaitWatch\PwshSrvConfigHelper\common.ps1" -Time "05:00:00" -day @("Sunday")
#EasyTaskscheduler -Name "Once3" -Program "c:\temp\x.ps1" -Arguments @("foo","fa il") -Time "05:00:00"
#EasyTaskscheduler -Name "Once4" -Program "c:\temp\x x.bat" -Arguments @("foo","fa il")
#EasyTaskscheduler -Name "Once5" -Program "$env:comspec.exe" -Arguments @("/c","""c:\temp\x x.bat""","""foo""")

function EasyTaskscheduler {

    param (
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [string]$Program,
        [string[]]$Arguments,
        [timespan]$Time,
        [dayofweek[]]$day = ('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'),
        [bool]$LaunchAsapIfMissed = $false
    )
    
    #starTime is required for a task to start the operations at a specific date, calculating a default at current day 00:00 if no starttime was givven
    [datetime]$startTime = $(Get-Date)
    if ($Time -eq $null)
    {
        $startTime = $($(Get-Date) - $(Get-Date).TimeOfDay)
    }
    else {
        $startTime = $($(Get-Date) - $(Get-Date).TimeOfDay) + $Time
    }

    if ($Program.EndsWith(".ps1") -or $Program.EndsWith(".ps1")  )
    {
        #if the program is a powershell script, that set the program exe to powershell.exe and pass the .ps1 + arguments as parameter
        $temp = @() ;  $Arguments | ForEach-Object{ $temp += """$_""" } ;
        if ($Arguments.Count -gt 0)
        {
            $Arguments = $temp
        }
        else {
            $Arguments = $null
        }
        $Argument = "-ExecutionPolicy Bypass -File ""$Program"" $($Arguments -join " ") ";
        $Program = """$($(Get-Command "powershell.exe").Source)""";
    }
    elseif ($Program.EndsWith(".cmd") -or $Program.EndsWith(".bat")  )
    {
        $temp = @() ;  $Arguments | ForEach-Object{ $temp += """$_""" } ;
        if ($Arguments.Count -gt 0)
        {
            $Arguments = $temp
        }
        else {
            $Arguments = $null
        }
        $Argument = "/c "" ""$Program"" $($Arguments -join " ") """;
        $Program = """$($(Get-Command "cmd.exe").Source)""";
    }
    else {
        $Argument = "$($Arguments -join " ")";
    }

    $actions = (New-ScheduledTaskAction -Execute "$Program" -Argument "$Argument" -Id "$Name")
    $trigger = New-ScheduledTaskTrigger -Weekly -WeeksInterval 1 -DaysOfWeek $day -At $startTime
    $principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest

    if ($LaunchAsapIfMissed)
    {
        $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 15) -StartWhenAvailable
    }
    else {
        $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 15)
    }
    
    $task = New-ScheduledTask -Action $actions -Principal $principal -Trigger $trigger -Settings $settings
    
    Register-ScheduledTask "$Name" -Force -InputObject $task
}

function EnableTaskSchedulerEventLog {
    $logName = 'Microsoft-Windows-TaskScheduler/Operational'
    $log = New-Object System.Diagnostics.Eventing.Reader.EventLogConfiguration $logName
    $log.IsEnabled=$true
    $log.SaveChanges()
}