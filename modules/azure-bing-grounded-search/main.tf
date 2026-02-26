// Mimics https://github.com/azure-ai-foundry/foundry-samples/blob/main/infrastructure/infrastructure-setup-bicep/45-basic-agent-bing/modules/add-bing-search-tool.bicep as Terraform module.

locals {
  has_private_endpoint = var.foundry_account.private_endpoint != null
  has_network_acls     = var.foundry_account.network_acls != null

  public_network_access_enabled = !local.has_private_endpoint
  network_acls_default_action   = local.has_network_acls ? "Deny" : "Allow"
  network_acls_ip_rules         = local.has_network_acls ? var.foundry_account.network_acls.ip_rules : []
  network_acls_subnet_ids       = local.has_network_acls ? var.foundry_account.network_acls.virtual_network_subnet_ids : []
}


resource "azurerm_cognitive_account" "foundry_account" {
  custom_subdomain_name         = var.foundry_account.custom_subdomain_name
  kind                          = "AIServices"
  local_auth_enabled            = false
  location                      = var.foundry_account.location
  name                          = var.foundry_account.name
  project_management_enabled    = true
  public_network_access_enabled = local.public_network_access_enabled
  resource_group_name           = coalesce(var.foundry_account.resource_group_name, var.resource_group_name)
  sku_name                      = var.foundry_account.sku_name
  tags                          = merge(var.tags, var.foundry_account.extra_tags)
  identity { type = "SystemAssigned" }

  network_acls {
    default_action = local.network_acls_default_action
    bypass         = "AzureServices"
    ip_rules       = local.network_acls_ip_rules
    dynamic "virtual_network_rules" {
      for_each = local.network_acls_subnet_ids
      content {
        subnet_id = virtual_network_rules.value
      }
    }
  }
}

resource "azapi_resource" "foundry_project" {
  for_each                  = var.foundry_projects
  location                  = var.foundry_account.location
  name                      = each.key
  parent_id                 = azurerm_cognitive_account.foundry_account.id
  type                      = "Microsoft.CognitiveServices/accounts/projects@2025-06-01"
  schema_validation_enabled = false

  body = {
    sku = {
      name = "S0"
    }
    properties = {
      description = each.value.description
      displayName = each.value.display_name
    }
  }

  identity {
    type = "SystemAssigned"
  }

  response_export_values = ["properties"]
}

resource "azurerm_private_endpoint" "foundry_account_private_endpoint" {
  count               = local.has_private_endpoint ? 1 : 0
  name                = "${var.foundry_account.name}-pe"
  location            = coalesce(var.foundry_account.private_endpoint.location, var.foundry_account.location)
  resource_group_name = coalesce(var.foundry_account.private_endpoint.resource_group_name, var.resource_group_name)
  subnet_id           = var.foundry_account.private_endpoint.subnet_id
  private_service_connection {
    name                           = "${var.foundry_account.name}-psc"
    private_connection_resource_id = azurerm_cognitive_account.foundry_account.id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.foundry_account.private_endpoint.private_dns_zone_id]
  }
}

resource "azurerm_cognitive_deployment" "agent_deployment" {
  name                   = var.deployment.name
  cognitive_account_id   = azurerm_cognitive_account.foundry_account.id
  version_upgrade_option = var.deployment.version_upgrade_option
  rai_policy_name        = var.deployment.rai_policy_name

  model {
    format  = var.deployment.model_format
    name    = var.deployment.model_name
    version = var.deployment.model_version
  }

  sku {
    name     = var.deployment.sku_name
    capacity = var.deployment.sku_capacity
  }
}

resource "azapi_resource" "bing_grounding" {
  location                  = "global"
  name                      = var.bing_account.name
  parent_id                 = var.bing_account.resource_group_id
  schema_validation_enabled = false # Microsoft.Bing/accounts type is not in the azapi schema
  type                      = "Microsoft.Bing/accounts@2020-06-10"
  # Microsoft.Bing/accounts requires camelCase tag keys
  tags = { for k, v in merge(var.tags, var.bing_account.extra_tags) : "${lower(substr(k, 0, 1))}${substr(k, 1, length(k) - 1)}" => v }

  body = {
    kind = "Bing.Grounding"
    sku = {
      name = var.bing_account.sku_name
    }
  }
}

resource "azapi_resource_action" "bing_search_keys" {
  action                 = "listKeys"
  method                 = "POST"
  response_export_values = ["key1"]
  resource_id            = azapi_resource.bing_grounding.id
  type                   = "Microsoft.Bing/accounts@2020-06-10"
}

resource "azapi_resource" "bing_search_connection" {
  for_each                  = var.foundry_projects
  name                      = "${each.key}-bsc"
  parent_id                 = azapi_resource.foundry_project[each.key].id
  type                      = "Microsoft.CognitiveServices/accounts/projects/connections@2025-06-01"
  schema_validation_enabled = false

  body = {
    properties = {
      category = "ApiKey"
      target   = "https://api.bing.microsoft.com/"
      authType = "ApiKey"
      credentials = {
        key = azapi_resource_action.bing_search_keys.output.key1
      }
      isSharedToAll = false
      metadata = {
        ApiType    = "Azure"
        Location   = azapi_resource.bing_grounding.location
        ResourceId = azapi_resource.bing_grounding.id
      }
    }
  }

  response_export_values = ["properties"]
}
