// Required Parameters

@description( 'common prameters reused along the different deployments')
param common object

@description('azure key vault object')
param akv akv_type

@description('log analitycs workspace object')
param law object

// Resource //

resource akvobj 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: akv.name
  location: common.location
  tags:common.tags
  properties: {
    sku:{
      family: 'A'
      name: 'premium'
     }
     enabledForDeployment: true
     enabledForDiskEncryption: true
     enabledForTemplateDeployment: true
     enablePurgeProtection: true
     enableRbacAuthorization: false
     softDeleteRetentionInDays: akv.softDeleteRetentionInDays
     tenantId: akv.tenantId
     publicNetworkAccess: 'Enabled'
     accessPolicies: akv.accessPolicies
     createMode: akv.createMode
  }
}

resource law_akvDS 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name:'${law.name}-${akv.name}-DS'
  scope: akvobj
  properties: {
    workspaceId: law.id
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

//Lock//

resource rg_lock 'Microsoft.Authorization/locks@2017-04-01' = {
  name: akv.name
  scope: akvobj
  properties: {
    level:'CanNotDelete'
    notes: 'add your comments'
  }
}

//Type//

type akv_type = {

  @description('azure key vault name')
  name: string

  @description('soft delete data after this number of days, between 90 anf 490.')
  @minValue(90)
  @maxValue(490)
  softDeleteRetentionDays: int

  tenantId: string

  @description(' indicate wheter the keyvault need to be recovered ot not [ recover | default]')
  creteMode: 'default' | 'recover'

  accessPolicies: accessPolicies_type[]

}

type accessPolicies_type = {

  @description(' azure keyvault tenant Id')
  tenantId: string

  @description('Object ID: AppReg | Group |User')
  ObjectId: string

  @description('Premission to grant')
  permission: {
    keys: string[]?
    secrets: string[]?
    certificates: string[]?
    storage: string[]?
  }
}

// Output //

output resource object = union(akvobj, {name:akv.name}, {id: resourceId(akvobj.type, akv.name)})
