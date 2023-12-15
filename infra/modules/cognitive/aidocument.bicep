param location string
param suffix string



resource frmRecognizer 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: 'frmRecognizer-${suffix}'
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'FormRecognizer'
  properties: {
    customSubDomainName: 'frmRecognizer-${suffix}'
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: [
        
      ]
    }
  }
}