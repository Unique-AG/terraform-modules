resource "azurerm_cognitive_account" "aca" {
  for_each              = var.accounts
  name                  = "${var.speech_service_name}-${each.key}"
  location              = each.value.location
  resource_group_name   = var.resource_group_name
  kind                  = each.value.account_kind
  sku_name              = each.value.account_sku_name
  tags                  = var.tags
  custom_subdomain_name = each.value.custom_subdomain_name

  dynamic "identity" {
    for_each = each.value.identity != null ? [1] : []
    content {
      type         = each.value.identity.type
      identity_ids = each.value.identity.identity_ids
    }
  }
}

resource "azurerm_private_endpoint" "pe" {
  for_each            = { for k, v in var.accounts : k => v if try(v.private_endpoint != null, false) }
  name                = "${var.speech_service_name}-${each.key}-pe"
  location            = each.value.location
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

  dynamic "metric" {
    for_each = try(
      each.value.diagnostic_settings != null ?
      (each.value.diagnostic_settings.enabled_metrics != null ?
        each.value.diagnostic_settings.enabled_metrics :
        ["AllMetrics"]
      ) :
      []
    )
    content {
      category = metric.value
      enabled  = each.value.diagnostic_settings.enabled_metrics != null
    }
  }

  lifecycle {
    precondition {
      condition     = try(each.value.diagnostic_settings != null ? each.value.diagnostic_settings.log_analytics_workspace_id != null : true, true)
      error_message = "Log analytics workspace ID is required when diagnostic settings are enabled"
    }
  }
}

resource "azurerm_network_security_group" "nsg" {
  for_each            = { for k, v in var.accounts : k => v if try(v.network_security_group, null) != null }
  name                = "${var.speech_service_name}-${each.key}-nsg"
  location            = each.value.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dynamic "security_rule" {
    for_each = try(each.value.network_security_group.security_rules, [])
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = try(security_rule.value.source_port_range, "*")
      destination_port_range     = try(security_rule.value.destination_port_range, "*")
      source_address_prefix      = try(security_rule.value.source_address_prefix, "*")
      destination_address_prefix = try(security_rule.value.destination_address_prefix, "*")
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
