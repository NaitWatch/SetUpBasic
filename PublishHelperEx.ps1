$ErrorActionPreference = 'Stop'

function RestoreModule {

    param(
        [Parameter(Mandatory)]
        [string]$PackageName
    )

    $PackageDirectory = "$PSScriptRoot\$PackageName"

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    #Create a new directory if the directory for this package do not exist
    if(!(test-path -PathType container $PackageDirectory))
    {
        $onlineModule = $null
        try {
            $onlineModule = $(Find-Module -Name $PackageName)
        }
        catch {
            $onlineModule = $null
        }
    
        if ($null -ne $onlineModule)
        {
            New-Item -ItemType Directory -Path $PackageDirectory

            $result = Invoke-WebRequest -Method GET -Uri "https://www.powershellgallery.com/api/v2/package/$($onlineModule.Name)/$($onlineModule.Version)" -UseBasicParsing
    
            $BaseUriSegs = $result.BaseResponse.ResponseUri.Segments
            $Name = $BaseUriSegs[$BaseUriSegs.Count-1]
            $path = "$(Join-Path $PSScriptRoot $Name).zip"
            
        
            $file = [System.IO.FileStream]::new($path, [System.IO.FileMode]::Create)
            $file.write($result.Content, 0, $result.RawContentLength)
            $file.close()
        
            Expand-Archive -Path "$path" -Destination "$PackageDirectory" -Force
    
            [System.IO.File]::Delete($path)
    
            Remove-Item -Recurse -Force "$PackageDirectory\_rels"
            Remove-Item -Recurse -Force "$PackageDirectory\package"
            Remove-Item -Force -LiteralPath "$PackageDirectory\[Content_Types].xml"
            Remove-Item -Force -Path "$PackageDirectory\$PackageName.nuspec"

            Write-Host "Default files, latst version have been downloaded to $PackageDirectory."
            Exit 0
        }
    }

 
}

function CreateOrContinueModule {

    param(
        [Parameter(Mandatory)]
        [string]$PackageName,
        [Parameter(Mandatory)]
        [string]$Author,
        [Parameter(Mandatory)]
        [string]$DefaultCommandPrefix,
        [switch]$NoDownload
    )

    $PackageDirectory = "$PSScriptRoot\$PackageName"

    if(-Not $NoDownload) {
        RestoreModule -PackageName "$PackageName"
    }
    

$lic = `
@"
    MIT License

    Copyright (c) $(get-date -Format yyyy) $Author
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
"@

$psm1RootModule = `
@"

. "`$PSScriptRoot\$PackageName.ps1"

function Out-$($DefaultCommandPrefix)Hello {
    Out-Private$($DefaultCommandPrefix)Hello
    Write-Host "Use Get-Verb prefixes - your prefix + command e.g. Out-SubHello"
    Write-Host "Don't forget to list newly added function in the module manifest .psd1 file, section FunctionsToExport= "
}

"@

$ps1RootModule = `
@"
function Out-Private$($DefaultCommandPrefix)Hello {
    Write-Host ("Hello world form: {0} ." -f `$MyInvocation.MyCommand)
}
"@

    #Create a new directory if the directory for this package do not exist
    if(!(test-path -PathType container $PackageDirectory))
    {
        New-Item -ItemType Directory -Path $PackageDirectory  | Out-Null

            #Create a empty root module if no rootmodule exists
        if (!(Test-Path "$PackageDirectory\$PackageName.psm1"))
        {
            New-Item -path "$PackageDirectory" -name "$PackageName.psm1" -type "file" -value "$psm1RootModule"  | Out-Null
        }

        #Create a empty root module if no rootmodule exists
        if (!(Test-Path "$PackageDirectory\$PackageName.ps1"))
        {
            New-Item -path "$PackageDirectory" -name "$PackageName.ps1" -type "file" -value "$ps1RootModule"  | Out-Null
        }

        #Create a default license 
        if (!(Test-Path "$PackageDirectory\LICENSE.txt"))
        {
            New-Item -path "$PackageDirectory" -name "LICENSE.txt" -type "file" -value "$lic"  | Out-Null
        }

        if (!(Test-Path "$PackageDirectory\$PackageName.psd1"))
        {
            $guid = "$([guid]::NewGuid())"

            New-ModuleManifest `
            -Path "$PackageDirectory\$PackageName.psd1" `
            -GUID "$guid" `
            -Description "Powershell module $PackageName. This module is under construction and just uploaded for testing purposes." `
            -Tags @('alpha',$PackageName) `
            -LicenseUri "https://www.powershellgallery.com/packages/$PackageName/0.0.0.0/Content/LICENSE.txt" `
            -ProjectUri "https://www.powershellgallery.com/packages/$PackageName" `
            -FunctionsToExport @("Out-$($DefaultCommandPrefix)Hello") `
            -ModuleVersion "0.0.0.0" `
            -RootModule "$PackageName.psm1" `
            -Author "$Author"

            (Get-Content -path "$PackageDirectory\$PackageName.psd1") | Set-Content -Encoding default -Path "$PackageDirectory\$PackageName.psd1"
            
        }

        Write-Host "Default files have been created in $PackageDirectory." -ForegroundColor black -BackgroundColor white
        Write-Host "You can import your module in the current session. -> " -NoNewline
        Write-Host "Import-Module "".\$PackageName\$PackageName.psd1"" -Verbose -Force" -ForegroundColor Yello
        Write-Host "If you want to check the imported commands in the current session. -> " -NoNewline
        Write-Host "Get-Module $PackageName | ForEach-Object { Get-Command -Module `$PSItem }" -ForegroundColor Yello
        Exit 0
    }

 
}

function PublishModule
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



#Template-SubNewPSModule -PackageName "SetUpBasic.Publish" -VerbPrefix "Publish" -ModulePrefix "Sub" -Author "Naitwatch" 
#Template-SubNewPSModule -PackageName "SetUpBasic.Template" -VerbPrefix "Template" -ModulePrefix "Sub" -Author "Naitwatch" 

#Publish-SubPSModule -PackageName "SetUpBasic.Template"
#Publish-SubPSModule -PackageName "SetUpBasic.Publish"
Publish-SubPSModule -PackageName "SetUpBasic"

<#
RequiredModules =@(
    @{ModuleName="SetUpBasic.Publish"; ModuleVersion="0.0.0.1"; GUID="cfc45206-1e49-459d-a8ad-5b571ef94857"},
    @{ModuleName="SetUpBasic.Template"; ModuleVersion="0.0.0.1"; GUID="cfc45206-1e49-459d-a8ad-5b571ef94857"}
)
#>