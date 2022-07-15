  
#Exported functions only

# Find all *.ps1 files in the module's subtree and dot-source them
foreach ($script in  (Get-ChildItem -File -LiteralPath $PSScriptRoot -Filter *.ps1)) { 
  . "$PSScriptRoot\$script"
}

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

