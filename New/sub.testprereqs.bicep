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

param tags object = {
  environment: environment
  project: 'terraform-prereqs'
  owner: 'DevOps Team'
}

targetScope = 'subscription'

resource identityRG 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: '${identityRGName}-${environment}'
  location: location
  tags: tags
}

resource stateRG 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: '${stateRGName}-${environment}'
  location: location
  tags: tags
}

resource backupsRG'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: '${backupsRGName}-${environment}'
  location: location
  tags: tags
}
