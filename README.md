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

**Installation screenshot Win10**

![grafik](https://user-images.githubusercontent.com/97656046/180610957-2b511bc8-0e97-4033-ad9a-41ea03f6f4b6.png)

### Update
```
SubUpdate ; SubClean
```

### List of SubModules
```
Install-Module -Name SetUpBasic.Publish -Scope CurrentUser -Force
Install-Module -Name SetUpBasic.Template -Scope CurrentUser -Force
Install-Module -Name SetUpBasic.Update -Scope CurrentUser -Force
Install-Module -Name SetUpBasic.TaskScheduler -Scope CurrentUser -Force
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

Updates your local computer with the latest module version from the PSGallery, if a newer version is available.
```
Update-SubModule -Name "MyModule"
```

### Maintenance.

Creates a windows scheduled task that runs user at logon, -HideScript $true invokes SubSystemWin.exe which hides the console window, see Windows Task Scheduler. Source of the SubSystemWin.exe can be found in the repository under Binaries
```
New-SubTask -Name "foops1" -Program "C:\temp\foo.ps1" -HideScript $true
```

Creates a scheduled task that will be executed at a specific time. Admin rights are required because of SYSTEM user execution. If you omit -day parameter the default ('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday') is used.
```
New-SubTask -Name "foops1" -Program "C:\temp\foo.ps1" -ScheduleType TIME -LogonUserType SYSTEM -Time "04:00:00" -day @("Sunday")
```

Creates a windows scheduled task that runs user at logon, foo.ps1 will be created with a simple template.
```
New-SubCreateDefaultLogonTask -Name "foops1" -Location "C:\temp\foo.ps1"
New-SubCreateDefaultLogonTask -Name "foocmd" -Location "C:\temp\foo.cmd"
#The next line would modify the default example file foo.ps1 to run under the system account at the same time each day.
#New-SubTask -Name "foops1" -Program "C:\temp\foo.ps1" -ScheduleType TIME -LogonUserType SYSTEM -Time "04:00:00"
```

