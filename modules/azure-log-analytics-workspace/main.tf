locals {
  default_transformations = {
    AGWAccessLogs = <<-KQL
      source
      | extend RequestUri = iif(RequestUri contains "token=" and indexof(RequestUri, "?") >= 0, strcat(substring(RequestUri, 0, indexof(RequestUri, "?")), "?[Redacted]"), RequestUri)
      | extend RequestQuery = iif(RequestQuery contains "token=", "[Redacted]", RequestQuery)
      | extend OriginalRequestUriWithArgs = iif(OriginalRequestUriWithArgs contains "token=" and indexof(OriginalRequestUriWithArgs, "?") >= 0, strcat(substring(OriginalRequestUriWithArgs, 0, indexof(OriginalRequestUriWithArgs, "?")), "?[Redacted]"), OriginalRequestUriWithArgs)
    KQL
  }

  dcr_enabled          = var.data_collection_rule != null && try(var.data_collection_rule.enabled, true)
  dcr_destination_name = coalesce(try(var.data_collection_rule.destination_name, null), "law")
  dcr_name             = coalesce(try(var.data_collection_rule.name, null), "dcr-${var.name}")
  dcr_transformations  = local.dcr_enabled ? coalesce(try(var.data_collection_rule.transformations, null), local.default_transformations) : {}
}

resource "azurerm_log_analytics_workspace" "this" {
  local_authentication_enabled = var.local_authentication_enabled
  location                     = var.location
  name                         = var.name
  resource_group_name          = var.resource_group_name
  retention_in_days            = var.retention_in_days
  sku                          = var.sku
  tags                         = var.tags

  lifecycle {
    ignore_changes = [data_collection_rule_id]
  }
}

resource "azurerm_log_analytics_workspace_table" "basic_log_table" {
  for_each                = var.basic_log_tables
  name                    = each.key
  plan                    = "Basic"
  total_retention_in_days = coalesce(each.value.retention_in_days, var.retention_in_days)
  workspace_id            = azurerm_log_analytics_workspace.this.id
}

resource "azurerm_monitor_data_collection_rule" "this" {
  count               = local.dcr_enabled ? 1 : 0
  kind                = "WorkspaceTransforms"
  location            = var.location
  name                = local.dcr_name
  resource_group_name = var.resource_group_name
  tags                = var.tags

  destinations {
    log_analytics {
      name                  = local.dcr_destination_name
      workspace_resource_id = azurerm_log_analytics_workspace.this.id
    }
  }

  dynamic "data_flow" {
    for_each = local.dcr_transformations
    content {
      destinations = [local.dcr_destination_name]
      streams      = ["Microsoft-Table-${data_flow.key}"]
      transform_kql = trimspace(replace(
        data_flow.value,
        "\n",
        " "
      ))
    }
  }

  lifecycle {
    precondition {
      condition     = length(local.dcr_transformations) > 0
      error_message = "At least one table transformation is required when data_collection_rule is enabled. Configure transformations."
    }
  }
}

resource "azapi_update_resource" "workspace_dcr" {
  count       = local.dcr_enabled ? 1 : 0
  resource_id = azurerm_log_analytics_workspace.this.id
  type        = "Microsoft.OperationalInsights/workspaces@2023-09-01"

  body = {
    properties = {
      defaultDataCollectionRuleResourceId = azurerm_monitor_data_collection_rule.this[0].id
    }
  }

  depends_on = [azurerm_monitor_data_collection_rule.this]
}
