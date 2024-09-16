targetScope = 'resourceGroup'

@description('The name of the parent site resource. Required if the template is used in a standalone deployment.')
param appName string

@description('The app settings key-value pairs except for AzureWebJobsStorage, AzureWebJobsDashboard, APPINSIGHTS_INSTRUMENTATIONKEY and APPLICATIONINSIGHTS_CONNECTION_STRING.')
param appSettingsKeyValuePairs object?

// Retrieve existing app settings
var existingAppSettings = list('${resourceId('Microsoft.Web/sites', appName)}/config/appsettings', '2022-09-01').properties

// Union the existing app settings with the new key-value pairs
var expandedAppSettings = union(existingAppSettings, appSettingsKeyValuePairs ?? {})

module appSettingsModule 'appSettings.bicep' = {
  name: 'appSettingsUnionDeployment'
  params: {
    appName: appName
    appSettingsKeyValuePairs: expandedAppSettings
  }
}
