
. "$PSScriptRoot\SetUpBasic.Publish.ps1"

function Publish-SubPSModule {
    Publish-PrivateSubPSModule
    Write-Host "Use Get-Verb prefixes - your prefix + command e.g. Out-SubHello"
    Write-Host "Don't forget to list newly added function in the module manifest .psd1 file, section FunctionsToExport= "
}
