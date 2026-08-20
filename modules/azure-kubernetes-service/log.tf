locals {
  diagnostic_logs_default_categories = ["cluster-autoscaler"]
  diagnostic_logs_base_categories    = var.control_plane_logs.categories != null ? var.control_plane_logs.categories : local.diagnostic_logs_default_categories
  diagnostic_logs_enabled_categories = distinct(concat(
    local.diagnostic_logs_base_categories,
    var.control_plane_logs.extra_categories,
  ))
  diagnostic_logs_unsupported_categories = var.log_analytics_workspace != null && var.control_plane_logs.enabled ? [
    for category in local.diagnostic_logs_enabled_categories : category
    if !contains(data.azurerm_monitor_diagnostic_categories.aks[0].log_category_types, category)
  ] : []
}

data "azurerm_monitor_diagnostic_categories" "aks" {
  count       = var.log_analytics_workspace != null && var.control_plane_logs.enabled ? 1 : 0
  resource_id = azurerm_kubernetes_cluster.cluster.id
}

resource "azurerm_monitor_diagnostic_setting" "aks_diagnostic_logs" {
  count                          = var.log_analytics_workspace != null && var.control_plane_logs.enabled ? 1 : 0
  name                           = "aks-diagnostic-logs"
  target_resource_id             = azurerm_kubernetes_cluster.cluster.id
  log_analytics_workspace_id     = var.log_analytics_workspace.id
  log_analytics_destination_type = "Dedicated"

  dynamic "enabled_log" {
    for_each = local.diagnostic_logs_enabled_categories
    content {
      category = enabled_log.value
    }
  }

  enabled_metric {
    category = "AllMetrics"
  }

  lifecycle {
    precondition {
      condition     = length(local.diagnostic_logs_unsupported_categories) == 0
      error_message = "Unsupported control_plane_logs categories: ${join(", ", local.diagnostic_logs_unsupported_categories)}. Supported categories: ${join(", ", data.azurerm_monitor_diagnostic_categories.aks[0].log_category_types)}."
    }
  }
}

resource "azurerm_monitor_data_collection_rule" "ci_dcr" {
  count               = var.log_analytics_workspace != null && var.data_plane_logs.enabled ? 1 : 0
  name                = "${var.cluster_name}-ci-dcr"
  resource_group_name = var.log_analytics_workspace.resource_group_name
  location            = var.log_analytics_workspace.location
  tags                = var.tags
  kind                = "Linux"

  destinations {
    log_analytics {
      name                  = "ciworkspace"
      workspace_resource_id = var.log_analytics_workspace.id
    }
  }

  data_flow {
    streams      = var.data_plane_logs.streams
    destinations = ["ciworkspace"]
  }

  data_sources {
    extension {
      name           = "ContainerInsightsExtension"
      streams        = var.data_plane_logs.streams
      extension_name = "ContainerInsights"
      extension_json = jsonencode({
        dataCollectionSettings = {
          interval               = "10m"
          namespaceFilteringMode = "Exclude"
          namespaces = [
            "kube-system",
            "gatekeeper-system",
            "azure-arc"
          ]
          enableContainerLogV2 = true
        }
      })
    }
  }
}

resource "azurerm_monitor_data_collection_rule_association" "ci_dcr_asc" {
  count                   = var.log_analytics_workspace != null && var.data_plane_logs.enabled ? 1 : 0
  name                    = "${var.cluster_name}-ci-dcr-asc"
  target_resource_id      = azurerm_kubernetes_cluster.cluster.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.ci_dcr[0].id
}
