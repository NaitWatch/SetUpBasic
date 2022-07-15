
function doo {
    
    $publishpath = "$PSScriptRoot\SetUpBasic"

    $file = "$publishpath\SetUpBasic.psd1"
    $fileVersion = Get-Content $file -Raw
    
    $RegExPattern = [regex]::new('ModuleVersion(.*?)=(.*?)''(.*?)''')
    [System.Text.RegularExpressions.MatchCollection]$matches = $RegExPattern.Matches($fileVersion)
    $fullmatch = [string]$matches[0].Groups[0].Value
    $version = [string]$matches[0].Groups[3].Value
    Write-Host "Current Version: $fullmatch"
    $v = [version]$version
    $newVersion = "{0}.{1}.{2}.{3}" -f $v.Major, $v.Minor, $v.Build, ($v.Revision + 1)
    
    $fileVersion = $fileVersion.replace($matches[0].Groups[0].Value,"ModuleVersion = '$newVersion'")
    $fileVersion | Out-File "$publishpath\SetUpBasic.psd1"
    Write-Host "Your published version will be: $newVersion"
    Write-Host "Commit of version : $newVersion"
    
    
    [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    $title = 'NuGetApiKey'
    $msg   = 'Enter you powershell gallery NuGetApiKey:'
    $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
    $global:progresspreference = 'SilentlyContinue'    # Subsequent calls do not display UI.
    Publish-Module -Path "$publishpath" -NuGetApiKey "$text" -Repository "PSGallery"
    $global:progresspreference = 'Continue'            # Subsequent calls do display UI.
    Write-Host "Finished"
}


doo