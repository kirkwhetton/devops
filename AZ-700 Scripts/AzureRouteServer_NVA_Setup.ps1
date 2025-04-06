# Install required Windows features.
$Features = @("RemoteAccess","RSAT-RemoteAccess-PowerShell","Routing")
Install-WindowsFeature $Features
Install-RemoteAccess -VpnType RoutingOnly

# Configure BGP & Router ID on the Windows Server
Add-BgpRouter -BgpIdentifier 10.1.2.4 -LocalASN 65001

# Configure Azure Route Server as a BGP Peer.
Add-BgpPeer -LocalIPAddress 10.1.2.4 -PeerIPAddress 10.1.0.68 -PeerASN 65515 -Name RS_IP1
Add-BgpPeer -LocalIPAddress 10.1.2.4 -PeerIPAddress 10.1.0.69 -PeerASN 65515 -Name RS_IP2

# Originate and announce BGP routes.
Add-BgpCustomRoute -network 172.16.1.0/24
Add-BgpCustomRoute -network 172.16.2.0/24 