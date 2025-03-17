targetScope = 'subscription'

param location string
param rgNames array
param tags object

// Validate that rgNames has at least 2 elements to avoid index errors
var hasEnoughRGs = length(rgNames) >= 2

resource resourceGroups 'Microsoft.Resources/resourceGroups@2021-04-01' = [for rg in rgNames: {
  name: rg
  location: location
  tags: tags
}]

output stateRGName string = hasEnoughRGs ? rgNames[0] : ''
output identityRGName string = hasEnoughRGs ? rgNames[1] : ''
