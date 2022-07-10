# SetUpBasic
Powershell module for basic windows os configuration, maintaince

You can find the current published Module version here. https://www.powershellgallery.com/packages/SetUpBasic/

## To trust the PowershellGallery

### Add trust
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

### Remove trust
Revert: Set-PSRepository -Name "PSGallery" -InstallationPolicy Untrusted

## Installation:

### Install
Install-Module -Name SetupBasic

### Update
Update-Module -Name SetUpBasic

### Uninstall
Uninstall-Module -Name SetUpBasic

## Listing:

### Show module and paths
Get-Module -ListAvailable SetUpBasic

### Show standard info
Find-Module -Name SetupBasic

## Current list of commands exported

### GetInfo
Sample: GetInfo 'localhost'

Description: Just a stub at the moment



