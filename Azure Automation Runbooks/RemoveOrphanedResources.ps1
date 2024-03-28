Param (
  [Parameter (Mandatory = $true)]
  [int] $DiskAgeInDays = 7,

  [Parameter (Mandatory = $false)]
  [switch] $EnableResourceRemoval = $false,

  [Parameter (Mandatory = $true)]
  [string] $Subscription = "MySubscriptionName",

  [Parameter (Mandatory = $true)]
  [string] $ResourceGroup = "MyResourceGroup"
)

# Configure Login
Disable-AzContextAutoSave -Scope Process
$AzureContext = (Connect-AzAccount -Identity).context
$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext

#-------------------------------------------- Start Script --------------------------------------------#

$Date = (Get-Date).AddDays(-($DiskAgeInDays))
$Disks = Get-AzDisk
$OrphanedDisks = @()

foreach ($Disk in $Disks) {
    $vmId = $Disk.ManagedBy
    if ((-not $vmId) -and ($disk.TimeCreated -le $date)) {
        $OrphanedDisks += $Disk.name
    }
}
if (-not $OrphanedDisks){
    Write-Host "No unorphaned disks found in resource group."
}
else {
    Write-Host ""
    Write-Host "Orphaned disks"
    Write-Host "---------------"
    $OrphanedDisks
    Write-Host ""

    if ($EnableResourceRemoval) {
        Write-Host "Removing virtual disk $($Disk.Name)."
        Remove-AzDisk -ResourceGroupName $ResourceGroup -DiskName $Disk.Name -Force
    }
}

$Nics = Get-AzNetworkInterface
$OrphanedNics = @()
foreach ($Nic in $Nics) {
    $vmId = $Nic.VirtualMachine.Id

    if (-not $vmId) {
        $OrphanedNICs += $Nic.Name
    }
}
if (-not $OrphanedNics){
    Write-Host "No unorphaned nics found in resource group."
}
else {
    Write-Host ""
    Write-Host "Orphaned nics"
    Write-Host "---------------"
    $OrphanedNics
    Write-Host ""

    if ($EnableResourceRemoval) {
        Write-Host "Removing virtual nic $($Nic.Name)."
        Remove-AzNetworkInterface -ResourceGroupName $ResourceGroup -Name $Nic.Name -Force
    }
}

$Pips = Get-AzPublicIpAddress
$OrphanedPips = @()
foreach ($Pip in $Pips) {
    $NicId = $Pip.IpConfiguration.Id
    if (-not $NicId) {
        $OrphanedPIPs += $Pip.Name
    }
}
if (-not $OrphanedPips){
    Write-Host "No unorphaned pips found in resource group."
}
else {
    Write-Host ""
    Write-Host "Orphaned pips"
    Write-Host "---------------"
    $OrphanedPips
    Write-Host ""

    if ($EnableResourceRemoval) {
        Write-Host "Removing public IP address $($Pip.Name)."
        Remove-AzPublicIpAddress -ResourceGroupName $ResourceGroup -Name $Pip.Name -Force
    }
}

