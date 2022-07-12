  

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

function SubOldModulCleanUp{
    param (
        [Parameter(Mandatory)]
        [string]$Name
     )

     $LatestModul = (Get-InstalledModule -name $Name)

     foreach ($CurrentModul in (Get-InstalledModule $Name -AllVersions)) {
        if ($CurrentModul.Version -ne $LatestModul.Version) 
        {
            Write-Host "Remove-Module -FullyQualifiedName @{ModuleName = """$Name"""; ModuleVersion = """$($CurrentModul.Version)"""}"
            Remove-Module -FullyQualifiedName @{ModuleName = "$Name"; ModuleVersion = "$($CurrentModul.Version)"}
            Write-Host "Uninstall-Module -name $Name -RequiredVersion $($CurrentModul.Version)"
            Uninstall-Module -name $Name -RequiredVersion $CurrentModul.Version
        }
     }
}

function SubCleanUp{
    param (
        [Parameter(Mandatory)]
        [string]$Name
     )

     SubOldModulCleanUp -Name "SetUpBasic"
}

#$ModuleName = 'navcontainerhelper';
#$Latest = Get-InstalledModule $ModuleName; 
#Get-InstalledModule $ModuleName -AllVersions | ? {$_.Version -ne $Latest.Version} | Uninstall-Module -WhatIf




