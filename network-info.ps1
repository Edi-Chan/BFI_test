$adapter = Get-CimInstance Win32_NetworkAdapterConfiguration |
    Where-Object { $_.IPEnabled -eq $true } |
    Select-Object -First 1

if (-not $adapter) {
    Write-Host "Kein aktives Netzwerkinterface gefunden." -ForegroundColor Red
    exit
}

$ip = ($adapter.IPAddress | Where-Object { $_ -match '^\d+\.\d+\.\d+\.\d+$' })[0]
$subnet = ($adapter.IPSubnet | Where-Object { $_ -match '^\d+\.\d+\.\d+\.\d+$' })[0]
$gateway = $adapter.DefaultIPGateway
$dns = $adapter.DNSServerSearchOrder
$dhcp = if ($adapter.DHCPEnabled) { "Ja" } else { "Nein" }

Write-Host "" 
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Netzwerkinformationen des Computers " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

[pscustomobject]@{
    Hostname    = $env:COMPUTERNAME
    IP          = $ip
    Subnetmaske = $subnet
    Gateway     = if ($gateway) { ($gateway -join ", ") } else { "Keine" }
    DNS         = if ($dns) { ($dns -join ", ") } else { "Keine" }
    DHCP        = $dhcp
} | ForEach-Object {
    $color = if ($_.DHCP -eq "Ja") { "Green" } else { "Yellow" }

    Write-Host ("Hostname:   " + $_.Hostname) -ForegroundColor Cyan
    Write-Host ("IP:         " + $_.IP) -ForegroundColor White
    Write-Host ("Subnet:     " + $_.Subnetmaske) -ForegroundColor White
    Write-Host ("Gateway:    " + $_.Gateway) -ForegroundColor Magenta
    Write-Host ("DNS:        " + $_.DNS) -ForegroundColor Blue
    Write-Host ("DHCP:       " + $_.DHCP) -ForegroundColor $color
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
