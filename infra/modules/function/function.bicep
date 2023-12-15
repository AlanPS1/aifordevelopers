param location string
param suffix string
param storageName string
param appInsightname string
param formRecognizerName string

resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageName  
}

resource form 'Microsoft.CognitiveServices/accounts@2021-04-30' existing = {
  name: formRecognizerName  
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightname
}

resource serverFarm 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: 'asp-${suffix}'
  location: location
  sku: {
    tier: 'Dynamic'
    name: 'Y1'
  }
}

resource function 'Microsoft.Web/sites@2020-06-01' = {
  name: 'func-${suffix}'
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: serverFarm.id    
    siteConfig: {
      netFrameworkVersion: 'v8.0'
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storage.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storage.listKeys().keys[0].value}'
        }
        {
          name: 'ModelContainer'
          value: 'model'
        }
        {
          name: 'FormRecognizerEndpoint'
          value: form.properties.endpoint
        }                  
        {
          name: 'FormRecognizerKey'
          value: form.listKeys().key1
        }        
        {
          name: 'DevStorageCnxString'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storage.listKeys().keys[0].value}'
        }                
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: 'processorapp092'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~12'
        }
      ]
    }
  }
}

output functionName string = function.name
