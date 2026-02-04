resource "azurerm_cognitive_account" "aca" {
  for_each                      = var.accounts
  name                          = "${var.speech_service_name}-${each.key}"
  location                      = each.value.location
  resource_group_name           = var.resource_group_name
  kind                          = each.value.account_kind
  sku_name                      = each.value.account_sku_name
  tags                          = var.tags
  custom_subdomain_name         = each.value.custom_subdomain_name
  public_network_access_enabled = each.value.public_network_access_enabled

  dynamic "identity" {
    for_each = each.value.identity != null || each.value.customer_managed_key != null ? [1] : []
    content {
      type = (
        each.value.identity != null &&
        each.value.identity.type == "SystemAssigned" &&
        each.value.customer_managed_key != null
        ) ? "SystemAssigned, UserAssigned" : (
        each.value.identity != null ? each.value.identity.type : "UserAssigned"
      )
      identity_ids = (
        each.value.identity != null &&
        each.value.identity.type == "SystemAssigned" &&
        each.value.customer_managed_key == null
        ) ? null : concat(
        each.value.identity != null && each.value.identity.identity_ids != null ? each.value.identity.identity_ids : [],
        each.value.customer_managed_key != null ? [each.value.customer_managed_key.user_assigned_identity.resource_id] : []
      )
    }
  }

  lifecycle {
    ignore_changes = [customer_managed_key]
  }
}

resource "azurerm_private_endpoint" "pe" {
  for_each            = { for k, v in var.accounts : k => v if try(v.private_endpoint != null, false) }
  name                = "${var.speech_service_name}-${each.key}-pe"
  location            = each.value.private_endpoint.vnet_location
  resource_group_name = var.resource_group_name
  subnet_id           = each.value.private_endpoint.subnet_id

  private_service_connection {
    name                           = "${var.speech_service_name}-${each.key}-psc"
    private_connection_resource_id = azurerm_cognitive_account.aca[each.key].id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [each.value.private_endpoint.private_dns_zone_id]
  }
}

resource "azurerm_monitor_diagnostic_setting" "diag" {
  for_each                   = { for k, v in var.accounts : k => v if try(v.diagnostic_settings != null, false) }
  name                       = "${var.speech_service_name}-${each.key}-diag"
  target_resource_id         = azurerm_cognitive_account.aca[each.key].id
  log_analytics_workspace_id = try(each.value.diagnostic_settings.log_analytics_workspace_id, null)

  dynamic "enabled_log" {
    for_each = try(each.value.diagnostic_settings.enabled_log_categories, [])
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = try(
      each.value.diagnostic_settings != null ?
      (each.value.diagnostic_settings.enabled_metrics != null ?
        each.value.diagnostic_settings.enabled_metrics :
        ["AllMetrics"]
      ) :
      []
    )
    content {
      category = enabled_metric.value
    }
  }

  lifecycle {
    precondition {
      condition     = try(each.value.diagnostic_settings != null ? each.value.diagnostic_settings.log_analytics_workspace_id != null : true, true)
      error_message = "Log analytics workspace ID is required when diagnostic settings are enabled"
    }
  }
}

resource "azurerm_role_assignment" "workload_identity" {
  for_each             = { for k, v in var.accounts : k => v if try(v.workload_identity, null) != null }
  scope                = azurerm_cognitive_account.aca[each.key].id
  role_definition_name = each.value.workload_identity.role_definition_name
  principal_id         = each.value.workload_identity.principal_id
}

locals {
  accounts_with_cmk = {
    for k, v in var.accounts : k => v
    if v.customer_managed_key != null
  }

  azure_speech_service_endpoints = [
    for key, value in var.accounts : azurerm_cognitive_account.aca[key].endpoint
  ]
  azure_speech_service_endpoint_definitions = [
    for key, value in var.accounts : {
      name     = key
      endpoint = azurerm_cognitive_account.aca[key].endpoint
      location = azurerm_cognitive_account.aca[key].location
    }
  ]
}

resource "azurerm_cognitive_account_customer_managed_key" "cmk" {
  for_each = local.accounts_with_cmk

  cognitive_account_id = azurerm_cognitive_account.aca[each.key].id
  key_vault_key_id     = each.value.customer_managed_key.key_vault_key_id
  identity_client_id   = each.value.customer_managed_key.user_assigned_identity.client_id
}
