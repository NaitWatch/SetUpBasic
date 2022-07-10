
function GetInfo{
    param($ComputerName)
    Get-WmiObject -ComputerName $ComputerName -Class Win32_BIOS
    Write-Host "fooupdate"
}   

Export-ModuleMember -Function 'GetInfo'
