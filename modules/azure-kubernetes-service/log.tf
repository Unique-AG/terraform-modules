locals {
  # https://learn.microsoft.com/en-gb/azure/aks/monitor-aks-reference#resource-logs
  diagnostic_logs_all_categories = [
    "cloud-controller-manager",
    "cluster-autoscaler",
    "csi-azuredisk-controller",
    "csi-azurefile-controller",
    "csi-snapshot-controller",
    "kube-audit-admin",
    "kube-scheduler",
  ]
  basic_log_tables = [
    "ContainerLogV2",
    "AKSControlPlane",
  ]
}

resource "azurerm_log_analytics_workspace_table" "basic_log_table" {
  count                   = var.log_analytics_workspace_id != null ? length(local.basic_log_tables) : 0
  workspace_id            = var.log_analytics_workspace_id
  name                    = local.basic_log_tables[count.index]
  plan                    = var.log_table_plan
  total_retention_in_days = var.retention_in_days
}

resource "azurerm_monitor_diagnostic_setting" "aks_diagnostic_logs" {
  count                          = var.log_analytics_workspace_id != null ? 1 : 0
  name                           = "aks-diagnostic-logs"
  target_resource_id             = azurerm_kubernetes_cluster.cluster.id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = "Dedicated"

  dynamic "enabled_log" {
    for_each = local.diagnostic_logs_all_categories
    content {
      category = enabled_log.value
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }
}

resource "azurerm_monitor_data_collection_rule" "ci_dcr" {
  count               = var.log_analytics_workspace_id != null ? 1 : 0
  name                = "${var.cluster_name}-ci-dcr"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  tags                = var.tags
  kind                = "Linux"

  destinations {
    log_analytics {
      name                  = "ciworkspace"
      workspace_resource_id = var.log_analytics_workspace_id
    }
  }

  data_flow {
    streams      = ["Microsoft-ContainerInsights-Group-Default"]
    destinations = ["ciworkspace"]
  }

  data_sources {
    extension {
      name           = "ContainerInsightsExtension"
      streams        = ["Microsoft-ContainerInsights-Group-Default"]
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
  count                   = var.log_analytics_workspace_id != null ? 1 : 0
  name                    = "${var.cluster_name}-ci-dcr-asc"
  target_resource_id      = azurerm_kubernetes_cluster.cluster.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.ci_dcr[0].id
}
