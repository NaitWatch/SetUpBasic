
. "$PSScriptRoot\SetUpBasic.Template.ps1"

function Template-SubNewPSModule {
    
    param(
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$PackageName,
        [Parameter(Mandatory)]
        [string]$Author,
        [Parameter(Mandatory)]
        [string]$VerbPrefix,
        [Parameter(Mandatory)]
        [string]$ModulePrefix
    )
    
    Private-Template-SubNewPSModule -Path "$Path" "$PackageName" -VerbPrefix "$VerbPrefix" -ModulePrefix "$ModulePrefix" -Author "$Author" 
}
