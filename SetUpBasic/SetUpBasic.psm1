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

function GetInfo4{
    GetInfo3 -ComputerName "localhost"
}   

