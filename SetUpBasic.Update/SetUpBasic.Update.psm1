
. "$PSScriptRoot\SetUpBasic.Update.ps1"

function Update-SubModule {
    param(
        [string]$Name
    )
    
    Private-Update-SubModule -Name "$Name"

}
