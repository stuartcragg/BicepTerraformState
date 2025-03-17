targetScope = 'subscription'

/* ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Create the parameters
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

param tags object = {
  environment: environment
  project: 'terraform-prereqs'
  owner: 'DevOps Team'
}

param oidcIssuerUrl string
param oidcSubject string

var rgNames = [
  '${environment}-rg-state'
  '${environment}-rg-identity'
  '${environment}-rg-backups'
]
// var roleDefinitions = {
//   Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
//   Reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
//   'Network Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7')
// }

/* ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Create the resource groups
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

module rgModule './modules/resource-group.bicep' = {
  name: 'rgDeployment'
  params: {
    location: location
    rgNames: rgNames
    tags: tags
  }
}

/* ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Create the storage and containers
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

var containerNames = [
  'state'
  'csv-${environment}'
  'json-${environment}'
]

module storageModule './modules/storage.bicep' = {
  name: 'storageDeployment'
  scope: resourceGroup('${environment}-rg-state')
  params: {
    location: location
    storageAccountName: 'stterraformdev123'
    storageAccountSku: 'Standard_LRS'
    containerNames: containerNames
  }
}


/* ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Managed Identity and Federated Credentials
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

module identityModule './modules/managed-identity.bicep' = {
  name: 'identityDeployment'
  scope: resourceGroup('${environment}-rg-identity') // Pass RG output
  params: {
    location: location
    environment: environment
    oidcIssuerUrl: oidcIssuerUrl
    oidcSubject: oidcSubject
    
  }
}

/* ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Create the RBAC for the Managed Identity
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------*/


// Deploy Role Assignments for each resource group
module rbacModules './modules/rbac.bicep' = [for (i, assignment) in roleAssignments: {
  name: 'rbacDeployment-${i}-${assignment.resourceGroupName}'
  scope: resourceGroup('${environment}-rg-state')
  params: {
    identityRGName: assignment.resourceGroupName
    managedIdentityPrincipalId: federatedIdentityModule.outputs.managedIdentityPrincipalId
    roleDefinitions: roleDefinitions
    roles: assignment.roles
  }
  dependsOn: [
    federatedIdentityModule
  ]
}]


// Outputs for use by other modules
output stateRGName string = rgModule.outputs.stateRGName
output identityRGName string = rgModule.outputs.identityRGName
