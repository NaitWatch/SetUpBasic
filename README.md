# SetUpBasic
Powershell module for basic windows os configuration, maintenance

You can find the current published Module version here. https://www.powershellgallery.com/packages/SetUpBasic/

## To trust the PowershellGallery

### Add powershell gallery and trust it to avoid confirmation dialogs.
```
Register-PSRepository -Default 2>$null ; Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
```

## Installation:
I recommend adding `-Scope AllUsers` the module than will installed C:\Program Files\WindowsPowerShell\Modules instead of a user specific directory. This of course required Administrator rights.

### Install
```
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ;
Install-Module -Name SetupBasic -Scope CurrentUser -Force
```

### Update
```
SubUpdate ; SubClean
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

### SubUpdate
```
SubUpdate #Updates this powershell module
```

### SubClean
```
SubClean #Cleans up old version of this powershell module on the computer
```

### SubInstallModUpTask
```
SubInstallModUpTask #Installs a scheduled task on the computer to update powershell modules
```




