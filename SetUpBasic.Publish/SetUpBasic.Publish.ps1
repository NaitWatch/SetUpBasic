
function Publish-PrivateSubPSModule
{
    param(
        [Parameter(Mandatory)]
        [string]$PackageName
    )

    $PackageDirectory = "$PSScriptRoot\$PackageName"
    $PackageManifest = "$PackageDirectory\$PackageName.psd1"

    $data = Test-ModuleManifest -Path "$PackageManifest"

    [version]$ManifestVersion = $data.Version
    $ManifestVersionInc = "{0}.{1}.{2}.{3}" -f $ManifestVersion.Major, $ManifestVersion.Minor, $ManifestVersion.Build, ($ManifestVersion.Revision + 1)

    $FunctionsToExport = $($data.ExportedFunctions.Keys -join ',') -Split ','
    
    [string[]]$Tags = ($data.Tags  | Group-Object| Select-Object -ExpandProperty Name)

 
    New-ModuleManifest `
    -Path "$PackageManifest" `
    -GUID "$($data.GUID)" `
    -Description "$($data.Description)" `
    -Tags @($Tags) `
    -LicenseUri "https://www.powershellgallery.com/packages/$PackageName/$ManifestVersionInc/Content/LICENSE.txt" `
    -ProjectUri "$($data.ProjectUri)" `
    -FunctionsToExport @($FunctionsToExport) `
    -ModuleVersion "$ManifestVersionInc" `
    -RootModule "$($data.RootModule)" `
    -Author "$($data.Author)" 
    # -RequiredModules "$($data.RequiredModules)"

    (Get-Content -path "$PackageManifest") | Set-Content -Encoding default -Path "$PackageManifest"


    [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    $title = 'NuGetApiKey'
    $msg   = 'Enter you powershell gallery NuGetApiKey:'
    $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
    $global:progresspreference = 'SilentlyContinue'    # Subsequent calls do not display UI.
    Publish-Module -Path "$PackageDirectory" -NuGetApiKey "$text" -Repository "PSGallery"
    $global:progresspreference = 'Continue'            # Subsequent calls do display UI.
    Write-Host "Uploaded $PackageName version: $ManifestVersionInc"

    
}