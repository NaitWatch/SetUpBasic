
function GetInfo3{
    param($ComputerName)
    Get-WmiObject -ComputerName $ComputerName -Class Win32_BIOS
    Write-Host "fooupdate3"
}   

