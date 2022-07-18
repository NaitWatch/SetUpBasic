
. "$PSScriptRoot\SetUpBasic.Publish.ps1"

function Publish-SubPSModule {
    
    param(
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$PackageName
    )

    Publish-PrivateSubPSModule -Path "$Path" -PackageName "$PackageName" 
}
