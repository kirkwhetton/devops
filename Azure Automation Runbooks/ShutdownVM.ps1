Param (
  [Parameter (Mandatory= $false)]
  [array] $VMNames,

  [Parameter (Mandatory= $true)]
  [string] $Subscription = "MySubscriptionName",

  [Parameter (Mandatory= $true)]
  [string] $ResourceGroup = "MyResourceGroup"
)

# Configure Login
Disable-AzContextAutoSave -Scope Process
$AzureContext = (Connect-AzAccount -Identity).context
$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext

#-------------------------------------------- Start Script --------------------------------------------#

# Shutdown virtual machines that are running with the shutdown tag enabled or with an array from user input.

if($VMNames){
    foreach ($VM in $VMNames){
        Stop-AzVM -ResourceGroupName $ResourceGroup -Name $VM -Force -NoWait
    }
}
else { 
    $VMs = Get-AzVM -ResourceGroupName $ResourceGroup | Where-Object {$_.Tags['Shutdown'] -eq 'true'}
    foreach ($VM in $VMs) {
        $Status = Get-AzVM -ResourceGroupName $ResourceGroup -Name $VM.Name -Status
        if ($Status.Statuses[1].Code -eq "Powerstate/running"){
            Stop-AzVM -ResourceGroupName $ResourceGroup -Name $VM.Name -Force -NoWait
        }
    }
}

