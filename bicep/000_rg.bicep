// ### paramters ####

//common parameres
@description(' Name of the location')
param location string

//Reource group
@description('name of the resource gorup')
param rgName string

//Tags
@description('tags for the resource')
param rg_tags object

//Branch name
@description( 'branch where start the pipeline')
param branchName string

//ADO pipeline
@description('ADO pipeline run number')
param buildNumber string

// ##  Variables  ###

var tagTrack = {
  branchName: branchName
  buildNumber: buildNumber
}

var tagsJoin = union(rg_tags,tagTrack)

// ##  Deploy ##

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: location
  name: rgName
  tags: tagsJoin

}

// ## output ##
