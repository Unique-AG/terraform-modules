locals {
  model_version_endpoints = [
    for account in azurerm_cognitive_account.aca : {
      "endpoint" : account.endpoint,
      "location" : account.location,
      "models" : [
        for deployment in azurerm_cognitive_deployment.deployments : {
          "modelName" : deployment.model[0].name,
          "deploymentName" : deployment.name,
          "modelVersion" : deployment.model[0].version
        } if deployment.cognitive_account_id == account.id
      ]
    }
  ]

  flattened_deployments = flatten([
    for account_key, account in var.cognitive_accounts : [
      for deployment in account.cognitive_deployments : {
        account_key = account_key
        deployment  = deployment
      }
    ]
  ])


}
resource "azurerm_cognitive_account" "aca" {
  for_each                      = var.cognitive_accounts
  name                          = each.value.name
  location                      = each.value.location
  resource_group_name           = var.resource_group_name
  kind                          = each.value.kind
  sku_name                      = each.value.sku_name
  tags                          = var.tags
  public_network_access_enabled = each.value.public_network_access_enabled
  local_auth_enabled            = each.value.local_auth_enabled
  custom_subdomain_name         = each.value.custom_subdomain_name
}

resource "azurerm_cognitive_deployment" "deployments" {

  for_each = {
    for deployment in local.flattened_deployments : "${deployment.account_key}-${deployment.deployment.name}" => deployment
  }
  name                   = each.value.deployment.name
  cognitive_account_id   = azurerm_cognitive_account.aca[each.value.account_key].id
  rai_policy_name        = each.value.deployment.rai_policy_name
  version_upgrade_option = each.value.deployment.version_upgrade_option

  model {
    format  = each.value.deployment.model_format
    name    = each.value.deployment.model_name
    version = each.value.deployment.model_version
  }

  sku {
    name     = each.value.deployment.sku_type
    capacity = each.value.deployment.sku_capacity
  }
}
