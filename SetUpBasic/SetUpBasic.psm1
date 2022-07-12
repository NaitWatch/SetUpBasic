  

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

     $LatestModuls = (Get-Module -ListAvailable $Name) | Sort-Object Version -Descending
     $LatestModul = $LatestModuls[0]
     

     foreach ($CurrentModul in $(Get-Module -ListAvailable $Name)) {
        if ($CurrentModul.Version -ne $LatestModul.Version) 
        {
            Write-Host "Remove-Module -FullyQualifiedName @{ModuleName = """$Name"""; ModuleVersion = """$($CurrentModul.Version)"""}"
            Remove-Module -FullyQualifiedName @{ModuleName = "$Name"; ModuleVersion = "$($CurrentModul.Version)"} -ErrorAction SilentlyContinue
            Write-Host "Uninstall-Module -name $Name -RequiredVersion $($CurrentModul.Version)"
            Uninstall-Module -name $Name -RequiredVersion $CurrentModul.Version -ErrorAction SilentlyContinue
        }
     }
     Write-Host "Current: $($LatestModul) $($LatestModul.Version)"
}

function SubCleanUp{
     SubOldModulCleanUp -Name "SetUpBasic"
}

#$ModuleName = 'navcontainerhelper';
#$Latest = Get-InstalledModule $ModuleName; 
#Get-InstalledModule $ModuleName -AllVersions | ? {$_.Version -ne $Latest.Version} | Uninstall-Module -WhatIf




