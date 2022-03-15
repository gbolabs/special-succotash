@allowed([
  'switzerlandnorth'
])
param location string = 'switzerlandnorth'

// Need to deploy a B2C tenant, an API Management and two azure functions.

/// Storage accout with blob containers for Static Web distribution
resource sto 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  kind: 'StorageV2'
  location: location
  name: 'stob2capmazfuncdev01'
  sku: {
    name: 'Standard_LRS'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    accessTier: 'Hot'
    allowSharedKeyAccess: true
  }
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices@2021-08-01' = {
  name: 'default'
  parent: sto
  properties: {
    containerDeleteRetentionPolicy: {
      enabled: false
    }
    isVersioningEnabled: false
    automaticSnapshotPolicyEnabled: false
  }
}

resource webBlob 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-08-01' = {
  name: '$web'
  parent: blobContainer
  properties: {
    publicAccess: 'None'
  }
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'DeploymentScript'
  location: location
}
resource contributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  // This is the Storage Account Contributor role, which is the minimum role permission we can give. See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#:~:text=17d1049b-9a84-46fb-8f53-869881c3d3ab
  name: '17d1049b-9a84-46fb-8f53-869881c3d3ab'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: sto
  name: guid(resourceGroup().id, managedIdentity.id, contributorRoleDefinition.id)
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deploymentScript'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  dependsOn: [
    // we need to ensure we wait for the role assignment to be deployed before trying to access the storage account
    roleAssignment
  ]
  properties: {
    azPowerShellVersion: '3.0'
    scriptContent: loadTextContent('./scripts/enable-staticwebsite.ps1')
    retentionInterval: 'PT4H'
    environmentVariables: [
      {
        name: 'ResourceGroupName'
        value: resourceGroup().name
      }
      {
        name: 'StorageAccountName'
        value: sto.name
      }
      {
        name: 'IndexDocumentPath'
        value: 'index.html'
      }
    ]
  }
}

output staticWebsiteUrl string = sto.properties.primaryEndpoints.web


/// end storage

/// CDN
resource cdn 'Microsoft.Cdn/profiles@2021-06-01' = {
  location: 'Global'
  name: 'cdn-b2capimazfunc-dev-01'
  sku: {
    name: 'Standard_Microsoft'
  }
  properties: {
    identity: {
      type: 'SystemAssigned'
    }
  }
}

resource cdnEndpoint 'Microsoft.Cdn/profiles/endpoints@2021-06-01' = {
  location: 'Global'
  name: 'b2capimazfunc-dev'
  parent: cdn
  properties: {
    origins: [
      {
        name: 'stob2capmazfuncdev01'
        properties: {
          hostName: 'stob2capmazfuncdev01.z1.web.${environment().suffixes.storage}'
          originHostHeader: 'stob2capmazfuncdev01.z1.web.${environment().suffixes.storage}'
          enabled: true
        }
      }
    ]
    originHostHeader: 'stob2capmazfuncdev01.z1.web.${environment().suffixes.storage}'
    optimizationType: 'GeneralWebDelivery'
    queryStringCachingBehavior: 'IgnoreQueryString'
    isHttpAllowed: true
    isHttpsAllowed: true
    deliveryPolicy: {
      rules: [
        {
          name: 'http2https'
          actions: [
            {
              name: 'UrlRedirect'
              parameters: {
                redirectType: 'Moved'
                typeName: 'DeliveryRuleUrlRedirectActionParameters'
                destinationProtocol: 'Https'
              }
            }
          ]
          conditions: [
            {
              name: 'RequestScheme'
              parameters: {
                operator: 'Equal'
                typeName: 'DeliveryRuleRequestSchemeConditionParameters'
                matchValues: [
                  'HTTP'
                ]
              }
            }
          ]
          order: 1
        }
      ]
    }
  }
}

/// end of cdn


/// storage permissions
var storageBlodContributor = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
resource bloblContributorRoleDefiintion 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing={
  scope: subscription()
  name: storageBlodContributor
}

resource gbo2storage 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: '${guid('gbo2storage', sto.name, storageBlodContributor)}'
  properties: {
    principalId: '1c66f21e-0648-43c1-8104-2be2d1c349dc' //gbo@pr114.isago.ch
    roleDefinitionId: bloblContributorRoleDefiintion.id
    principalType: 'User'
  }
}

output cdnEndpoint string = cdnEndpoint.properties.hostName
output webBlobId string = webBlob.id
