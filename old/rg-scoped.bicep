param location string
param environment string
param storageAccountName string
param storageAccountSku string
param blobContainerNames array
param oidcIssuerUrl string
param oidcSubject string
param resourceGroups array
param roleDefinitions object

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  name: 'default'
  parent: storageAccount
}

resource blobContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = [for containerName in blobContainerNames: {
  name: containerName
  parent: blobService
  properties: {}
}]

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'mi-terraform-${environment}'
  location: location
}

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (i, rg) in resourceGroups: for role in rg.roles: {
  name: guid(rg.name, managedIdentity.name, role)
  scope: resourceGroup()
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: roleDefinitions[role]
    principalType: 'ServicePrincipal'
  }
  dependsOn: [
    managedIdentity
  ]
}]

output managedIdentityId string = managedIdentity.id
