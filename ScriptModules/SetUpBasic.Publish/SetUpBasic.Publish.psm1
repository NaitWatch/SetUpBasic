
. "$PSScriptRoot\SetUpBasic.Publish.ps1"

function Publish-SubPSModule {
    
    param(
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$Name
    )

    Publish-PrivateSubPSModule -Path "$Path" -$Name "$Name" 
}
