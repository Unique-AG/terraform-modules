locals {
  model_version_endpoints = [
    for account in azurerm_cognitive_account.aca :  {
      "endpoint": account.endpoint,
      "location": account.location,
      "models": [
        for deployment in azurerm_cognitive_deployment.deployments : {
          "modelName": deployment.model[0].name,
          "deploymentName": deployment.name,
          "modelVersion": deployment.model[0].version
        } if deployment.cognitive_account_id == account.id
      ]
    }
  ]
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
  for_each               = var.cognitive_deployments
  name                   = each.value.name
  cognitive_account_id   = azurerm_cognitive_account.aca[each.value.cognitive_account].id
  rai_policy_name        = each.value.rai_policy_name
  version_upgrade_option = each.value.version_upgrade_option

  model {
    format  = each.value.model_format
    name    = each.value.model_name
    version = each.value.model_version
  }

  sku {
    name     = each.value.sku_type
    capacity = each.value.sku_capacity
  }
}
