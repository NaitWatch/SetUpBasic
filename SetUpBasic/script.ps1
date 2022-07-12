
function short{
    Update-Module -Name SetUpBasic
    #Get-InstalledModule -Name SetUpBasic -AllVersions | Where-Object {$_.Version -ne $(Get-InstalledModule -Name SetUpBasic).Version} | Uninstall-Module -Verbose
    #Import-Module -Name SetUpBasic -Force
    Write-Host "To update your current shell session you need to reload the module with 'Import-Module -Name SetUpBasic -Force' "
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


#$ret = DownloadString -url "https://github.com/microsoft/winget-cli/releases/latest"

#ExtractLinks2 -html $ret -url "https://github.com/microsoft/winget-cli/releases/latest"
