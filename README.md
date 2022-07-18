# SetUpBasic
Powershell module for basic windows os configuration, maintenance

You can find the current published Module version here.

https://www.powershellgallery.com/packages/SetUpBasic/

Take a look at "PublishHelperEx.ps1" this can create a powershell modul template. If you have a powershell gallery account and the corresponding key you can create a Module with seconds and upload it to the PSGallery. I will release it as SetUpBasic submodule later on.

```
CreateOrContinueModule -PackageName "MyModule" -Author "MyName" -DefaultCommandPrefix "My" -NoDownload
PublishModule -PackageName "MyModule"
```

## To trust the PowershellGallery

### Add powershell gallery and trust it to avoid confirmation dialogs.
```
Register-PSRepository -Default 2>$null ; Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
```

## Installation:
I recommend adding `-Scope AllUsers` the module than will installed C:\Program Files\WindowsPowerShell\Modules instead of a user specific directory. This of course required Administrator rights.

#### Install
```
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force ;
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ;
Install-Module -Name SetupBasic -Scope CurrentUser -Force
```

#### Update
```
SubUpdate ; SubClean
```


## Inspection (Powershell standard commands):

List the currently installed modules versions on your computer.
```
Get-Module -ListAvailable SetupBasic | Format-List
```

Displays the latest online version available.
```
Find-Module -Name SetupBasic
```

Displays function/commands loaded in your current session.
```
Get-Module SetupBasic | ForEach-Object { Get-Command -Module $PSItem }
```
