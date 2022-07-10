# SetUpBasic
Powershell module for basic windows os configuration, maintenance

You can find the current published Module version here. https://www.powershellgallery.com/packages/SetUpBasic/

## To trust the PowershellGallery

### Add powershell gallery and trust it to avoid confirmation dialogs.
```
Register-PSRepository -Default 2>$null ; Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
```

### Removing trust of a repository
```
Set-PSRepository -Name "PSGallery" -InstallationPolicy Untrusted
```

## Installation:
I recommend adding `-Scope AllUsers` the module than will installed C:\Program Files\WindowsPowerShell\Modules instead of a user specific directory. This of course required Administrator rights.

### Install
```
Install-Module -Name SetupBasic
```

### Update
```
Update-Module -Name SetUpBasic ; Remove-Module -Name SetUpBasic ; Import-Module -Name SetUpBasic ;  Find-Module -Name SetUpBasic
```

### Uninstall
```
Uninstall-Module -Name SetUpBasic ; Remove-Module -Name SetUpBasic
```



## Listing:

### Show module and paths
```
Get-Module -ListAvailable SetupBasic | Format-List
```

### Show standard info
```
Find-Module -Name SetupBasic
```

## Current list of commands exported

### GetInfo
Sample: GetInfo 'localhost'

Description: Just a stub at the moment



