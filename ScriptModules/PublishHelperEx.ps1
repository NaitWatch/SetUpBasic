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


function Dd {
    Write-Host $MyInvocation.Line
}

#Template-SubNewPSModule -PackageName "SetUpBasic.TaskScheduler" -VerbPrefix "New" -ModulePrefix "Sub" -Author "Naitwatch" 
#Template-SubNewPSModule -PackageName "SetUpBasic.Template" -VerbPrefix "Template" -ModulePrefix "Sub" -Author "Naitwatch" 

Publish-SubPSModule -Name "SetUpBasic.Update"
Publish-SubPSModule -Name "SetUpBasic.TaskScheduler"

#Publish-SubPSModule -Name "SetUpBasic.Publish"
#Publish-SubPSModule -PackageName "SetUpBasic.Publish"
#Publish-SubPSModule -PackageName "SetUpBasic.Template"
#Publish-SubPSModule -PackageName "SetUpBasic"

#Publish-SubPSModule -PackageName "SetUpBasic.Publish"
#Publish-SubPSModule -PackageName "SetUpBasic.Update"
#Publish-SubPSModule -PackageName "SetUpBasic"

<#
RequiredModules =@(
    @{ModuleName="SetUpBasic.Publish"; ModuleVersion="0.0.0.1"; GUID="cfc45206-1e49-459d-a8ad-5b571ef94857"},
    @{ModuleName="SetUpBasic.Template"; ModuleVersion="0.0.0.1"; GUID="cfc45206-1e49-459d-a8ad-5b571ef94857"}
)

New-SubTask -Name "1aaatesting" -Program "C:\temp\test.ps1" -HideScript $true
#>

function test{
   

    #Get-ScheduledTask -TaskPath '*' | where-object { $_.TaskPath -Like '*xxxx*' } | ForEach-Object { Unregister-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -Confirm:$false }
    
    #must be x64 session
    $usr = "local"
    $pawd = "123"
    Remove-LocalUser -Name "$usr" | Out-Null
    New-LocalUser "$usr" -Password (ConvertTo-SecureString "$pawd" -AsPlainText -Force) -FullName "$usr" -Description "$usr" -AccountNeverExpires -PasswordNeverExpires -UserMayNotChangePassword
    Add-LocalGroupMember -Group "Administrators" -Member "$usr"

    Stop-Service -Name "Fax" -Force
    Set-Service  -Name "Fax" -Startuptype Disable
    #Remove-Service -Name "Fax"

    #test
    #$x = 1
}