
. "$PSScriptRoot\SetUpBasic.TaskScheduler.ps1"

function New-SubTask {
    param (
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [string]$Program,
        [string]$Arguments = "",

        [ScheduleType]$ScheduleType = [ScheduleType]::LOGON,
        [LogonUserType]$LogonUserType = [LogonUserType]::CURRENTUSER,
        [bool]$HideScripts = $false,

        [timespan]$Time = (New-TimeSpan),
        [dayofweek[]]$day = ('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday')

    )

    Private-New-SubTask -Name $Name -Program $Program -Arguments $Arguments -ScheduleType $ScheduleType -LogonUserType $LogonUserType -HideScripts $HideScripts -Time $Time -day $day
}

function New-SubCreateDefaultLogonTask {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [string]$Location,
        [bool]$HideScript = $false
    )

    Private-New-SubCreateDefaultLogonTask -Name $Name -Location $Location -HideScript $HideScript
}
