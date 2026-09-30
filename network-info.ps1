$adapter = Get-CimInstance Win32_NetworkAdapterConfiguration |
    Where-Object { $_.IPEnabled -eq $true } |
    Select-Object -First 1

if (-not $adapter) {
    Write-Host "Kein aktives Netzwerkinterface gefunden."
    exit
}

$ip = ($adapter.IPAddress | Where-Object { $_ -match '^\d+\.\d+\.\d+\.\d+$' })[0]
$subnet = ($adapter.IPSubnet | Where-Object { $_ -match '^\d+\.\d+\.\d+\.\d+$' })[0]
$gateway = $adapter.DefaultIPGateway
$dns = $adapter.DNSServerSearchOrder
$dhcp = if ($adapter.DHCPEnabled) { "Ja" } else { "Nein" }

[pscustomobject]@{
    Hostname    = $env:COMPUTERNAME
    IP          = $ip
    Subnetmaske = $subnet
    Gateway     = if ($gateway) { ($gateway -join ", ") } else { "Keine" }
    DNS         = if ($dns) { ($dns -join ", ") } else { "Keine" }
    DHCP        = $dhcp
} | Format-List
