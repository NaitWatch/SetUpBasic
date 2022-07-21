function Publish-PrivateSubPSModule
{
    param(
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$Name
    )

    if ((-not $PSBoundParameters.ContainsKey('Path')) -or ($Path -eq ""))
    {
        $Path = Get-Location
    }

    if (-not (Test-Path -LiteralPath "$Path" -IsValid))
    {
        $Path = Get-Location
    }

    [string[]] $retval = @()

    foreach ($script in  (Get-ChildItem -File -LiteralPath "$Path\$Name" -Filter "*.psd1")) { 
        $retval += "$($script.Fullname)"
    }

    if ($retval.Count -gt 0)
    {
        if(Test-Path -LiteralPath "$($retval[0])" -PathType Leaf)
        {
            $nfo = $(Get-Item "$($retval[0])")
            $PackageDirectory = "$($nfo.Directory)"
            $PackageManifest = "$($nfo.FullName)"
        }
        else {
            return $null
        }
    }
    
    $data = Test-ModuleManifest -Path "$PackageManifest"

    [version]$ManifestVersion = $data.Version
    $ManifestVersionInc = "{0}.{1}.{2}.{3}" -f $ManifestVersion.Major, $ManifestVersion.Minor, $ManifestVersion.Build, ($ManifestVersion.Revision + 1)

    $FunctionsToExport = $($data.ExportedFunctions.Keys -join ',') -Split ','
    
    [string[]]$Tags = ($data.Tags  | Group-Object| Select-Object -ExpandProperty Name)

    $RequiredMod = @()
   
    foreach($item in $data.RequiredModules)
    {
        if (($null -eq $item.Version) -and ($item.Guid -eq "00000000-0000-0000-0000-000000000000"))
        {                                                   
            $add = [string]$item.Name
        }
        elseif (($null -ne $item.Version) -and ($item.Guid -eq "00000000-0000-0000-0000-000000000000")) {
            $add = @{
                ModuleName = [string]$item.Name;
                ModuleVersion = [string]$item.Version;
                }
        }
        else {
            $add = @{
                ModuleName = $item.Name
                ModuleVersion = $item.Version;
                GUID = $item.Guid
                }
        }
         $RequiredMod += $add
    }


 
    New-ModuleManifest `
    -Path "$PackageManifest" `
    -GUID "$($data.GUID)" `
    -Description "$($data.Description)" `
    -Tags @($Tags) `
    -LicenseUri "https://www.powershellgallery.com/packages/$Name/$ManifestVersionInc/Content/LICENSE.txt" `
    -ProjectUri "$($data.ProjectUri)" `
    -FunctionsToExport @($FunctionsToExport) `
    -ModuleVersion "$ManifestVersionInc" `
    -RootModule "$($data.RootModule)" `
    -Author "$($data.Author)" `
    -RequiredModules ($RequiredMod)
    

    (Get-Content -path "$PackageManifest") | Set-Content -Encoding default -Path "$PackageManifest"


    [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    $title = 'NuGetApiKey'
    $msg   = "Enter you powershell gallery NuGetApiKey:`n $PackageManifest"
    $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
    $global:progresspreference = 'SilentlyContinue'    # Subsequent calls do not display UI.
    Publish-Module -Path "$PackageDirectory" -NuGetApiKey "$text" -Repository "PSGallery"
    $global:progresspreference = 'Continue'            # Subsequent calls do display UI.
    Write-Host "Uploaded $Name version: $ManifestVersionInc"

}

