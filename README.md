# SetUpBasic
Powershell module for basic windows os configuration, maintenance

You can find the current published Module version here.

https://www.powershellgallery.com/packages/SetUpBasic/


## To trust the PowershellGallery

### Add powershell gallery and trust it to avoid confirmation dialogs.
```
Register-PSRepository -Default 2>$null ; Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
```

## Installation:
I recommend adding `-Scope AllUsers` the module than will installed C:\Program Files\WindowsPowerShell\Modules instead of a user specific directory. This of course required Administrator rights.
The Module SetupBasic will hold and install dependencys of the other SubModules

### Install (Main Module)
```
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force ;
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ;
Install-Module -Name SetupBasic -Scope CurrentUser -Force
```

### Update
```
SubUpdate ; SubClean
```

### List of SubModules
```
Install-Module -Name SetUpBasic.Publish -Scope CurrentUser -Force
Install-Module -Name SetUpBasic.Template -Scope CurrentUser -Force
Install-Module -Name SetUpBasic.Update -Scope CurrentUser -Force
```


## Inspection (Powershell standard commands):

List the currently installed modules versions on your computer.
```
Get-Module -ListAvailable SetupBasic*
```

Displays the latest online version available.
```
Find-Module -Name SetupBasic*
```

Displays function/commands loaded in your current session.
```
Get-Module SetupBasic* | ForEach-Object { Get-Command -Module $PSItem }
```

## Alpha commands:

### Publish a Module in under a minute.
(of course you need a microsoft account, and a PSGallery NugetApiKey https://www.powershellgallery.com/account/apikeys)

Creates a directory and places powershell script module standard files in it, ready to publish it to the powershell gallery.
```
Template-SubNewPSModule -Path "C:\temp" -Name "MyModule" -Author "Me" -VerbPrefix "Out" -ModulePrefix "MyMod"
```

Publish the powershell script module to the powershell gallery.
```
Publish-SubPSModule -Path "C:\temp" -Name "MyModule"
```

Updates a powershell module if necessaray from the PSGallery
```
Update-SubModule -Name "MyModule"
```

Creates a windows scheduled task that runs user at logon, $HideScript invokes SubSystemWin.exe which hides the console window, see Windows Task Scheduler
```
New-SubTask -Name "foo" -Program "C:\temp\foo.ps1" -HideScript $true
```

Creates a windows scheduled task that runs user at logon, foo.ps1 will be created with a simple template.
```
New-SubCreateDefaultLogonTask -Name "foo" -Program "C:\temp\foo.ps1" 
```

