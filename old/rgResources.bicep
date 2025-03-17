targetScope = 'resourceGroup'

/* ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Creating the parameters for the Terraform prerequisite resources within a resource group.
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

@allowed([
  'eastus'
  'westus'
  'northeurope'
  'westeurope'
  // Add more regions as needed
])
param location string

@allowed([
  'prd'
  'acc'
  'dev'
  'tst'
  // Add more environments if needed
])
param environment string

param storageAccountName string
param storageAccountSku string
param blobContainerNames array = ['tfstate', 'vaults-tfstate', 'backups-tfstate', 'csv-${environment}', 'json-${environment}'] // Optional default, can be overridden
param oidcIssuerUrl string
param oidcSubject string

/* ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Deploy the Storage Account and containers for TF State.
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

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
}]

/* ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Deploy the User-Assigned Managed Identity.
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'mi-terraform-${environment}'
  location: location
}

// Outputs
output managedIdentityId string = managedIdentity.id
