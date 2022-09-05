@description('Username for the Virtual Machine.')
param adminUsername string = 'AzureAdmin'

@description('Password for the Virtual Machine.')
@secure()
param adminPassword string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Number of VNETs and VMs to deploy')
@minValue(1)
@maxValue(254)
param copies int = 5

@allowed([
  'Standard_A1_v2'
  'Standard_A2_v2'
  'Standard_A4_v2'
])
param vmsize string = 'Standard_A4_v2'

@description('Prefix Name of VNETs')
param virtualNetworkName string = 'anm-vnet-'

@description('Name of the existing VNET resource group')
param existingVirtualNetworkResourceGroup string = resourceGroup().name

@description('remote desktop source address')
param sourceIPaddressRDP string = '81.150.78.91'

@description('Name of the subnet to create in the virtual network')
param subnetName string = 'vmSubnet'

@description('Prefix name of the nic of the vm')
param nicName string = 'VMNic-'

@description('Prefix name of the nic of the vm')
param vmName string = 'VM-'

@description('Prefix name of the nic of the vm')
param bastionHostName string = 'AVNMBASTION-'

@description('Bool parameter to deploy Bastion')
param deployBastion bool = true

@description('Bool parameter to deploy Network Manager with access to the current subscription scope only')
param deployNetworkManager bool = true

var currentSub = subscription().id
var avnmName = 'AVNMDemo'


resource virtualNetworkName_resource 'Microsoft.Network/virtualNetworks@2019-09-01' = [for i in range(0, copies): {
  name: '${virtualNetworkName}${i}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.${i}.0/24'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.${i}.0/26'
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: anm_nsg.id
          }
        }
      }
    ]
  }
}]

output deployedvNets array = [for i in range(0, copies): {
  virtualNetworkName: virtualNetworkName_resource[i].name
  addressPrefixes: virtualNetworkName_resource[i].properties.addressSpace
  subnetName: virtualNetworkName_resource[i].properties.subnets
}]

resource anm_nsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: 'anm-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'rdp'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: sourceIPaddressRDP
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

resource nicName_resource 'Microsoft.Network/networkInterfaces@2019-09-01' = [for i in range(0, copies): {
  name: '${nicName}${i}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId(existingVirtualNetworkResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', '${virtualNetworkName}${i}', subnetName)
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
  dependsOn: [
    virtualNetworkName_resource
  ]
}]

resource vmName_resource 'Microsoft.Compute/virtualMachines@2018-10-01' = [for i in range(0, copies): {
  name: '${vmName}${i}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmsize
    }
    osProfile: {
      computerName: '${vmName}${i}'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter'
        version: 'latest'
      }
      osDisk: {
        name: 'osDisk-${vmName}${i}'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${nicName}${i}')
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
  dependsOn: [
    nicName_resource
  ]
}]

resource vmName_Microsoft_Azure_NetworkWatcher 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = [for i in range(0, copies): {
  name: '${vmName}${i}/Microsoft.Azure.NetworkWatcher'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.NetworkWatcher'
    type: 'NetworkWatcherAgentWindows'
    typeHandlerVersion: '1.4'
    autoUpgradeMinorVersion: true
  }
  dependsOn: [
    vmName_resource
  ]
}]

resource vmName_IISExtension 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = [for i in range(0, copies): {
  name: '${vmName}${i}/IISExtension'
  location: location
  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.9'
    settings: {
      commandToExecute: 'powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path "C:\\inetpub\\wwwroot\\Default.htm" -Value $($env:computername)"'
    }
    protectedSettings: {
    }
  }
  dependsOn: [
    vmName_resource
  ]
}]

resource virtualNetworkManager 'Microsoft.Network/networkManagers@2022-04-01-preview' = if (deployNetworkManager) {
  name: avnmName 
  location: location
  properties: {
    networkManagerScopeAccesses:[
      'Connectivity'
    ]
    networkManagerScopes:{
      subscriptions:[
        currentSub
      ]
    }
  }
}

//Create Bastion Host
//module bastion 'modules/bastion.bicep'= if (deployBastion) {
//  name: 'bastion'
//  params: {
 //   bastionHostName: bastionHostName
 //   bastionSubnetIpPrefix: bastionSubnetIpPrefix
//    vnetName: '${virtualNetworkName}${i}'
//    location: location
//  }
// }
