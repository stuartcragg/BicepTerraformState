targetScope = 'subscription'

/* ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Parameters
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

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

param createResourceGroups bool
param tags object = {
  environment: environment
  project: 'terraform-prereqs'
}

param storageAccountName string
param storageAccountSku string
param blobContainerNames array = [
  'tfstate'
  'vaults-tfstate'
  'backups-tfstate'
  'csv-${environment}'
  'json-${environment}'
]
param oidcIssuerUrl string
param oidcSubject string

/* ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Variables
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

var resourceGroups = [
  {
    name: 'rg-tfstate-${environment}'
    roles: ['Contributor']
  }
  {
    name: 'rg-network-${environment}'
    roles: ['Reader', 'Network Contributor']
  }
  {
    name: 'rg-compute-${environment}'
    roles: ['Contributor']
  }
]

var roleDefinitions = {
  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  Reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  'Network Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7')
}

/* ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Deploy Resource Groups
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

resource resourceGroupsArray 'Microsoft.Resources/resourceGroups@2021-04-01' = [for rg in resourceGroups: if (createResourceGroups) {
  name: rg.name
  location: location
  tags: tags
}]

resource resourceGroupsExisting 'Microsoft.Resources/resourceGroups@2021-04-01' existing = [for i in range(0, length(resourceGroups)): {
  name: resourceGroups[i].name
}]

/* ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Module for Resource Group-Scoped Resources and RBAC
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

module rgScopedDeployment './rg-scoped.bicep' = {
  name: 'rgScopedDeployment-${environment}'
  scope: resourceGroupsExisting[0] // Target the first resource group (rg-tfstate-${environment})
  params: {
    location: location
    environment: environment
    storageAccountName: storageAccountName
    storageAccountSku: storageAccountSku
    blobContainerNames: blobContainerNames
    oidcIssuerUrl: oidcIssuerUrl
    oidcSubject: oidcSubject
    resourceGroups: resourceGroups
    roleDefinitions: roleDefinitions
  }
  dependsOn: createResourceGroups ? resourceGroupsArray : []
}

/* ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Outputs
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

output resourceGroupNames array = [for rg in resourceGroups: rg.name]
output managedIdentityId string = rgScopedDeployment.outputs.managedIdentityId
