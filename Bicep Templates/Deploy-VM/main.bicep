param name string
param location string
param vnetName string
param subnetName string
param userName string
param ouPath string
param domainJoinOptions int

@secure()
param userPassword string

@description('The FQDN of the AD domain')
param domainToJoin string

@description('Username of the account on the domain')
param domainUsername string

@description('Password of the account on the domain')
@secure()
param domainPassword string

@description('Size of the virtual machine.')
param vmSize string = 'Standard_D2s_v3'

resource vnet 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  name: vnetName
  scope: resourceGroup('rg-my-resource-group')
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' existing = {
  parent: vnet
  name: subnetName
}

resource nic 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: '${name}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet.id
          }
        }
      }
    ]
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: name
      adminUsername: userName
      adminPassword: userPassword
    }
    storageProfile: {
      imageReference: {
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        publisher: 'MicrosoftWindowsServer'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

resource virtualMachineExtension 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = {
  parent: virtualMachine
  name: 'joindomain'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      name: domainToJoin
      ouPath: ouPath
      user: '${domainToJoin}\\${domainUsername}'
      restart: true
      options: domainJoinOptions
    }
    protectedSettings: {
      Password: domainPassword
    }
  }
}
