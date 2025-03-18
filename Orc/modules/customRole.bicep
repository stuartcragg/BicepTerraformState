// Parameters for flexibility
param subscriptionId string = subscription().subscriptionId
param roleName string = 'Multi-Resource Backup Manager'
param roleDescription string = 'Grants permissions to query tags and manage backups for multiple Azure resource types'

// Define the custom role
resource backupManagerRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(subscriptionId, roleName) // Generates a unique ID for the role
  properties: {
    roleName: roleName
    description: roleDescription
    type: 'customRole'
    assignableScopes: [
      '/subscriptions/${subscriptionId}' // Scope to the subscription
    ]
    permissions: [
      {
        actions: [
          // Read permissions for querying tags and metadata
          'Microsoft.Storage/storageAccounts/read'                  // Storage Accounts
          'Microsoft.Compute/disks/read'                           // Azure Disks
          'Microsoft.DBforPostgreSQL/servers/read'                // PostgreSQL Servers
          'Microsoft.ContainerService/managedClusters/read'       // AKS
          'Microsoft.DBforPostgreSQL/flexibleServers/read'        // PostgreSQL Flexible Servers
          'Microsoft.DBforMySQL/flexibleServers/read'             // MySQL Flexible Servers

          // Backup-related permissions
          'Microsoft.DataProtection/backupVaults/read'            // Read backup vaults
          'Microsoft.DataProtection/backupVaults/write'           // Create/update backup vaults
          'Microsoft.DataProtection/backupPolicies/read'          // Read backup policies
          'Microsoft.DataProtection/backupPolicies/write'         // Create/update backup policies
          'Microsoft.DataProtection/backupInstances/read'         // Read backup instances
          'Microsoft.DataProtection/backupInstances/write'        // Configure backups on resources
        ]
        notActions: []
        dataActions: []
        notDataActions: []
      }
    ]
  }
}

// Output the role ID for assignment
output roleId string = backupManagerRole.id
