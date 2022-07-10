
function GetInfo{
    param($ComputerName)
    Get-WmiObject -ComputerName $ComputerName -Class Win32_BIOS
}   

Export-ModuleMember -Function 'GetInfo'
