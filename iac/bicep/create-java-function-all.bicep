targetScope = 'subscription'

@description('Provide the id of the subscription.')
param subscriptionId string = 'subscriptionId'

@description('Provide the name of the resource group.')
param rgName string = 'rgName'

@description('Provide the location of the apim instance.')
param location string = 'location'

@description('Provide the name of the app service plan.')
param aspName string = 'App Service Plan name'

@allowed([
  'EP1'
  'EP2'
  'EP3'
  'Y1'
])
@description('The name of the app service plan sku.')
param sku string = 'EP1'

@description('Name of the log analytics workspace.')
param lawName string = '<lawName>'

@description('Name of the app insights resource.')
param appInsightsName string = '<appInsightsName>'

@description('Name of the storage account to map to function app.')
param storageAccountName string = '<storageAccountName>'

@description('Name of the function app.')
param functionAppName string = '<functionApp>'

@description('Name of the keyvault to store secrets.')
param keyVaultName string = '<keyVaultName>'

@description('Name of the dashboard to show all the cool metrics')
param demoDashboard string = 'myDashboard'

//create resource group
module resourceGroupResource 'br/public:avm/res/resources/resource-group:0.3.0' = {
  name: 'createResourceGroup'
  scope: subscription(subscriptionId)
  params: {
    name: rgName
    location: location
  }
}

//app service plan
module serverfarm 'br/public:avm/res/web/serverfarm:0.2.2' = {
  scope: resourceGroup(rgName)
  dependsOn: [ resourceGroupResource ]
  name: 'serverfarmDeployment'
  params: {
    // Required parameters
    name: aspName
    skuCapacity: 1
    skuName: sku
    // Non-required parameters
    // Commenting these out as I don't think we need them but I'm not 100% sure
    //kind: 'Elastic'
    //maximumElasticWorkerCount: 2
    reserved: false
    location: location 
    perSiteScaling: false
    zoneRedundant: false
  }
}

//log analytics workspace resource
module workspace 'br/public:avm/res/operational-insights/workspace:0.5.0' = {
  name: 'workspaceDeployment'
  scope: resourceGroup(rgName)
  dependsOn: [ resourceGroupResource ]
  params: {
    // Required parameters
    name: lawName
    // Non-required parameters
    location: location
  }
}

//app insights resource
module component 'br/public:avm/res/insights/component:0.4.0' = {
  name: 'componentDeployment'
  scope: resourceGroup(rgName)
  dependsOn: [ resourceGroupResource, workspace ]
  params: {
    // Required parameters
    name: appInsightsName
    workspaceResourceId: workspace.outputs.resourceId
    // Non-required parameters
    location: location
  }
}

//key vault resource
module vault 'br/public:avm/res/key-vault/vault:0.7.1' = {
  scope: resourceGroup(rgName)
  name: 'vaultDeployment'
  dependsOn: [ resourceGroupResource ]
  params: {
    // Required parameters
    name: keyVaultName
    // Non-required parameters
    enablePurgeProtection: false
    enableRbacAuthorization: true
    location: location
  }
}

//create storage account
module storageAccount 'br/public:avm/res/storage/storage-account:0.13.2' = {
  name: 'storageAccountDeployment'
  scope: resourceGroup(rgName)
  dependsOn: [ resourceGroupResource, vault ]
  params: {
    // Required parameters
    name: storageAccountName
    // Non-required parameters
    allowBlobPublicAccess: false
    blobServices: {
      containers: [
        {
          name: 'egtestcontainer'
          publicAccess: 'None'
        }
      ]
    }
    fileServices: {
      shares: [ 
        {
          name: '${functionAppName}-share'
          accessTier: 'TransactionOptimized'
          sharequota: 102400
          enabledProtocols: 'SMB'
        }
      ]
    }
    location: location
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
      ipRules: [ ]
      virtualNetworkRules: [ ]
    }
    queueServices: {
      queues: [
        {
          name: 'egtestqueue'
        }
      ]
    }
    secretsExportConfiguration: {
      accessKey1: 'javafuncdemo-storage-key1'
      accessKey2: 'javafuncdemo-storage-key2'
      connectionString1: 'javafuncdemo-storage-connstr1'
      connectionString2: 'javafuncdemo-storage-connstr2'
      keyVaultResourceId: vault.outputs.resourceId
    }
    skuName: 'Standard_LRS'
  }
}

// create event grid topic
module topic 'br/public:avm/res/event-grid/system-topic:0.4.0' = {
  name: 'topicDeployment'
  scope: resourceGroup(rgName)
  params: {
    // Required parameters
    name: 'eg-test-topic'
    source: storageAccount.outputs.resourceId
    topicType: 'Microsoft.Storage.StorageAccounts'
    // Non-required parameters
    eventSubscriptions: [
      {
        destination: {
          endpointType: 'StorageQueue'
          properties: {
            queueMessageTimeToLiveInSeconds: 86400
            queueName: 'egtestqueue'
            resourceId: storageAccount.outputs.resourceId
          }
        }
        eventDeliverySchema: 'EventGridSchema'
        filter: {
          includedEventTypes: [
            'Microsoft.Storage.BlobCreated'
            'Microsoft.Storage.BlobDeleted'
          ]
          enableAdvancedFilteringOnArrays: true
        }
        name: 'eg-test-blob-container-create-event'
        retryPolicy: {
          eventTimeToLive: '120'
          maxDeliveryAttempts: 10
        }
      }
    ]
    location: location
    managedIdentities: {
      systemAssigned: true
    }
  }
  dependsOn: [ 
    storageAccount 
  ]
}

//create function app
module site 'br/public:avm/res/web/site:0.8.0' = {
  name: 'siteDeployment'
  scope: resourceGroup(rgName)
  dependsOn: [ resourceGroupResource, serverfarm, component, storageAccount, vault ]
  params: {
    // Required parameters
    kind: 'functionapp'
    name: functionAppName
    serverFarmResourceId: serverfarm.outputs.resourceId
    // Non-required parameters
    appInsightResourceId: component.outputs.resourceId
    appSettingsKeyValuePairs: {
      APPINSIGHTS_INSTRUMENTATIONKEY: component.outputs.instrumentationKey
      FUNCTIONS_EXTENSION_VERSION: '~4'
      FUNCTIONS_WORKER_RUNTIME: 'java'
    }
    managedIdentities: {
      systemAssigned: true
    }
    location: location
    siteConfig: {
      alwaysOn: false
      functionappscalelimit: 20
      prewarmedInstanceCount: 0
      windowsFxVersion: 'java|17'
      javaVersion: '17'
    }
    storageAccountResourceId: storageAccount.outputs.resourceId
    storageAccountUseIdentityAuthentication: false
  }
}

// create resource role assignment for the managed identity
module resourceRoleAssignment 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.1' = {
  scope: resourceGroup(rgName)
  dependsOn: [ vault, site ]
  name: 'resourceRoleAssignmentDeployment'
  params: {
    // Required parameters
    principalId: site.outputs.systemAssignedMIPrincipalId
    resourceId: vault.outputs.resourceId
    roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6'
    // Non-required parameters
    description: 'Assign Key Vault Secrets User role to the managed identity on the function app.'
    principalType: 'ServicePrincipal'
    roleName: 'Key Vault Secrets User'
  }
}

module appSettingsModule 'modules/currentAppSettings.bicep' = {
  name: 'appSettingsDeployment'
  scope: resourceGroup(rgName)
  dependsOn: [ site, vault, resourceRoleAssignment]
  params: {
    appName: functionAppName
    appSettingsKeyValuePairs: {
      // Add any additional settings you want to append here
      APPLICATIONINSIGHTS_ENABLE_AGENT: 'true'
      WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: '@Microsoft.KeyVault(SecretUri=${storageAccount.outputs.exportedSecrets['javafuncdemo-storage-connstr1'].secretUri})'
      WEBSITE_CONTENTSHARE: '${functionAppName}-share'
    }
  }
}

module dashboard 'br/public:avm/res/portal/dashboard:0.3.0' = {
  name: 'dashboardDeployment'
  scope: resourceGroup(rgName)
//  dependsOn: [ appSettingsModule ]
  params: {
    // Required parameters
    name: demoDashboard 

    // Non-required parameters
    lenses: [
      {
        order: 0
        parts: [
          {
            position: {
              x: 0
              y: 0
              rowSpan: 3
              colSpan: 6
            }
            metadata: {
                inputs: [
                    {
                        name: 'ComponentId'
                        value: '/subscriptions/${subscriptionId}/resourceGroups/${rgName}/providers/Microsoft.Insights/components/${appInsightsName}'
                    }
                ]
                type: 'Extension/AppInsightsExtension/PartType/AppMapGalPt'
                settings: {}
            }
          }
          {
            position: {
              x: 6 
              y: 0
              colSpan: 6
              rowSpan: 3
            }
            metadata: {
              inputs: [
                {
                  isOptional: true
                  // Define the scope to point to the Log Analytics workspace
                  name: 'Scope'
                  value: {
                    resourceIds: [
                      '/subscriptions/${subscriptionId}/resourceGroups/${rgName}/providers/Microsoft.Insights/components/${appInsightsName}'
                    ]
                  }
                }
                {
                  isOptional: true
                  name: 'Version'
                  value: '2.0'
                }
                {
                  isOptional: true
                  name: 'TimeRange'
                  value: 'PT4H'
                }
                {
                  isOptional: true
                  name: 'ControlType'
                  value: 'AnalyticsGrid'
                }
                {
                  // The query to run within the Log Analytics workspace
                  name: 'Query'
                  value: 'traces\n| where message == "Message processed successfully"\n| summarize count() by message, operation_Name, bin(timestamp, 1m)\n| order by timestamp desc'  // Your KQL query
                }
              ]
              partHeader: {
                title: 'Processed Messages'
                subtitle: appInsightsName
              }
              settings: {}
              type: 'Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart'
            }
          }
          {
            position: {
              colSpan: 6
              rowSpan: 3
              x: 0 
              y: 3 
            }
            metadata: {
              inputs: [
                {
                  isOptional: true
                  // Define the scope to point to the Log Analytics workspace
                  name: 'Scope'
                  value: {
                    resourceIds: [
                      '/subscriptions/${subscriptionId}/resourceGroups/${rgName}/providers/Microsoft.Insights/components/${appInsightsName}'
                    ]
                  }
                }
                {
                  isOptional: true
                  name: 'Version'
                  value: '2.0'
                }
                {
                  isOptional: true
                  name: 'TimeRange'
                  value: 'PT4H'
                }
                {
                  isOptional: true
                  name: 'ControlType'
                  value: 'AnalyticsGrid'
                }
                {
                  isOptional: true
                  name: 'Query'
                  value: 'requests\n| where cloud_RoleName == "${functionAppName}"\n| summarize TotalSuccess=countif(success == true), TotalFailures=countif(success == false) by bin(timestamp, 1h)\n| order by timestamp desc'
                }
              ]
              partHeader: {
                title: 'Function Success vs Failure'
                subtitle: functionAppName
              }
              settings: {}
              type: 'Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart'
            }
          }
          {
            position: {
              colSpan: 6
              rowSpan: 3
              x: 6
              y: 3
            }
            metadata: {
              inputs: [
                {
                  isOptional: true
                  // Define the scope to point to the Log Analytics workspace
                  name: 'Scope'
                  value: {
                    resourceIds: [
                      '/subscriptions/${subscriptionId}/resourceGroups/${rgName}/providers/Microsoft.Insights/components/${appInsightsName}'
                    ]
                  }
                }
                {
                  isOptional: true
                  name: 'Version'
                  value: '2.0'
                }
                {
                  isOptional: true
                  name: 'TimeRange'
                  value: 'PT4H'
                }
                {
                  isOptional: true
                  name: 'ControlType'
                  value: 'AnalyticsGrid'
                }
                {
                  isOptional: true
                  name: 'Query'
                  value: 'requests\n| where cloud_RoleName == "${functionAppName}"\n| summarize AvgDuration=avg(duration) by bin(timestamp, 1h)\n| order by timestamp desc'
                }
              ]
              partHeader: {
                title: 'Average Execution Time'
                subtitle: functionAppName
              }
              settings: {}
              type: 'Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart'
            }
          }
          {
            position: {
              colSpan: 12
              rowSpan: 5
              x: 0
              y: 6
            }
            metadata: {
              inputs: [
                {
                  isOptional: true
                  // Define the scope to point to the Log Analytics workspace
                  name: 'Scope'
                  value: {
                    resourceIds: [
                      '/subscriptions/${subscriptionId}/resourceGroups/${rgName}/providers/Microsoft.Insights/components/${appInsightsName}'
                    ]
                  }
                }
                {
                  isOptional: true
                  name: 'Version'
                  value: '2.0'
                }
                {
                  isOptional: true
                  name: 'TimeRange'
                  value: 'PT4H'
                }
                {
                  isOptional: true
                  name: 'ControlType'
                  value: 'AnalyticsGrid'
                }
                {
                  isOptional: true
                  name: 'Query'
                  value: 'traces\n| where cloud_RoleName == "${functionAppName}"\n| summarize count() by message, bin(timestamp, 1h)\n| order by timestamp desc'
                }
              ]
              partHeader: {
                title: 'Trace Logs Summary'
                subtitle: functionAppName
              }
              settings: {
                content: {
                  GridColumnsWidth: {
                    message: '719px'
                  }
                }
              }
              type: 'Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart'
            }
          }
        ]
      }
    ]
    
    location: location
    
    metadata: {
      model: {
        filterLocale: {
          value: 'en-us'
        }
        filters: {
          value: {
            MsPortalFx_TimeRange: {
              displayCache: {
                name: 'UTC Time'
                value: 'Past 4 hours'
              }
              filteredPartIds: []
              model: {
                format: 'utc'
                granularity: 'auto'
                relative: '24h'
              }
            }
          }
        }
        timeRange: {
          type: 'MsPortalFx.Composition.Configuration.ValueTypes.TimeRange'
          value: {
            relative: {
              duration: 4
              timeUnit: 1
            }
          }
        }
      }
    }
    
  }
}
