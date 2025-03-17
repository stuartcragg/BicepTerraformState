param location string
param storageAccountName string
param storageAccountSku string
param containerNames array

// Create the Storage Account

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageAccountSku
  }
  properties: {
    accessTier: 'Hot'
    enableHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    infrastructureEncryption: 'Enabled'
  }
}

// Create the blob containers

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  name: 'default'
  parent: storageAccount
}

resource blobContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = [for containerName in containerNames: {
  name: containerName
  parent: blobService
  properties: {}
}]

output storageAccountId string = storageAccount.id  // Output storage account ID
