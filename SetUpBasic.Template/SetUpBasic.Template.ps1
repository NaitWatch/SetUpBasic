$ErrorActionPreference = 'Stop'


function Private-Template-SubNewPSModule {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param(
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$PackageName,
        [Parameter(Mandatory)]
        [string]$Author,
        [Parameter(Mandatory)]
        [string]$VerbPrefix,
        [Parameter(Mandatory)]
        [string]$ModulePrefix
    )

    if ((-not $PSBoundParameters.ContainsKey('Path')) -or ($Path -eq ""))
    {
        $Path = Get-Location
    }

    if (-not (Test-Path -LiteralPath "$Path" -IsValid))
    {
        $Path = Get-Location
        Write-Warning "Invalid path detected. Path is now current directory. $Path"
    }

    if(!(Test-Path -PathType container $Path))
    {
        New-Item -ItemType Directory -Path $Path | Out-Null
        Write-Information "New directory created. $Path"
    }

    $PackageDirectory = "$Path\$PackageName"

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

function $($VerbPrefix)-$($ModulePrefix)ReplaceMe {
    Private-$($VerbPrefix)-$($ModulePrefix)ReplaceMe
    Write-Host "Use Get-Verb prefixes - your prefix + command e.g. Out-SubHello"
    Write-Host "Don't forget to list newly added function in the module manifest .psd1 file, section FunctionsToExport= "
}

"@

$ps1RootModule = `
@"
function Private-$($VerbPrefix)-$($ModulePrefix)ReplaceMe {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param()
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
            -FunctionsToExport @("$($VerbPrefix)-$($ModulePrefix)ReplaceMe") `
            -ModuleVersion "0.0.0.0" `
            -RootModule "$PackageName.psm1" `
            -Author "$Author"

            (Get-Content -path "$PackageDirectory\$PackageName.psd1") | Set-Content -Encoding default -Path "$PackageDirectory\$PackageName.psd1"
            
        }

        Write-Host "Default files have been created in $PackageDirectory." -ForegroundColor black -BackgroundColor white
        Write-Host "You can import your module in the current session. -> " -NoNewline
        Write-Host "Import-Module ""$PackageDirectory\$PackageName.psd1"" -Verbose -Force" -ForegroundColor Yello
        Write-Host "If you want to check the imported commands in the current session. -> " -NoNewline
        Write-Host "Get-Module $PackageName | ForEach-Object { Get-Command -Module `$PSItem }" -ForegroundColor Yello
    }
}