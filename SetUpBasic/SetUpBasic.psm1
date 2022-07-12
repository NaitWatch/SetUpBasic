  

function SubRefresh{
    short
}   

function SubDump{
    Write-Host "6"
}   

function Subiamadmin{
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $result = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    Write-Host "$result"
}   

function SubFetchLink{
    param (
        [Parameter(Mandatory)]
        [string]$url
     )
     FetchStdLink -url $url -Contain @(".msixbundle")
}




