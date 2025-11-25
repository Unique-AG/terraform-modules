/**
  Log Ingestion is a large cost aspect. Users can configure the tables and plan to use for well-know large tables.
*/
resource "azurerm_log_analytics_workspace_table" "basic_log_table" {
  for_each                = var.log_analytics_workspace != null ? toset(var.log_analytics_table_configuration.tables) : []
  workspace_id            = var.log_analytics_workspace.id
  name                    = each.value
  plan                    = var.log_analytics_table_configuration.plan
  total_retention_in_days = var.retention_in_days
}


/**
  Infrastructure monitoring (Azure platform level)
*/
resource "azurerm_monitor_diagnostic_setting" "aks_diagnostic_logs" {
  count = var.log_analytics_workspace != null ? 1 : 0

  log_analytics_destination_type = var.monitor_diagnostic_settings.log_analytics_destination_type
  log_analytics_workspace_id     = var.log_analytics_workspace.id
  name                           = var.monitor_diagnostic_settings.explicit_name != null ? var.monitor_diagnostic_settings.explicit_name : "aks-diagnostic-logs"
  target_resource_id             = azurerm_kubernetes_cluster.cluster.id

  dynamic "enabled_log" {
    for_each = var.monitor_diagnostic_settings.enabled_log_categories
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = var.monitor_diagnostic_settings.enabled_metric_categories
    content {
      category = enabled_metric.value
    }
  }

}

/**
  Application monitoring (Container/application level)
*/
resource "azurerm_monitor_data_collection_rule" "ci_dcr" {
  count               = var.log_analytics_workspace != null && var.container_insights_enabled ? 1 : 0
  name                = var.monitor_data_collection_rule.explicit_name != null ? var.monitor_data_collection_rule.explicit_name : "${var.cluster_name}-ci-dcr"
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
          interval               = var.monitor_data_collection_rule.container_insights_collection_interval
          namespaceFilteringMode = var.monitor_data_collection_rule.container_insights_namespaces_filtering_mode
          namespaces             = var.monitor_data_collection_rule.container_insights_namespaces
          enableContainerLogV2   = var.monitor_data_collection_rule.container_insights_enable_container_log_v2
        }
      })
    }
  }
}

resource "azurerm_monitor_data_collection_rule_association" "ci_dcr_asc" {
  count                   = var.log_analytics_workspace != null && var.container_insights_enabled ? 1 : 0
  name                    = var.monitor_data_collection_rule.explicit_name != null ? var.monitor_data_collection_rule.explicit_name : "${var.cluster_name}-ci-dcr-asc"
  target_resource_id      = azurerm_kubernetes_cluster.cluster.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.ci_dcr[0].id
}
