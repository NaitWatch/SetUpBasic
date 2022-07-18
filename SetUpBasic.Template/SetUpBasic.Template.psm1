
. "$PSScriptRoot\SetUpBasic.Template.ps1"

function Template-SubNewPSModule {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    
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
    
    Private-Template-SubNewPSModule -Path "$Path" -PackageName "$PackageName" -VerbPrefix "$VerbPrefix" -ModulePrefix "$ModulePrefix" -Author "$Author" 
}
