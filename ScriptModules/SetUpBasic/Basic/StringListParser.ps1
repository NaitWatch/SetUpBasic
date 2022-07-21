function RegExParser {
    
    param (
        [Parameter(Mandatory)]
        [string]$string,
        [Parameter(Mandatory)]
        [string]$RegExPattern,
        [Parameter(Mandatory)]
        [int]$MatchGroup
    )

    $retval = New-Object System.Collections.Generic.List[System.String]

    #$RegExPattern = [regex]::new('<(a|link|Link|A).*href\s*=\s*\"(.*?)\".*>')
    $Pattern = [regex]::new($RegExPattern)
    
    foreach($match in $Pattern.Matches($string))
    {
        $retval.Add([string]$match.Groups[4].Value)
    }

    [string[]] $retval
    
    return
}

function LinkListReprocessing {

    param (
        [Parameter(Mandatory)]
        [object[]] $LinkList,
        [Parameter()]
        [bool]$RemoveEmpty = $true,
        [Parameter()]
        [bool]$RemoveHashTag = $true,
        [Parameter()]
        [bool]$PreventDupes = $true,
        [Parameter()]
        [string]$RelativeToAbsoluteUrl = $null
    )

    $retval = New-Object System.Collections.Generic.List[System.String]
    [uri]$uri = $null
    if ($null -ne $RelativeToAbsoluteUrl)
    {
        $uri = [uri]::new($RelativeToAbsoluteUrl)
    }

    for ($i = 0; $i -lt $LinkList.Count; $i++) {

        if($RemoveEmpty -and [string]::IsNullOrEmpty($LinkList[$i]))
        {
            continue;
        }

        if($RemoveHashTag -and $LinkList[$i].StartsWith("#"))
        {
            continue;
        }

        if ($null -ne $uri)
        {
            if ($LinkList[$i].StartsWith("/"))
            {
                $LinkList[$i] = $uri.Scheme+"://"+$uri.Host+$LinkList[$i]
            }
        }

        if($PreventDupes -and ($retval.Contains($LinkList[$i]) -eq $true))
        {
            continue;
        }

        $retval.Add($LinkList[$i])

     }

     [System.Collections.Generic.List[System.String]] $retval
    
     return

}

function LinkListFilter {

    param (
        [Parameter(Mandatory)]
        [object[]] $LinkList,
        [Parameter(Mandatory)]
        [string[]]$Endings
    )

    $retval = New-Object System.Collections.Generic.List[System.String]

    for ($i = 0; $i -lt $LinkList.Count; $i++) {

        $uriitem = [uri]::new($LinkList[$i])
        $max = $uriitem.Segments.Count-1
        $lastsegment = $uriitem.Segments[$max]
        for ($j = 0; $j -lt $Endings.Count; $j++) {
            
            if ($lastsegment.EndsWith($Endings[$j]))
            {
                $retval.Add($LinkList[$i])
            }
        }
     }

     [System.Collections.Generic.List[System.String]] $retval
    
     return

}

function LinkListMustContain {

    param (
        [Parameter(Mandatory)]
        [object[]] $LinkList,
        [Parameter(Mandatory)]
        [string[]]$Contain
    )

    $retval = New-Object System.Collections.Generic.List[System.String]

    for ($i = 0; $i -lt $LinkList.Count; $i++) {

        $uriitem = [uri]::new($LinkList[$i])
        $lastsegment = $uriitem.Segments[$uriitem.Segments.Count-1]
        [bool]$allcontain = $true
        for ($j = 0; $j -lt $Contain.Count; $j++) {
            

            if ($lastsegment.Contains($Contain[$j]))
            {
                $allcontain = $allcontain -and $true
            }
            else {
                $allcontain = $allcontain -and $false
            }
        }
        if ($allcontain)
        {
            $retval.Add($LinkList[$i])
        }
     }

     [System.Collections.Generic.List[System.String]] $retval
    
     return

}

function FetchStdLink {

    param (
        [Parameter(Mandatory)]
        [string] $url,
        [Parameter(Mandatory)]
        [string[]]$Contain
    )

    [string]$url = "https://github.com/microsoft/winget-cli/releases/latest"
    $html = DownloadString -url $url
    [string[]]$rest = RegExParser -string $html -RegExPattern '<(a|A)(.*?)href(.*?)=\"(.*?)\"(.*?)>' -MatchGroup 4
    [string[]]$rest = LinkListReprocessing -LinkList $rest -RelativeToAbsoluteUrl $url
    [string[]]$rest = LinkListFilter -LinkList $rest -Endings @(".zip",".exe",".ps1",".cmd",".bat",".msixbundle")
    [string[]]$rest = LinkListMustContain -LinkList $rest -Contain $Contain

    [string[]]$rest[0]

    return
}






