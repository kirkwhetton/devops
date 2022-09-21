@description('The default username that will be created with the Azure virtual machine.')
param userName string

@secure()
@description('The default password that will be created with the Azure virtual machine.')
param userPassword string

@description('The username of a domain admin to add the computer to a domain.')
param domainUserName string

@secure()
@description('The password of the domain admin account adding the computer to a domain.')
param domainPassword string

// Load deployment variables from json file.
var mainVars = loadJsonContent('vars/mainVars.json')

// Deploy virtual machines with parameters from json file.
module vm 'modules/vm.bicep' = [for i in range(0, mainVars.vmCount): {
  name: '${mainVars.vmPrefix}${i}'
  params:{
    name: '${mainVars.vmPrefix}${i}'
    location: mainVars.location
    vnetName: mainVars.vnetName
    subnetName: mainVars.subnetName
    userName: userName
    userPassword: userPassword
    domainToJoin: mainVars.domainToJoin
    domainJoinOptions: mainVars.domainJoinOptions
    ouPath: mainVars.ouPath
    domainUsername: domainUserName   
    domainPassword: domainPassword
  }
}]
