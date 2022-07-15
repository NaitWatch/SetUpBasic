enum PowerShellDirectoryType
{
    Unknown = 0
    PowerShellCurrentUser5Directory = 1
    PowerShellCurrentUser7Directory = 2
    PowerShellWindowsDirectory = 3
    PowerShell5ProgramFilesDirectory = 4
    PowerShell7ProgramFilesDirectory = 5
}

class ModulFullyQualifiedName
{
    [string]$Name
    [Version]$Version
    [string]$Path
    [PowerShellDirectoryType]$DirType
    [PSObject]$Object

    ModulFullyQualifiedName([string]$Name,[Version]$Version,[string]$Path,[PSObject]$Object )
    {
        $this.Name = $Name
        $this.Version = $Version
        $this.Path = $Path
        $this.DirType = PowerShellPathType -Path $Path
        $this.Object = $Object
    }
}

function PowerShellPathType {
    [OutputType([PowerShellDirectoryType])]
    param(
        [string]$Path
    )
    [PowerShellDirectoryType] $retval = [PowerShellDirectoryType]::Unknown

    $pf86 = ${env:ProgramFiles(x86)}
    $pf = $env:ProgramFiles
    $windir = $env:windir
    $usr = $(GetUserName).ToLower()

    if ($Path.ToLower().Contains($usr)) {
        if ($Path.ToLower().Contains("windowspowershell"))
        {
            $retval = [PowerShellDirectoryType]::PowerShellCurrentUser5Directory
        }
        elseif ($Path.ToLower().Contains("powershell")) {
            $retval = [PowerShellDirectoryType]::PowerShellCurrentUser5Directory
        }
    }
    elseif ($Path.ToLower().Contains($windir.ToLower())) {
        $retval = [PowerShellDirectoryType]::PowerShellWindowsDirectory
    }
    elseif (($Path.ToLower().Contains($pf.ToLower())) -or ($Path.ToLower().Contains($pf86.ToLower()))) {
        
        if ($Path.ToLower().Contains("windowspowershell"))
        {
            $retval = [PowerShellDirectoryType]::PowerShell5ProgramFilesDirectory
        }
        elseif ($Path.ToLower().Contains("powershell")) {
            $retval = [PowerShellDirectoryType]::PowerShell7ProgramFilesDirectory
        }

    }
    else {
        $retval = [PowerShellDirectoryType]::Unknown
    }

    return $retval
}

function FindPowerShellDirectory {
    [OutputType([string])]
    param(
        [PowerShellDirectoryType]$Type
    )
    
    [string] $retval = $null;

    $paths = $env:PSModulePath -split ';'
    foreach($item in $paths)
    {
        $itemType = $(PowerShellPathType -Path $item)
        if ($itemType  -eq $Type)
        {
            $retval = $item
            break;
        }
    }

    return $retval
}

function GetUserName {

    [string]$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().name
    $CurrentUserSplit = $CurrentUser.ToString().Split('\')
    $CurrentUserDomain = $CurrentUserSplit[0].ToLower()
    $CurrentUserName = $CurrentUserSplit[$CurrentUserSplit.Count-1].ToLower()
    return $CurrentUserName
}




function GetModules{

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
            $retval += [ModulFullyQualifiedName]::new( $item.Name, $item.Version, $item.ModuleBase.TrimEnd($item.Version.ToString()).TrimEnd('\').TrimEnd($item.Name),$item ) 
        }
    }
    else {
        Write-Host "$Name could not be found please check the name."
    }

    return $retval
}

function PrivateSubIsAdmin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $result = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    return $result
}

function PrivateSubUpdate {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    if ($(PrivateSubIsAdmin))
    {
        Install-Module -Name SetUpBasic -Scope AllUsers -Force -Repository "PSGallery" -AllowClobber -AcceptLicense
    }
    else {
        Install-Module -Name SetUpBasic -Scope CurrentUser -Force -Repository "PSGallery" -AllowClobber -AcceptLicense
    }
    Write-Host "To update your current shell session you need to reload the module with 'Import-Module -Name SetUpBasic -Force' "
}

function PrivateSubClean2 {
    param (
        [Parameter(Mandatory)]
        [string]$Name
     )

     $arr = GetModuleVersions $Name 
     $CurrentUser5Modules = $arr | Where-Object {$_.DirType -eq [PowerShellDirectoryType]::PowerShellCurrentUser5Directory} | Sort-Object Version -Descending
     $CurrentUser7Modules = $arr | Where-Object {$_.DirType -eq [PowerShellDirectoryType]::PowerShellCurrentUser7Directory} | Sort-Object Version -Descending
     
     $Machine5Modules = $arr | Where-Object {$_.DirType -eq [PowerShellDirectoryType]::PowerShell5ProgramFilesDirectory} | Sort-Object Version -Descending
     $Machine7Modules = $arr | Where-Object {$_.DirType -eq [PowerShellDirectoryType]::PowerShell7ProgramFilesDirectory} | Sort-Object Version -Descending

     if ($(PrivateSubIsAdmin))
     {
        if ($Machine5Modules.Count -gt 1)
        {
           for ($i = 1; $i -lt $Machine5Modules.Count; $i++) {
               $mod = $Machine5Modules[$i].Object
               Remove-Item -Recurse -Force -Path $mod.ModuleBase
           }
        }
        #Check if machine modules are higher than user ones and delete the user ones
        if (($Machine5Modules.Count -gt 0) -and ($CurrentUser5Modules.Count -gt 0))
        {

            if ($Machine5Modules[0].Version -gt $CurrentUser5Modules[0].Version)
            {
                for ($i = 0; $i -lt $CurrentUser5Modules.Count; $i++) {
                    $mod = $CurrentUser5Modules[$i].Object
                    Remove-Item -Recurse -Force -Path $mod.ModuleBase
                }

                $basepath = $CurrentUser5Modules[0].Object.ModuleBase.TrimEnd($CurrentUser5Modules[0].Object.Version.ToString())
                $subItems = Get-ChildItem -LiteralPath $basepath
                if ($null -eq $subItems)
                {
                    Remove-Item -Force -Path $basepath
                }
            }
        }
     }
     else {
        if ($CurrentUser5Modules.Count -gt 1)
        {
           for ($i = 1; $i -lt $CurrentUser5Modules.Count; $i++) {
               $mod = $CurrentUser5Modules[$i].Object
               Remove-Item -Recurse -Force -Path $mod.ModuleBase
           }
        }
     }

     
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
     Import-Module -Name $Name -Force
     Write-Host "Current: $($LatestModul) $($LatestModul.Version)"
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
            $retval += [ModulFullyQualifiedName]::new( $item.Name, $item.Version, $item.ModuleBase.TrimEnd($item.Version.ToString()).TrimEnd('\').TrimEnd($item.Name) ,$item) 
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

PrivateSubClean2 "SetUpBasic"

$e = ""


#Write-Host "Hello from SetUpBasic.ps1"
#CreateDir "C:\TaskScheduler"

#RemoveOldModules SetUpBasic
#save "C:\temp\localrep"
#Installfromfolder



#SubOldModulCleanUp -ModulName "SetUpBasic"

#$ret = DownloadString -url "https://github.com/microsoft/winget-cli/releases/latest"

#ExtractLinks2 -html $ret -url "https://github.com/microsoft/winget-cli/releases/latest"
