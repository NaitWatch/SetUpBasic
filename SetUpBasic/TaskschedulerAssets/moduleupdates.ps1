$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
$logFileTime = [System.DateTime]::UtcNow.ToString("yyyy_MM_dd_HH_mm_ss")
Start-Transcript -path "$PSScriptRoot\log_$logFileTime.txt" -append -Force -IncludeInvocationHeader

Import-Module -Name SetUpBasic -Force
SubUpdate
Import-Module -Name SetUpBasic -Force
SubClean

Stop-Transcript