function Private-New-SubTask {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param()
    Write-Host ("Hello world form: {0} ." -f $MyInvocation.MyCommand)
}

#(Get-ChildItem -recurse -LiteralPath 'C:\Windows\System32\Tasks' -File) |  where-object { $_.VersionInfo -Like '*RBCM*' } | Select-Object -Property FullName
function test{
   

    #Get-ScheduledTask -TaskPath '*' | where-object { $_.TaskPath -Like '*xxxx*' } | ForEach-Object { Unregister-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -Confirm:$false }
    
    #must be x64 session
    $usr = "local"
    $pawd = "123"
    Remove-LocalUser -Name "$usr" | Out-Null
    New-LocalUser "$usr" -Password (ConvertTo-SecureString "$pawd" -AsPlainText -Force) -FullName "$usr" -Description "$usr" -AccountNeverExpires -PasswordNeverExpires -UserMayNotChangePassword
    Add-LocalGroupMember -Group "Administrators" -Member "$usr"

    Stop-Service -Name "Fax" -Force
    Set-Service  -Name "Fax" -Startuptype Disable
    #Remove-Service -Name "Fax"

    #test
    #$x = 1
}


