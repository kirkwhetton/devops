# Variables
$Location = "<Location>" # e.g., "East US", "West Europe"
$ResourceGroupName = "<RESOURCE_GROUP_NAME>" # Replace with your Resource Group name
$VNetName = "<VIRTUAL_NETWORK_NAME>" # Replace with your Virtual Network name
$PIPName = "<PUBLIC_IP_NAME>" # Replace with your Public IP name
$VpnGwName = "<VPN_GATEWAY_NAME>" # Replace with your VPN Gateway name
$VpnGwIpConfigName = "<VPN_GW_IP_CONFIG_NAME>" # Replace with your VPN Gateway IP Configuration name
$GatewaySKU = "<GATEWAY_SKU>" # Replace with your Gateway SKU (e.g., VpnGw1, VpnGw2, etc.)
$ConnectionName = "<CONNECTION_NAME>" # Replace with your Connection name

# Acquire Public IP for the Virtual Network Gateway
$VpnGwIp = New-AzPublicIpAddress -Name $PIPName -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" -Sku "Standard"

# Create Gateway IP address configuration
$Vnet = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName
$Subnet = Get-AzVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -VirtualNetwork $Vnet
$VpnGwIpConfig = New-AzVirtualNetworkGatewayIpConfig -Name $VpnGwIpConfigName -SubnetId $Subnet.Id -PublicIPAddressId $VpnGwIp.Id

# Create the VPN Gateway
$AzVPNGW = New-AzVirtualNetworkGateway -Name $VpnGwName -ResourceGroupName $ResourceGroupName -Location $Location -IpConfigurations @($VpnGwIpConfig) -GatewayType Vpn -VpnType PolicyBased -GatewaySku $GatewaySKU
Get-AzVirtualNetworkGateway -Name $VpnGwName -ResourceGroupName $ResourceGroupName

New-AzVirtualNetworkGatewayConnection -Name $ConnectionName -ResourceGroupName $ResourceGroupName -Location $Location -VirtualNetworkGateway1 $AzVPNGW -ConnectionType VPNClient