targetScope = 'resourceGroup'

@description('Environment name')
param environment string = 'Production'

@description('Prefix for resource names')
param prefix string = 'rendo'

@description('Location for all resources')
param location string = resourceGroup().location

var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 6)

// 1. Modulo de Monitoreo (Log Analytics + App Insights)
module monitoring 'modules/monitoring.bicep' = {
  name: 'monitoringDeployment'
  params: {
    location: location
    prefix: prefix
  }
}

// 2. Modulo de Identidad Administrada (UAMI)
module identity 'modules/identity.bicep' = {
  name: 'identityDeployment'
  params: {
    location: location
    prefix: prefix
  }
}

// 3. Modulo de Azure Key Vault
module keyvault 'modules/keyvault.bicep' = {
  name: 'keyvaultDeployment'
  params: {
    location: location
    prefix: prefix
    uniqueSuffix: uniqueSuffix
  }
}

output logAnalyticsId string = monitoring.outputs.logAnalyticsId
output appInsightsConnectionString string = monitoring.outputs.appInsightsConnectionString
output uamiPrincipalId string = identity.outputs.uamiPrincipalId
output keyVaultUri string = keyvault.outputs.keyVaultUri
