# Declare variables
$ResourceGroupName = "<RESOURCE_GROUP_NAME>" # Replace with your Resource Group name
$VirtualNetworkName = "<VIRTUAL_NETWORK_NAME>" # Replace with your Virtual Network name
$DNSZoneName = "<DNS_ZONE_NAME>" # Replace with your desired DNS Zone name
$SubscriptionID = "<SUBSCRIPTION_ID>" # Replace with your Azure Subscription ID

# New Private DNS Zone
Write-Host "Creating new Azure Private DNS Zone $DNSZoneName..." -ForegroundColor Green
$DNSZone = New-AzPrivateDnsZone -Name $DNSZoneName -ResourceGroupName $ResourceGroupName

# Check the Zone was created
Write-Host "Confirming Azure Private DNS Zone was created..." -ForegroundColor Green
Get-AzPrivateDnsZone -Name $DNSZone.Name -ResourceGroupName $ResourceGroupName

# Link DNS Zone to Virtual Network
Write-Host "Linking Azure Private DNS Zone was to Virtual Network $VirtualNetworkName..." -ForegroundColor Green
New-AzPrivateDnsVirtualNetworkLink -ZoneName $DNSZoneName `
-ResourceGroupName $ResourceGroupName `
-Name "DNS_Vnet_Link" `
-VirtualNetworkId "/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.Network/virtualNetworks/$VirtualNetworkName" `
-EnableRegistration:$true

# Hash table containing DNS records settings.
$DNSRecords = @{
    LinuxVM01 = @{
        Name = "LinuxVM01"
        RecordType = "A"
        Ttl = 3600
        IPv4Address = "10.1.2.4"
    }
    LinuxVM02 = @{
        Name = "LinuxVM02"
        RecordType = "A"
        Ttl = 3600
        IPv4Address = "10.1.2.5"
    }
    WindowsVM01 = @{
        Name = "WindowsVM01"
        RecordType = "A"
        Ttl = 3600
        IPv4Address = "10.1.2.6"
    }
    WindowsVM02 = @{
        Name = "WindowsVM02"
        RecordType = "A"
        Ttl = 3600
        IPv4Address = "10.1.2.7"
    }
}

# Iterate through the DNSRecords hashtable and create new DNS records
Write-Host "Adding DNS Records to the Zone $DNSZoneName..." -ForegroundColor Green
foreach ($recordKey in $DNSRecords.Keys) {
    $recordDetails = $DNSRecords[$recordKey]

    # Use New-AzPrivateDnsRecordSet to create a new DNS record set for each entry
    New-AzPrivateDnsRecordSet -ResourceGroupName $ResourceGroupName `
    -ZoneName $DNSZoneName `
    -Name $recordKey `
    -RecordType $recordDetails.RecordType `
    -Ttl $recordDetails.Ttl `
    -PrivateDnsRecords (New-AzPrivateDnsRecordConfig -IPv4Address $recordDetails.IPv4Address)
}