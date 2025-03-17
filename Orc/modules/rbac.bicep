param identityRGName string
param managedIdentityPrincipalId string
param roleDefinitions object
param roles array = [
  'Contributor'
] // Default role(s) to assign; can be overridden

// Create role assignments
resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (i, role) in roles: {
  name: guid(identityRGName, managedIdentityPrincipalId, role)
  properties: {
    principalId: managedIdentityPrincipalId
    roleDefinitionId: roleDefinitions[role]
    principalType: 'ServicePrincipal'
  }
}]

// Outputs
output roleAssignmentIds array = [for (i, role) in roles: roleAssignments[i].id]
