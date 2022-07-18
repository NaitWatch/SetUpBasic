
. "$PSScriptRoot\SetUpBasic.TemplateGenerator.ps1"

function New-SubTemplatePSModule {
    
    param(
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$PackageName,
        [Parameter(Mandatory)]
        [string]$Author,
        [Parameter(Mandatory)]
        [string]$CommandPrefix
    )

    New-SubPrivateTemplatePSModule -PackageName "$PackageName" -Author "$Author" -CommandPrefix "$CommandPrefix" -Path "$Path"
}
