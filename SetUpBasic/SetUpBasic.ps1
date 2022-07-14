
function PrivateSubUpdate{
    Update-Module -Name SetUpBasic -Force
    #Get-InstalledModule -Name SetUpBasic -AllVersions | Where-Object {$_.Version -ne $(Get-InstalledModule -Name SetUpBasic).Version} | Uninstall-Module -Verbose
    #Import-Module -Name SetUpBasic -Force
    Write-Host "To update your current shell session you need to reload the module with 'Import-Module -Name SetUpBasic -Force' "
}

function PrivateSubClean{
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

function PrivateSubIsAdmin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $result = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    return $result
}

function DownloadString {
    
    param (
        [Parameter(Mandatory)]
        [string]$url
    )

    $uri = [uri]::new($url)
    

    try {
        $str = (New-Object Net.WebClient).DownloadString($uri.OriginalString) 
    }
    catch {
        Write-Host "DownloadString thrown a exception"
        Write-Host "$($PSItem.Exception.Message)"
        $str = ""
    }
    return [string]$str
}

function GetInfo3{
    param($ComputerName)
    Get-WmiObject -ComputerName $ComputerName -Class Win32_BIOS
    Write-Host "fooupdate3"
}  

class ModulFullyQualifiedName
{
    [string]$Name
    [Version]$Version
    [string]$Path
    
    ModulFullyQualifiedName([string]$Name,[Version]$Version,[string]$Path )
    {
        $this.Name = $Name
        $this.Version = $Version
        $this.Path = $Path
    }
}

function GetModuleVersions{

    [OutputType([ModulFullyQualifiedName[]])]
    param(
        [string]$Name
    )

    [ModulFullyQualifiedName[]] $retval = @()

    $LatestModuls = (Get-Module -ListAvailable $Name) | Sort-Object Version -Descending

    if( ($LatestModuls -is [system.array]) -or ($null -ne $LatestModuls))
    {
        foreach($item in $LatestModuls)
        {
            $retval += [ModulFullyQualifiedName]::new( $item.Name, $item.Version, $item.ModuleBase.TrimEnd($item.Version.ToString()).TrimEnd('\').TrimEnd($item.Name) ) 
        }
    }
    else {
        Write-Host "$Name could not be found please check the name."
    }

    return $retval
}

function GetOldModuleVersions{

    [OutputType([ModulFullyQualifiedName[]])]
    param(
        [string]$Name
    )
    
    $arr = GetModuleVersions $Name
    if ($arr.Count -gt 1)
    {
        $arr = $arr[1..($arr.Length-1)]
    }
    else {
        [ModulFullyQualifiedName[]] $retval = @()
        $arr = $retval
    }
    return $arr
}

function GetLatestModuleVersion{

    [OutputType([ModulFullyQualifiedName])]
    param(
        [string]$Name
    )
   

    $arr = GetModuleVersions $Name
    if ($arr.Count -gt 0)
    {
        $retval = $arr[0]
    }

    return $retval 
}

function RemoveOldModules{

    param(
        [string]$Name
    )

    $old = GetOldModuleVersions $Name

    foreach($item in $old)
    {
        try {
            Write-Host "Remove-Module -FullyQualifiedName @{ModuleName = ""$item.Name""; ModuleVersion = ""$($item.Version)""}"
            Remove-Module -FullyQualifiedName @{ModuleName = "$($item.Name)"; ModuleVersion = "$($item.Version)"}
         }
         catch {
             "An error occurred that could not be resolved."
         }
    }

    foreach($item in $old)
    {
        try {
            Write-Host "Uninstall-Module -name $($item.Name) -RequiredVersion $($item.Version)"
            Uninstall-Module -name $item.Name -RequiredVersion $item.Version
         }
         catch {
             "An error occurred that could not be resolved."
         }
    }
    
}


function Installfromfolder{
    #Register-PSRepository -Name 'myRepositoryName' -SourceLocation 'C:\temp\repo' -InstallationPolicy Trusted
    Install-Module -Name SetUpBasic -Repository 'local'
    

    #Unregister-PSRepository -Name "myRepositoryName"
}

function save{
   
    param(
        [string]$ffff
    )

    New-Item -ItemType Directory -Force -Path $ffff

    $Moduls = Find-Module -Name SetUpBasic -Repository PSGallery -AllVersions

    foreach($item in $Moduls)
    {
        $Folder = "$ffff\$($item.Name)\$($item.Version)"
        
        if (Test-Path -Path $Folder) {
            "Path exists!"
        } else {
            Save-Module -Name $item.Name -Path $ffff -Repository PSGallery -RequiredVersion $item.Version
        }

        
    }
}
function PrivateCreateDir{
       param(
        [string]$path
    )

    if(!(test-path -PathType container $path))
    {
        New-Item -ItemType Directory -Path $path
    }
}

#Write-Host "Hello from SetUpBasic.ps1"
#CreateDir "C:\TaskScheduler"

#RemoveOldModules SetUpBasic
#save "C:\temp\localrep"
#Installfromfolder



#SubOldModulCleanUp -ModulName "SetUpBasic"

#$ret = DownloadString -url "https://github.com/microsoft/winget-cli/releases/latest"

#ExtractLinks2 -html $ret -url "https://github.com/microsoft/winget-cli/releases/latest"
