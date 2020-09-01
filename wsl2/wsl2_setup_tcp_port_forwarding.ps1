#$remote_addr = bash.exe -c "ifconfig eth0 | grep 'inet '"
$remote_addr = bash.exe -c "ip addr | grep -Ee 'inet.*eth0'"
#$remote_ip = "172.30.216.220"
$found = $remote_addr -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';

if( $found ){
  $remote_addr = $matches[0];
} else{
  Write-Output "The Script Exited, the ip address of WSL 2 cannot be found";
  exit;
}

#[Ports]

#All the ports you want to forward separated by coma
$ports=@(80,443,10000,3000,5000);


#[Static ip]
#You can change the addr to your ip config to listen to a specific address
$addr='192.168.1.24';
$ports_a = $ports -join ",";


#Remove Firewall Exception Rules
Remove-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock'

#adding Exception Rules for inbound and outbound Rules
New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Outbound -LocalPort $ports_a -Action Allow -Protocol TCP;
New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Inbound -LocalPort $ports_a -Action Allow -Protocol TCP;

for( $i = 0; $i -lt $ports.length; $i++ ){
  $port = $ports[$i];
  #delete v4tov4 listenport=$port listenaddress=$addr
  Stop-SSHPortForward -BoundPort $port -BoundHost $addr
  #Invoke-Expression "netsh interface portproxy delete v4tov4 listenport=$port listenaddress=$addr";
  
  New-SSHRemotePortForward -LocalAdress $addr -LocalPort $port -RemoteAddress $remote_ip -RemotePort $port
  #Invoke-Expression "netsh interface portproxy add v4tov4 listenport=$port listenaddress=$addr connectport=$port connectaddress=$remoteport";
}