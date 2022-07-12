

function scrip{
    Write-Host "script1"
}  

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

function ExtractLinks2 {
    
    param (
        [Parameter(Mandatory)]
        [string]$html,
        [Parameter(Mandatory)]
        [string]$url
    )

    $uri = [uri]::new($url)

    $retval = New-Object System.Collections.Generic.List[System.String]

    #$RegExPattern = [regex]::new('<(a|link|Link|A).*href\s*=\s*\"(.*?)\".*>')
    $RegExPattern = [regex]::new('<(a|A)(.*?)href(.*?)=\"(.*?)\"(.*?)>')
    
    foreach($match in $RegExPattern.Matches($html))
    {
        $retval.Add([string]$match.Groups[4].Value)
    }

    #Adding missing beginnings
    for ($i = 0; $i -lt $retval.Count; $i++) {
       if ($retval[$i].StartsWith("/"))
       {
        $retval[$i] = $uri.Scheme+"://"+$uri.Host+$retval[$i]
       }
    }

    $retvalnodupe = New-Object System.Collections.Generic.List[System.String]
    #Remove duplicates without changing the order of items, remove empty items, remove #
    for ($i = 0; $i -lt $retval.Count; $i++) {
        if($retvalnodupe.Contains($retval[$i]) -eq $false)
        {
            if(-Not [string]::IsNullOrEmpty($retval[$i]))
            {
                if(-Not $retval[$i].StartsWith("#"))
                {
                    $retvalnodupe.Add($retval[$i])
                }
            }
        }
    }

    [System.Collections.Generic.List[System.String]] $retvalnodupe
    
    return
}



#$ret = DownloadString -url "https://github.com/microsoft/winget-cli/releases/latest"

#ExtractLinks2 -html $ret -url "https://github.com/microsoft/winget-cli/releases/latest"
