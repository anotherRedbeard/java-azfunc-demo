targetScope = 'resourceGroup'

@description('The name of the parent site resource. Required if the template is used in a standalone deployment.')
param appName string

@description('The app settings key-value pairs except for AzureWebJobsStorage, AzureWebJobsDashboard, APPINSIGHTS_INSTRUMENTATIONKEY and APPLICATIONINSIGHTS_CONNECTION_STRING.')
param appSettingsKeyValuePairs object?

resource app 'Microsoft.Web/sites@2022-09-01' existing = {
  name: appName
}

resource appSettings 'Microsoft.Web/sites/config@2022-09-01' = {
  name: 'appsettings'
  parent: app
  properties: appSettingsKeyValuePairs
}
