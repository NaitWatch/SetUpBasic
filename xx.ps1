$ErrorActionPreference = 'Stop'

function CreateMinModule {

    param(
        [Parameter(Mandatory)]
        [string]$PackageName,
        [Parameter(Mandatory)]
        [string]$Author
    )



    $PackageDirectory = "$PSScriptRoot\$PackageName"

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

function Stub {
    PrivateStub
}

"@

$ps1RootModule = `
@"
function PrivateStub {
    Write-Host "Stub"
}
"@

    #Create a new directory if the directory for this package do not exist
    if(!(test-path -PathType container $PackageDirectory))
    {
          New-Item -ItemType Directory -Path $PackageDirectory
    }

    #Create a empty root module if no rootmodule exists
    if (!(Test-Path "$PackageDirectory\$PackageName.psm1"))
    {
        New-Item -path "$PackageDirectory" -name "$PackageName.psm1" -type "file" -value "$psm1RootModule"
    }

    #Create a empty root module if no rootmodule exists
    if (!(Test-Path "$PackageDirectory\$PackageName.ps1"))
    {
        New-Item -path "$PackageDirectory" -name "$PackageName.ps1" -type "file" -value "$ps1RootModule"
    }

    #Create a default license 
    if (!(Test-Path "$PackageDirectory\LICENSE"))
    {
        New-Item -path "$PackageDirectory" -name "LICENSE" -type "file" -value "$lic"
    }

    if (!(Test-Path "$PackageDirectory\$PackageName.psd1"))
    {
        $guid = "$([guid]::NewGuid())"

        New-ModuleManifest `
        -Path "$PackageDirectory\$PackageName.psd1" `
        -GUID "$guid" `
        -Description "Powershell module $PackageName. This module is under construction and just uploaded for testing purposes." `
        -Tags @('alpha',$PackageName) `
        -LicenseUri "https://www.powershellgallery.com/packages/$PackageName/0.0.0.1/Content/LICENSE" `
        -ProjectUri "https://www.powershellgallery.com/packages/$PackageName" `
        -FunctionsToExport @('Stub') `
        -ModuleVersion "0.0.0.1" `
        -RootModule "$PackageName.psm1" `
        -Author "$Author"
    }
}

function PushGallery {
    
    param(
        [Parameter(Mandatory)]
        [string]$PackageName,
        [Parameter(Mandatory)]
        [string]$Author,
        [Parameter(Mandatory)]
        [string[]]$FunctionsToExport,
        [Parameter(Mandatory)]
        [string[]]$Tags
    )

$lic = `
@"
    MIT License

    Copyright (c) 2022 $Author
    
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

    $PackageDirectory = "$PSScriptRoot\$PackageName"

    #Create a new directory if the directory for this package do not exist
    If(!(test-path -PathType container $PackageDirectory))
    {
          New-Item -ItemType Directory -Path $PackageDirectory
    }

    #Create a empty root module if no rootmodule exists
    if (!(Test-Path "$PackageDirectory\$PackageName.psm1"))
    {
        New-Item -path "$PackageDirectory" -name "$PackageName.psm1" -type "file" -value "#RootModule"
    }

    #Create a default license 
    if (!(Test-Path "$PackageDirectory\LICENSE"))
    {
        New-Item -path "$PackageDirectory" -name "LICENSE" -type "file" -value "$lic"
    }

    $onlineModule = $null

    try {
        $onlineModule = $(Find-Module -Name $PackageName)
        [version]$latestOnlineVersion = $onlineModule.Version
        $newVersion = "{0}.{1}.{2}.{3}" -f $latestOnlineVersion.Major, $latestOnlineVersion.Minor, $latestOnlineVersion.Build, ($latestOnlineVersion.Revision + 1)
    }
    catch {
        Write-Host "An error occurred."
        $newVersion = [version]"0.0.0.1"
    }

    if (!(Test-Path "$PackageDirectory\$PackageName.psd1"))
    {
        $guid = "$([guid]::NewGuid())"

        New-ModuleManifest `
        -Path "$PSScriptRoot\$PackageName\$PackageName.psd1" `
        -GUID "$guid" `
        -Description "Powershell module for basic windows os configuration, maintenance" `
        -Tags @($Tags) `
        -LicenseUri "https://www.powershellgallery.com/packages/$PackageName/$newVersion/Content/LICENSE" `
        -ProjectUri "https://www.powershellgallery.com/packages/$PackageName" `
        -FunctionsToExport @('x') `
        -ModuleVersion "$newVersion" `
        -RootModule "$PackageName.psm1" `
        -Author "$Author"
    }
    else {
        
        New-ModuleManifest `
        -Path "$PSScriptRoot\$PackageName\$PackageName.psd1" `
        -GUID "$($onlineModule.GUID)" `
        -Description "$($onlineModule.Description)" `
        -Tags @($Tags) `
        -LicenseUri "$($onlineModule.LicenseUri)" `
        -ProjectUri "$($onlineModule.ProjectUri)" `
        -FunctionsToExport @('') `
        -ModuleVersion "$newVersion" `
        -RootModule "$PackageName.psm1" `
        -Author "$Author"
    }

    [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    $title = 'NuGetApiKey'
    $msg   = 'Enter you powershell gallery NuGetApiKey:'
    $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
    $global:progresspreference = 'SilentlyContinue'    # Subsequent calls do not display UI.
    Publish-Module -Path "$PackageDirectory" -NuGetApiKey "$text" -Repository "PSGallery"
    $global:progresspreference = 'Continue'            # Subsequent calls do display UI.
    Write-Host "Finished"

}

function DownloadPackage {

    param(
        [Parameter(Mandatory)]
        [string]$PackageName
    )

    $PackageDirectory = "$PSScriptRoot\$PackageName"

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    #Create a new directory if the directory for this package do not exist
    if(!(test-path -PathType container $PackageDirectory))
    {
        New-Item -ItemType Directory -Path $PackageDirectory

        $onlineModule = $null
        try {
            $onlineModule = $(Find-Module -Name $PackageName)
        }
        catch {
            $onlineModule = $null
        }
    
        if ($null -ne $onlineModule)
        {
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
            Remove-Item -Force -Path "$PackageDirectory\SetUpBasic.nuspec"
        }
    }

 
}


DownloadPackage -PackageName "SetUpBasic"
#CreateMinModule -PackageName "ran" -Author "Nightwatch"
#PushGallery -PackageName "lingg" -Author "Nightwatch" -FunctionsToExport @('x') -Tags @('PSModule')
$ss=""



