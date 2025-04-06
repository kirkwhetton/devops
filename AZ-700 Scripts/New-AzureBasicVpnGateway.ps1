# Variables
$Location = "<Location>" # e.g., "East US", "West Europe"
$ResourceGroupName = "<RESOURCE_GROUP_NAME>" # Replace with your Resource Group name
$VNetName = "<VIRTUAL_NETWORK_NAME>" # Replace with your Virtual Network name
$PIPName = "<Public_IP_Name>" # Replace with your Public IP name
$VpnGwName = "<VPN_GATEWAY_NAME>" # Replace with your VPN Gateway name
$VpnGwIpConfigName = "<VPN_GW_IP_CONFIG_NAME>" # Replace with your VPN Gateway IP Configuration name

# Acquire Public IP for the Virtual Network Gateway
$VpnGwIp = New-AzPublicIpAddress -Name $PIPName -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" -Sku "Basic"

# Create Gateway IP address configuration
$Vnet = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName
$Subnet = Get-AzVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -VirtualNetwork $Vnet
$VpnGwIpConfig = New-AzVirtualNetworkGatewayIpConfig -Name $VpnGwIpConfigName -SubnetId $Subnet.Id -PublicIPAddressId $VpnGwIp.Id

# Create the VPN Gateway
New-AzVirtualNetworkGateway -Name $VpnGwName -ResourceGroupName $ResourceGroupName -Location $Location -IpConfigurations @($VpnGwIpConfig) -GatewayType Vpn -VpnType PolicyBased -GatewaySku Basic
Get-AzVirtualNetworkGateway -Name $VpnGwName -ResourceGroupName $ResourceGroupName