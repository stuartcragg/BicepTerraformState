//param identityRGName string
param location string
param environment string
param oidcIssuerUrl string
param oidcSubject string

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: 'myManagedIdentity'
  location: location
}

resource federatedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = {
  name: 'fic-${environment}' // Name of the federated identity credential
  parent: managedIdentity
  properties: {
    issuer: oidcIssuerUrl
    subject: oidcSubject
    audiences: [
      'api://AzureADTokenExchange'
    ]
  }
}

output managedIdentityId string = managedIdentity.id
output managedIdentityPrincipalId string = managedIdentity.properties.principalId
