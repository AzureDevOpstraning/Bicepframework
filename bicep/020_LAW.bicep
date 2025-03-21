// ## Required Paramaters //

@description('common parameters reused along the different deployment')
param common object

@description('log analitycs workspace object')
param law law_type

// ## resources //

resource lawObj 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: law.name
  location: common.location
  tags: common.tags
  properties: {
    sku: {
      name: 'PerGB2018' // Pricing tier: Can be 'Free', 'PerGB2018', etc.
    }
    retentionInDays: law.retentioninDays
    workspaceCapping: {
      dailyQuotaGb: -1 // Set retention period (default is 30 days)
    }
    feature: {
      enableLogAccessUsingOnlyRespurcePermission: false
      immediatePurgeDataOn30Days: false
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Type //

type law_type = {

  @description('log Analytic Workspace name')
  name: string

  @description('retention period in days for logs (730-2 years).')
  @maxValue(730)
  retentionInDays: int
}

//OutPut//

output resouce object = union(lawObj,{name:law.name}, {id: resourceId(lawObj.type, law.name)})
