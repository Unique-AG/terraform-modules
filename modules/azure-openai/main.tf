locals {
  model_version_endpoints = [
    for account_key, account in azurerm_cognitive_account.aca : {
      "endpoint" : account.endpoint,
      "location" : account.location,
      "key" : var.cognitive_accounts[account_key].model_definitions_auth_strategy_injected == "ApiKey" ? (account.primary_access_key != null ? account.primary_access_key : local.key_placeholder) : "WORKLOAD_IDENTITY", # to be a real enum, this would need to be adjusted to support more than two values (switch instead of if/else so to say)
      "models" : [
        for deployment in azurerm_cognitive_deployment.deployments : {
          "deploymentName" : deployment.name,
          "modelName" : deployment.model[0].name,
          "modelVersion" : deployment.model[0].version,
          var.endpoint_definitions_secret.sku_capacity_field_name : deployment.sku[0].capacity,
          var.endpoint_definitions_secret.sku_name_field_name : deployment.sku[0].name
        } if deployment.cognitive_account_id == account.id
      ]
    }
  ]

  flattened_deployments = flatten([
    for account_key, account in var.cognitive_accounts : [
      for deployment in account.cognitive_deployments : {
        account_key            = account_key
        name                   = deployment.name
        model_name             = deployment.model_name
        model_version          = deployment.model_version
        model_format           = deployment.model_format
        sku_capacity           = deployment.sku_capacity
        sku_type               = deployment.sku_type
        rai_policy_name        = deployment.rai_policy_name
        version_upgrade_option = deployment.version_upgrade_option
      }
    ]
  ])
}

resource "azurerm_cognitive_account" "aca" {
  for_each = var.cognitive_accounts

  custom_subdomain_name         = each.value.custom_subdomain_name
  kind                          = each.value.kind
  local_auth_enabled            = each.value.local_auth_enabled
  location                      = each.value.location
  name                          = each.value.name
  public_network_access_enabled = each.value.public_network_access_enabled
  resource_group_name           = var.resource_group_name
  sku_name                      = each.value.sku_name
  tags                          = var.tags
}

resource "azurerm_cognitive_deployment" "deployments" {

  for_each = {
    for deployment in local.flattened_deployments : "${deployment.account_key}-${deployment.name}" => deployment
  }

  cognitive_account_id   = azurerm_cognitive_account.aca[each.value.account_key].id
  name                   = each.value.name
  rai_policy_name        = each.value.rai_policy_name
  version_upgrade_option = each.value.version_upgrade_option

  model {
    format  = each.value.model_format
    name    = each.value.model_name
    version = each.value.model_version
  }

  sku {
    capacity = each.value.sku_capacity
    name     = each.value.sku_name
  }
}

resource "azurerm_private_endpoint" "pe" {
  for_each            = { for k, v in var.cognitive_accounts : k => v if try(v.private_endpoint != null, false) }
  name                = "${each.key}-pe"
  location            = each.value.private_endpoint.vnet_location != null ? each.value.private_endpoint.vnet_location : each.value.location
  resource_group_name = var.resource_group_name
  subnet_id           = each.value.private_endpoint.subnet_id

  private_service_connection {
    name                           = "${each.key}-psc"
    private_connection_resource_id = azurerm_cognitive_account.aca[each.key].id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [each.value.private_endpoint.private_dns_zone_id]
  }
}
