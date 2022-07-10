# SetUpBasic
Powershell module for basic windows os configuration, maintenance

You can find the current published Module version here. https://www.powershellgallery.com/packages/SetUpBasic/

## To trust the PowershellGallery

### Add trust
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

### Remove trust
Revert: Set-PSRepository -Name "PSGallery" -InstallationPolicy Untrusted

## Installation:
I recommend adding `-Scope AllUsers` the module than will installed C:\Program Files\WindowsPowerShell\Modules instead of a user specific directory. This of course required Administrator rights.

### Install
```
Install-Module -Name SetupBasic
```
```
Install-Module -Name SetupBasic -Scope AllUsers
```

### Update
```
Update-Module -Name SetupBasic
```
```
Update-Module -Name SetUpBasic -Scope AllUsers
```

### Uninstall
```
Uninstall-Module -Name SetupBasic
```
```
Uninstall-Module -Name SetUpBasic -Scope AllUsers
```


## Listing:

### Show module and paths
```
Get-Module -ListAvailable SetUpBasic
```

### Show standard info
```
Find-Module -Name SetupBasic
```

## Current list of commands exported

### GetInfo
Sample: GetInfo 'localhost'

Description: Just a stub at the moment



