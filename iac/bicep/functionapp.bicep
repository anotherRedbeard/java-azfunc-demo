resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'bugteststorageaccount'
  location: 'southcentralus'
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: 'bugtestappserviceplan'
  location: 'southcentralus'
  sku: {
    name: 'EP1'
    tier: 'Elastic'
  }
  properties: {
    reserved: false // Reserved should be false for Windows
    maximumElasticWorkerCount: 2
    perSiteScaling: false
    zoneRedundant: false
  }
  dependsOn: [
    storageAccount
  ]
}

resource functionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: 'bugtestfunctionapp'
  location: 'southcentralus'
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      alwaysOn: false
      windowsFxVersion: 'java|17'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${listKeys(storageAccount.id, '2021-02-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
      ]
    }
    httpsOnly: true
  }
  identity: {
    type: 'SystemAssigned'
  }
  dependsOn: [
    appServicePlan
    storageAccount
  ]
}

output functionAppId string = functionApp.id
