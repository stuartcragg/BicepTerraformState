targetScope = 'subscription'

/* ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Creating the parameters for the Terraform prerequisite resource groups.
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

param createResourceGroups bool
//param tags object // Tags to apply to all resource groups

/* ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Deploy the Resource Groups.
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

var resourceGroups = [
  {
    name: 'rg-tfstate-${environment}' // Interpolates environment short code
    roles: ['Reader', 'Storage Blob Data Reader'] // Roles for the managed identity (used later in rbac.bicep)
  }
  {
    name: 'rg-network-${environment}'
    roles: ['Reader']
  }
  {
    name: 'rg-compute-${environment}'
    roles: ['Reader']
  }
]

// Resource Group creation
resource resourceGroupsArray 'Microsoft.Resources/resourceGroups@2021-04-01' = [for rg in resourceGroups: if (createResourceGroups) {
  name: rg.name
  location: location
  //tags: tags
}]

// Outputs
output resourceGroupNames array = [for rg in resourceGroups: rg.name]
