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
          hostName: 'stob2capmazfuncdev01.z1.web.core.windows.net'
          originHostHeader: 'stob2capmazfuncdev01.z1.web.core.windows.net'
          enabled: true
        }
      }
    ]
    originHostHeader: 'stob2capmazfuncdev01.z1.web.core.windows.net'
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
resource gbo2storage 'Microsoft.Authorization/roleAssignments@2020-04-01-preview'={
  name: guid('gbo2storage $storageBlodContributor')
  properties:{
    principalId: '1c66f21e-0648-43c1-8104-2be2d1c349dc' //gbo@pr114.isago.ch
    roleDefinitionId: storageBlodContributor
    principalType: 'User'
  }
}

output cdnEndpoint string = cdnEndpoint.properties.hostName
output webBlobId string = webBlob.id
