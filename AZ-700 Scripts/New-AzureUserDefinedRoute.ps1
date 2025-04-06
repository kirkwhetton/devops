# Login to Azure if not already logged in, not necessary if running in Azure Cloud Shell
Connect-AzAccount

$ResourceGroupName = "<RESOURCE_GROUP_NAME>" # Replace with your Resource Group name
$Location = "<LOCATION>" # e.g., "East US", "West Europe"
$VnetName = "<VIRTUAL_NETWORK_NAME>" # Replace with your Virtual Network name
$SubnetName = "<Subnet_Name>" # Replace with your Subnet name
$RouteTableName = "<ROUTE_TABLE_NAME>" # Replace with your Route Table name
$RouteName = "<ROUTE_NAME>" # Replace with your Route name
$NextHopIPAddress = "<NEXT_HOP_IP_ADDRESS>" # Replace with your Next Hop IP Address

# Create the Route Table
Write-Host "Creating Route Table..." -ForegroundColor Cyan
$RouteTable = New-AzRouteTable `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -Name $RouteTableName

# Add a route to the Route Table
Write-Host "Adding route '$RouteName' to Route Table..." -ForegroundColor Cyan
Add-AzRouteConfig `
    -Name $RouteName `
    -RouteTable $RouteTable `
    -AddressPrefix "0.0.0.0/0" `
    -NextHopType "VirtualAppliance" `
    -NextHopIpAddress $NextHopIPAddress

# Update the Route Table with the new route
Set-AzRouteTable -RouteTable $RouteTable

# Associate the Route Table with the subnet
Write-Host "Associating Route Table with Subnet..." -ForegroundColor Cyan
$VNet = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VnetName
$Subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $VNet -Name $SubnetName
Set-AzVirtualNetworkSubnetConfig `
    -VirtualNetwork $VNet `
    -Name $SubnetName `
    -AddressPrefix $Subnet.AddressPrefix `
    -RouteTable $RouteTable

# Apply the subnet changes to the Virtual Network
Write-Host "Applying changes to the Virtual Network..." -ForegroundColor Cyan
Set-AzVirtualNetwork -VirtualNetwork $VNet

Write-Host "User Defined Route (UDR) and route configuration completed!" -ForegroundColor Green
