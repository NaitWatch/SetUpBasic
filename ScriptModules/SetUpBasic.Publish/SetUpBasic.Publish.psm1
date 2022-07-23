
. "$PSScriptRoot\SetUpBasic.Publish.ps1"

function Publish-SubPSModule {
    
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [string]$Path
    )

    Publish-PrivateSubPSModule -Path "$Path" -Name "$Name" 
}
