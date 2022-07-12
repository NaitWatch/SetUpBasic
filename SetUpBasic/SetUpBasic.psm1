
function GetInfo2{
    param($ComputerName)
    Get-WmiObject -ComputerName $ComputerName -Class Win32_BIOS
    Write-Host "fooupdate2"
}   

function GetInfo{
    param($ComputerName)
    Get-WmiObject -ComputerName $ComputerName -Class Win32_BIOS
    Write-Host "fooupdate"
}   

function Refresh{
    short
}   

function Dump{
    Write-Host "6"
}   

function GetInfo4{
    GetInfo3 -ComputerName "localhost"
    scrip
}   

function iamadmin{
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $result = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    Write-Host "$result"
}   

function ExtractLinks{
    param (
        [Parameter(Mandatory)]
        [string]$url
     )
     $ret = DownloadString -url $url
     ExtractLinks2 -html $ret -url $url

}   


