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

Add-Type @'
public enum LogonUserType {
    SYSTEM = 0,
    CURRENTUSER = 1,
    ANYUSER = 2,
}
'@

Add-Type @'
public enum ScheduleType{
    TIME = 0,
    LOGON = 1,
}
'@

function Private-New-SubTask {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param (
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [string]$Program,
        [string]$Arguments = "",

        [ScheduleType]$ScheduleType = [ScheduleType]::LOGON,
        [LogonUserType]$LogonUserType = [LogonUserType]::CURRENTUSER,
        [bool]$HideScripts = $false,

        [timespan]$Time,
        [dayofweek[]]$day = ('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday')

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

    Private-Script-Task-Helper -Program ([ref]$Program) -Arguments ([ref]$Arguments) -HideScripts $HideScripts

    if ($Arguments.Trim() -eq "")
    {
        $actions = (New-ScheduledTaskAction -Execute "$Program" -Id "$Name")
    }
    else {
        $actions = (New-ScheduledTaskAction -Execute "$Program" -Argument "$Arguments" -Id "$Name")
    }

    if ($LogonUserType -eq [LogonUserType]::SYSTEM)
    {
        $principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    }
    elseif ($LogonUserType -eq [LogonUserType]::CURRENTUSER) {
        $principal = New-ScheduledTaskPrincipal -UserId "$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)" -LogonType Interactive
    }
    elseif ($LogonUserType -eq [LogonUserType]::ANYUSER) {
        $principal = New-ScheduledTaskPrincipal -GroupId "NT AUTHORITY\Interactive"
    }

    if ($ScheduleType -eq [ScheduleType]::TIME)
    {
        $trigger = New-ScheduledTaskTrigger -Weekly -WeeksInterval 1 -DaysOfWeek $day -At $startTime
        $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable
    }
    elseif ($ScheduleType -eq [ScheduleType]::LOGON)
    {
        if ($LogonUserType -eq [LogonUserType]::SYSTEM)
        {
            $trigger = New-ScheduledTaskTrigger -AtLogon
            $settings = New-ScheduledTaskSettingsSet
        }
        elseif ($LogonUserType -eq [LogonUserType]::CURRENTUSER) {
            $trigger = New-ScheduledTaskTrigger -AtLogon -User "$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
            $settings = New-ScheduledTaskSettingsSet
        }
        elseif ($LogonUserType -eq [LogonUserType]::ANYUSER) {
            $trigger = New-ScheduledTaskTrigger -AtLogon
            $settings = New-ScheduledTaskSettingsSet
        }

    }

    $task = New-ScheduledTask -Action $actions -Principal $principal -Trigger $trigger -Settings $settings

    Register-ScheduledTask "$Name" -Force -InputObject $task | Out-Null
}

function Private-Script-Task-Helper {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param (
        [Parameter(Mandatory)]
        [ref]$Program,
        [Parameter(Mandatory)]
        [ref]$Arguments,
        [Parameter(Mandatory)]
        [bool]$HideScripts
    )

    if ($Program.Value.EndsWith(".ps1") -and ($HideScripts -eq $false))
    {
        $NewProgram = "$([System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName)"
        $NewArguments = "-ExecutionPolicy Bypass -File $($Program.Value) $($Arguments.Value)"
    }
    elseif ($Program.Value.EndsWith(".ps1") -and ($HideScripts -eq $true))
    {
        $NewProgram = "$PSScriptRoot\SubSystemWin.exe"
        $NewArguments = """$([System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName)"" -NonInteractive -ExecutionPolicy Bypass -File $($Program.Value) $($Arguments.Value)"
    }
    elseif (($Program.Value.EndsWith(".bat") -or $Program.Value.EndsWith(".cmd")) -and ($HideScripts -eq $false))
    {
        $NewProgram = "$($env:comspec)"
        $NewArguments = "/c $($Program.Value) $($Arguments.Value)"
    }
    elseif (($Program.Value.EndsWith(".bat") -or $Program.Value.EndsWith(".cmd"))  -and ($HideScripts -eq $true))
    {
        $NewProgram = "$PSScriptRoot\SubSystemWin.exe"
        $NewArguments = """$($env:comspec)"" /c ""$($Program.Value)"" $($Arguments.Value)"
    }
    else {
        $NewProgram = $Program.Value
        $NewArguments = $Arguments.Value 
    }

    $Program.Value = $NewProgram
    $Arguments.Value = $NewArguments

}

function Private-Script-CreateSampleScript {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param(
        [Parameter(Mandatory)]
        [string]$Location
    )
    


    if ($Location.EndsWith(".ps1"))
    {
$sample = `
@"
`$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
`$ErrorActionPreference = "Continue"
`$logFileTime = [System.DateTime]::UtcNow.ToString("yyyy_MM_dd_HH_mm_ss_fff")
Start-Transcript -path "`$PSScriptRoot\`$(`$MyInvocation.MyCommand.Name)_`$logFileTime.log" -append -Force -IncludeInvocationHeader

Write-Host "Hello form `$PSScriptRoot\`$(`$MyInvocation.MyCommand.Name)"
Write-Host "Our commands here"

Stop-Transcript
"@
    }
    elseif ($Location.EndsWith(".bat") -or $Location.EndsWith(".cmd")) {
$sample = `
@"
@echo off
echo hello > %~dp0foo.log
echo %0 >> %~dp0foo.log
echo 1 >> %~dp0foo.log
echo 2 >> %~dp0foo.log
echo 3 >> %~dp0foo.log
"@       
    }

    New-Item -path "$Location" -ItemType "file" -Force -value "$sample"  | Out-Null

}

function Private-New-SubCreateDefaultLogonTask {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [string]$Location,
        [bool]$HideScript = $false
    )
    Private-Script-CreateSampleScript -Location "$Location"
    Private-New-SubTask -Name "$Name" -Program "$Location" -HideScript $HideScript
}
