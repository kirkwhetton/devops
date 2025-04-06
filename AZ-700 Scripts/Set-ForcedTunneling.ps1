# Variables
$resourceGroupName = "<RESOURCE_GROUP_NAME>" # Replace with your Resource Group name
$vnetName = "<VIRTUAL_NETWORK_NAME>" # Replace with your Virtual Network name
$location = "<LOCATION>" # e.g., "East US", "West Europe"
$routeTableName = "<ROUTE_TABLE_NAME>" # Replace with your Route Table name
$subnetName = "<SUBNET_NAME>" # Replace with your Subnet name

# Retrieve Existing Virtual Network
$vnet = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vnetName

# Create a Route Table for Forced Tunneling
$routeTable = New-AzRouteTable -ResourceGroupName $resourceGroupName -Location $location -Name $routeTableName

# Add a User-Defined Route (UDR) for redirecting internet traffic
Add-AzRouteConfig -RouteTable $routeTable -Name "DefaultRoute" -AddressPrefix "0.0.0.0/0" -NextHopType "VirtualNetworkGateway"

# Update the Route Table with the new route
Set-AzRouteTable -RouteTable $routeTable

# Apply the Route Table to the Subnet
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet
$subnet.RouteTable = $routeTable
$vnet | Set-AzVirtualNetwork
