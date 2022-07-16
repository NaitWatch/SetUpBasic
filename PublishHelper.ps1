
$latestOnlineVersion = $(Find-Module -Name SetUpBasic).Version
Write-Host "Your oldest online version: $latestOnlineVersion"
$v = [version]$latestOnlineVersion
$newVersion = "{0}.{1}.{2}.{3}" -f $v.Major, $v.Minor, $v.Build, ($v.Revision + 1)
Write-Host "Your published version will be: $newVersion"

New-ModuleManifest `
-Path "$PSScriptRoot\SetUpBasic\SetUpBasic.psd1" `
-GUID "a8f1f122-a560-4d34-9390-0193cd370f33" `
-Description "Powershell module for basic windows os configuration, maintenance" `
-Tags @("windows","configuration","maintenance") `
-LicenseUri "https://github.com/NaitWatch/SetUpBasic/blob/main/LICENSE" `
-ProjectUri "https://github.com/NaitWatch/SetUpBasic" `
-FunctionsToExport @('SubUpdate','SubClean','SubIsAdmin','SubFetchLink','SubInstallRestartTask','SubInstallRestartTask','SubInstallModUpTask') `
-ModuleVersion "$newVersion"

[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$title = 'NuGetApiKey'
$msg   = 'Enter you powershell gallery NuGetApiKey:'
$text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
$global:progresspreference = 'SilentlyContinue'    # Subsequent calls do not display UI.
Publish-Module -Name "SetUpBasic" -Path "$PSScriptRoot\SetUpBasic"  -NuGetApiKey "$text" -Repository "PSGallery"
$global:progresspreference = 'Continue'            # Subsequent calls do display UI.
Write-Host "Finished"

