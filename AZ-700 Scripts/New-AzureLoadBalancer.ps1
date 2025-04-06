# Variables
$ResourceGroupName = "<RESOURCE_GROUP_NAME>" # Replace with your Resource Group name
$Location = "<LOCATION>" # e.g., "East US", "West Europe"
$LBName = "<LOAD_BALANCER_NAME>" # Replace with your Load Balancer name
$PublicIPName = "<Public_IP_Name>" # Replace with your Public IP name
$FrontendIPName = "<FRONTEND_IP_NAME>" # Replace with your Frontend IP name
$BackendPoolName = "<BACKEND_POOL_NAME>" # Replace with your Backend Pool name
$ProbeName = "<PROBE_NAME>" # Replace with your Probe name
$LbRuleName = "<LOAD_BALANCER_RULE_NAME>" # Replace with your Load Balancer Rule name
$VM1 = "<VM01>" # Replace with your VM1 name
$VM2 = "<VM02>" # Replace with your VM2 name

# Get resource group
Get-AzResourceGroup -Name $ResourceGroupName

# Create Public IP for Load Balancer
$PublicIP = New-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Location $Location -Name $PublicIpName -AllocationMethod Static -Sku Standard

# Create Load Balancer Frontend IP Configuration
$FrontendIPConfig = New-AzLoadBalancerFrontendIpConfig -Name $FrontendIPName -PublicIpAddress $PublicIP

# Create Backend Pool
$BackendPool = New-AzLoadBalancerBackendAddressPoolConfig -Name $BackendPoolName

# Create Health Probe
$Probe = New-AzLoadBalancerProbeConfig -Name $ProbeName -Protocol Tcp -Port 80 -IntervalInSeconds 15 -ProbeCount 2

# Create Load Balancer Rule
$LbRule = New-AzLoadBalancerRuleConfig -Name $LbRuleName -Protocol Tcp -FrontendPort 80 -BackendPort 80 -FrontendIpConfiguration $FrontendIPConfig -BackendAddressPool $BackendPool -Probe $Probe

# Create Load Balancer
New-AzLoadBalancer -ResourceGroupName $ResourceGroupName -Location $Location -Name $LbName -Sku Standard -FrontendIpConfiguration $FrontendIpConfig -BackendAddressPool $BackendPool -Probe $Probe -LoadBalancingRule $LbRule

# Retrieve Existing VMs and Their NICs
$VM1Nic = Get-AzNetworkInterface | Where-Object { $_.VirtualMachine.Id -match $VM1 }
$VM2Nic = Get-AzNetworkInterface | Where-Object { $_.VirtualMachine.Id -match $VM2 }

# Associate NICs with Load Balancer Backend Pool
if ($VM1Nic) {
    $VM1Nic.IpConfigurations[0].LoadBalancerBackendAddressPools = $BackendPool
    Set-AzNetworkInterface -NetworkInterface $VM1Nic
}

if ($VM2Nic) {
    $VM2Nic.IpConfigurations[0].LoadBalancerBackendAddressPools = $BackendPool
    Set-AzNetworkInterface -NetworkInterface $VM2Nic
}