#Import-Module Posh-SSH

$VerbosePreference = "Continue"

#$remote_addr = bash.exe -c "ifconfig eth0 | grep 'inet '"
$remote_addr = bash.exe -c "ip addr show dev eth0 | grep 'inet '"
Write-Verbose "Found IP information on WSL Host [$remote_addr]"
#$remote_addr = "172.30.216.220"
$found = $remote_addr -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';
Write-Verbose "IP Found from remote host is [$found]"

if( $found ){
  $remote_addr = $matches[0];
  Write-Verbose "WSL Address updated to [$remote_addr]"
} else{
  Write-Output "The Script Exited, the ip address of WSL 2 cannot be found";
  exit;
}

#[Ports]

#All the ports you want to forward separated by comma
$ports=@(53,80,443,10000,3000,5000);
Write-Verbose "Ports to be opened are [$ports]"

#[Static ip]
#You can change the addr to your ip config to listen to a specific address
#$addr='192.168.1.24';
$addr=(Get-NetIPConfiguration |
        Where-Object {
          $_.IPv4DefaultGateway -ne $null -and
          $_.NetAdapter.Status -ne "Disconnected"
        }
      ).IPv4Address.IPAddress
#Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin DHCP | Select-Object IPAddress
Write-Verbose "Windows Host Address is [$addr]"

$ports_a = $ports -join ",";
Write-Verbose "Ports to be opened as csv list is [$ports_a]"

Write-Output "Remove Firewall Exception Rules"
Remove-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock'

for( $i = 0; $i -lt $ports.length; $i++ ){
  $port = $ports[$i];
  Write-Output "Add Exception Rules for inbound and outbound for port [$port]" 
  New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Outbound -LocalPort "$port" -Action Allow -Protocol TCP;
  New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Inbound -LocalPort "$port" -Action Allow -Protocol TCP;
  
  Write-Output "Removing Proxy for Port [$port]."
  Write-Output "delete v4tov4 listenport=$port listenaddress=$addr"
  #Stop-SSHPortForward -BoundPort $port -BoundHost $addr
  netsh interface portproxy delete v4tov4 listenport=$port listenaddress=$addr
  
  Write-Output "Adding new proxy rule from [$addr] to [$remote_addr] for port [$port]."
  #New-SSHRemotePortForward -LocalAdress $addr -LocalPort $port -RemoteAddress $remote_addr -RemotePort $port
  netsh interface portproxy add v4tov4 listenport=$port listenaddress=$addr connectport=$port connectaddress=$remoteport
  Write-Output "End of port loop."
}

Write-Output "Out of Port Proxy Loop. Fini."