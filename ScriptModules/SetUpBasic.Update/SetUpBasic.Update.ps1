$ErrorActionPreference = 'Stop'

function Private-Update-SubModule {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param(
        [string]$Name
    )

    if ((-not $PSBoundParameters.ContainsKey('Name')) -or ($Name -eq ""))
    {
        $Name = "SetupBasic.Update"
    }
    
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    try {
        $latestOnlineVersion = [System.Version](Find-Module -Name "$Name").Version
    }
    catch {
        $latestOnlineVersion = [System.Version]::new()
    }

    $localmodules = (Get-Module -ListAvailable "$Name") | Sort-Object Version -Descending

    if ($localmodules.Count -gt 1)
    {
        $latestLocalVersion = $localmodules[0].Version
    }
    elseif ($localmodules.Count -eq 1)
    {
        $latestLocalVersion = [System.Version]$localmodules.Version
    }
    else {
        $latestLocalVersion = [System.Version]::new()
    }

    [bool]$NeedUpdate = $false
    if ($latestOnlineVersion -gt $latestLocalVersion)
    {
        $NeedUpdate = $true
    }

    if ($NeedUpdate)
    {
        #Check for admin rights
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        $IsAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

        #Install the module
        if ($IsAdmin)
        {
            Install-Module -Name "$Name" -Scope AllUsers -Force -Repository "PSGallery" -AllowClobber -RequiredVersion "$latestOnlineVersion" -WarningAction SilentlyContinue
        }
        else {
            Install-Module -Name "$Name" -Scope CurrentUser -Force -Repository "PSGallery" -AllowClobber -RequiredVersion "$latestOnlineVersion" -WarningAction SilentlyContinue
        }

        <#
        #Check if module is loaded and remove
        $loaded = Get-Module "$Name" | ForEach-Object { Get-Command -Module $PSItem } | Group-Object -Property Version | Select-Object -Property Name
        foreach($item in $loaded)
        {
            Remove-Module -FullyQualifiedName @{ModuleName = "$Name"; RequiredVersion = "$($item.Name)"} -Force
            $loaded = Get-Module "$Name" | ForEach-Object { Get-Command -Module $PSItem } | Group-Object -Property Version | Select-Object -Property Name
        }
        #Import the latest version
        #Import-Module -FullyQualifiedName @{ModuleName = "$Name"; RequiredVersion = "$latestOnlineVersion"} -Force
        #>
        
    }
}
