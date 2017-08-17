$Computers = Get-Content $($PSScriptRoot + "\servers.csv")

$results = foreach ($computer in $Computers)
{
    If (test-connection -ComputerName $computer -Count 1 -Quiet)
    { 
        $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computer) 
        $regKey= $reg.OpenSubKey("SYSTEM\CurrentControlSet\services\LanmanServer\Parameters",$true) 
        $regKey.SetValue("IRPStackSize",30) 
    }
    else 
    { 
        Write-Host "$computer unreachable" 
    } 

    New-Object -TypeName PSObject -Property @{
        'Computer'=$computer
        'Status'=$status
    }
}

$results | Export-Csv -NoTypeInformation -Path "./out.csv"