targetScope = 'resourceGroup'

@description('The name of the parent site resource. Required if the template is used in a standalone deployment.')
param appName string

module appSettingsModule 'modules/currentAppSettings.bicep' = {
  name: 'appSettingsDeploymentIsolated'
  params: {
    appName: appName
    appSettingsKeyValuePairs: {
      // Add any additional settings you want to append here
      APPLICATIONINSIGHTS_ENABLE_AGENT: 'true'
      WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: '@Microsoft.KeyVault(SecretUri=https://red-scus-javafuncdemo-kv.vault.azure.net/secrets/javafuncdemo-storage-connstr1)'
      WEBSITE_CONTENTSHARE: '${appName}-share'
    }
  }
}
