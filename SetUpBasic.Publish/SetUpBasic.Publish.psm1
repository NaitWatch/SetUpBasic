
. "$PSScriptRoot\SetUpBasic.Publish.ps1"

function Publish-SubPSModule {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName
    )
    Publish-PrivateSubPSModule -PackageName "$PackageName"
}
