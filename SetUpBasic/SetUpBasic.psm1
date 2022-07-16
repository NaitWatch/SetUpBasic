function DotSourceDirectory {
    
    [OutputType([string[]])]
    
    param (
        [Parameter(Mandatory)]
        [string]$SubDirectory
    )

    [string[]] $retval = @()

    $SourceDirectory = "$PSScriptRoot\$SubDirectory"
    foreach ($script in  (Get-ChildItem -File -LiteralPath "$SourceDirectory" -Filter *.ps1)) { 
        $retval += "$SourceDirectory\$script"
    }
    return $retval
}

foreach ($script in  $(DotSourceDirectory -SubDirectory "Basic")) { Write-Host "Dot sourced: $script" ; . "$script" }
foreach ($script in  $(DotSourceDirectory -SubDirectory "ModuleManagement")) { Write-Host "Dot sourced: $script" ; . "$script" }
foreach ($script in  $(DotSourceDirectory -SubDirectory "TaskScheduler")) { Write-Host "Dot sourced: $script" ; . "$script" }

function SubUpdate{

    PrivateSubUpdate
}   

function SubClean{
    #PrivateSubClean -Name "SetUpBasic"

    PrivateSubClean2 -Name "SetUpBasic"
}


function SubInstallRestartTask{
    PrivateCreateDir -Path "C:\TaskScheduler"
    Copy-Item "$PSScriptRoot\TaskschedulerAssets\restart.ps1" -Destination "C:\TaskScheduler\restart.ps1" -Force
    EnableTaskSchedulerEventLog
    EasyTaskscheduler -Name "Daily Reboot" -Program "C:\TaskScheduler\restart.ps1" -Time "04:00:00"
}

function SubInstallModUpTask{
    PrivateCreateDir -Path "C:\TaskScheduler"
    Copy-Item "$PSScriptRoot\TaskschedulerAssets\moduleupdates.ps1" -Destination "C:\TaskScheduler\moduleupdates.ps1" -Force
    EnableTaskSchedulerEventLog
    EasyTaskscheduler -Name "Daily Module Updates" -Program "C:\TaskScheduler\moduleupdates.ps1" -Time "02:00:00" -LaunchAsapIfMissed $true
    
}


function SubIsAdmin{
    PrivateSubIsAdmin
}   

function SubFetchLink{
    param (
        [Parameter(Mandatory)]
        [string]$url
     )
     FetchStdLink -url $url -Contain @(".msixbundle")
}

