Param
(
  [Parameter (Mandatory= $true)]
  [String] $TagName,

  [Parameter (Mandatory= $true)]
  [String] $TagValue,

  [Parameter (Mandatory= $false)]
  [String] $Subscription = "MySubscriptionName",

  [Parameter (Mandatory= $false)]
  [String] $ResourceGroup = "MyResourceGroup"
)

# Configure Login
Disable-AzContextAutoSave -Scope Process
$AzureContext = (Connect-AzAccount -identity).context
$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext

# ----- Start Script ----- #

# Create the new Tag.
$Tag = @{Name="$TagName";Value="$TagValue"}

# Get Azure virtual machines from the resource group.
$VMs = Get-AzVM -ResourceGroupName $ResourceGroup

# Set the Tag on all virtual machines in the resource group.
Foreach ($VM in $VMs) {
	Update-AzTag -ResourceId $VM.Id -Tag $Tag -Operation 'Merge'
}
