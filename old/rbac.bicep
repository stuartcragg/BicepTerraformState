targetScope = 'subscription'

/* ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Creating the parameters for RBAC assignments.
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

@allowed([
  'prd'
  'acc'
  'dev'
  'tst'
  // Add more environments if needed
])
param environment string

param resourceGroupNames array
param managedIdentityId string

/* ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Role Assignments for Managed Identity.
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

var roleDefinitions = {
  Contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  Reader: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
  'Network Contributor': '4d97b98b-1d4f-4787-a291-c67834d212e7'
}

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for i in range(0, length(resourceGroupNames)): [for role in resourceGroups[i].roles: {
  name: guid(resourceGroupNames[i], managedIdentityId, role)
  scope: subscriptionResourceId('Microsoft.Resources/resourceGroups', resourceGroupNames[i])
  properties: {
    principalId: managedIdentityId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions[role])
    principalType: 'ServicePrincipal'
  }
}]]

var resourceGroups = [
  {
    name: resourceGroupNames[0]
    roles: ['Contributor']
  }
  {
    name: resourceGroupNames[1]
    roles: ['Reader', 'Network Contributor']
  }
  {
    name: resourceGroupNames[2]
    roles: ['Contributor']
  }
]
