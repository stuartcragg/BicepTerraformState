@allowed([
  'eastus'
  'westus'
  'northeurope'
  'westeurope'
])
param location string

@allowed([
  'prd'
  'acc'
  'dev'
  'tst'
])
param environment string
param identityRGName string
param stateRGName string
param backupsRGName string

targetScope = 'resourceGroup'


// Define the storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'sstbackups${environment}001'
  location: location
  resourceGroup: stateRGName
  kind: 'StorageV2'  // Specifies a StorageV2 account
  sku: {
    name: 'Standard_GRS'
  }
  properties: {
    accessTier: 'Hot'  // Ensures the account is on the Hot tier
    enableHttpsTrafficOnly: true  // Enforces HTTPS for security
    minimumTlsVersion: 'TLS1_2'  // Enforces TLS 1.2+
    supportsHttpsTrafficOnly: true  // Additional HTTPS enforcement
    allowBlobPublicAccess: false  // Disable public access for security
    infrastructureEncryption: 'Enabled'  // Enables infrastructure encryption
  }
}
