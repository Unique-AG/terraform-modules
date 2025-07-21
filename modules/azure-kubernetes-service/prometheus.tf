resource "azurerm_monitor_workspace" "monitor_workspace" {
  count               = var.azure_prometheus_grafana_monitor.enabled ? 1 : 0
  name                = "${var.cluster_name}-monitor"
  resource_group_name = var.azure_prometheus_grafana_monitor.azure_monitor_rg_name
  location            = var.azure_prometheus_grafana_monitor.azure_monitor_location
}

resource "azurerm_monitor_data_collection_endpoint" "monitor_dce" {
  count               = var.azure_prometheus_grafana_monitor.enabled ? 1 : 0
  name                = "${var.cluster_name}-monitor-dce"
  resource_group_name = var.azure_prometheus_grafana_monitor.azure_monitor_rg_name
  location            = var.azure_prometheus_grafana_monitor.azure_monitor_location
  tags                = var.tags
  kind                = "Linux"
}

resource "azurerm_monitor_data_collection_rule" "monitor_dcr" {
  count                       = var.azure_prometheus_grafana_monitor.enabled ? 1 : 0
  name                        = "${var.cluster_name}-monitor-dcr"
  resource_group_name         = var.azure_prometheus_grafana_monitor.azure_monitor_rg_name
  location                    = var.azure_prometheus_grafana_monitor.azure_monitor_location
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.monitor_dce[count.index].id
  kind                        = "Linux"

  destinations {
    monitor_account {
      monitor_account_id = azurerm_monitor_workspace.monitor_workspace[count.index].id
      name               = var.monitoring_account_name
    }
  }

  data_flow {
    streams      = ["Microsoft-PrometheusMetrics"]
    destinations = [var.monitoring_account_name]
  }

  data_sources {
    prometheus_forwarder {
      streams = ["Microsoft-PrometheusMetrics"]
      name    = "PrometheusDataSource"
    }
  }

  description = "DCR for Azure Monitor Metrics Profile (Managed Prometheus)"
  depends_on = [
    azurerm_monitor_data_collection_endpoint.monitor_dce
  ]
}

resource "azurerm_monitor_data_collection_rule_association" "monitor_dcr_asc" {
  count                   = var.azure_prometheus_grafana_monitor.enabled ? 1 : 0
  name                    = "${var.cluster_name}-monitor-dcr-asc"
  target_resource_id      = azurerm_kubernetes_cluster.cluster.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.monitor_dcr[count.index].id
  description             = "Association of data collection rule. Deleting this association will break the data collection for this AKS Cluster."
  depends_on = [
    azurerm_monitor_data_collection_rule.monitor_dcr
  ]
}

resource "azurerm_monitor_alert_prometheus_rule_group" "node_level_alerts" {
  count               = var.azure_prometheus_grafana_monitor.enabled ? 1 : 0
  name                = "${var.cluster_name}-node-level-alerts"
  location            = var.azure_prometheus_grafana_monitor.azure_monitor_location
  resource_group_name = var.azure_prometheus_grafana_monitor.azure_monitor_rg_name
  cluster_name        = azurerm_kubernetes_cluster.cluster.name
  description         = "Node level alerts for unreachable Kubernetes nodes"
  rule_group_enabled  = true
  interval            = "PT5M"
  scopes              = [azurerm_monitor_workspace.monitor_workspace[0].id, azurerm_kubernetes_cluster.cluster.id]

  dynamic "rule" {
    for_each = var.prometheus_node_alert_rules != null ? var.prometheus_node_alert_rules : []

    content {
      alert      = rule.value.alert
      enabled    = rule.value.enabled
      expression = rule.value.expression
      for        = rule.value.for
      severity   = rule.value.severity


      dynamic "action" {
        for_each = rule.value.action != null ? [rule.value.action] : (var.alert_configuration.email_receiver != null ? [{ action_group_id = azurerm_monitor_action_group.aks_alerts[0].id }] : [])
        content {
          action_group_id = action.value.action_group_id
        }
      }

      dynamic "alert_resolution" {
        for_each = rule.value.alert_resolution != null ? [rule.value.alert_resolution] : []
        content {
          auto_resolved   = alert_resolution.value.auto_resolved
          time_to_resolve = alert_resolution.value.time_to_resolve
        }
      }

      annotations = rule.value.annotations
      labels      = rule.value.labels
    }
  }

  tags = var.tags
}

resource "azurerm_monitor_alert_prometheus_rule_group" "cluster_level_alerts" {
  count               = var.azure_prometheus_grafana_monitor.enabled ? 1 : 0
  name                = "${var.cluster_name}-cluster-level-alerts"
  location            = var.azure_prometheus_grafana_monitor.azure_monitor_location
  resource_group_name = var.azure_prometheus_grafana_monitor.azure_monitor_rg_name
  cluster_name        = azurerm_kubernetes_cluster.cluster.name
  description         = "Cluster level Alert RuleGroup-RecommendedAlerts"
  rule_group_enabled  = true
  interval            = "PT5M"
  scopes              = [azurerm_monitor_workspace.monitor_workspace[0].id, azurerm_kubernetes_cluster.cluster.id]

  dynamic "rule" {
    for_each = var.prometheus_cluster_alert_rules != null ? var.prometheus_cluster_alert_rules : []

    content {
      alert      = rule.value.alert
      enabled    = rule.value.enabled
      expression = rule.value.expression
      for        = rule.value.for
      severity   = rule.value.severity

      dynamic "action" {
        for_each = rule.value.action != null ? [rule.value.action] : (var.alert_configuration.email_receiver != null ? [{ action_group_id = azurerm_monitor_action_group.aks_alerts[0].id }] : [])
        content {
          action_group_id = action.value.action_group_id
        }
      }

      dynamic "alert_resolution" {
        for_each = rule.value.alert_resolution != null ? [rule.value.alert_resolution] : []
        content {
          auto_resolved   = alert_resolution.value.auto_resolved
          time_to_resolve = alert_resolution.value.time_to_resolve
        }
      }

      annotations = rule.value.annotations
      labels      = rule.value.labels
    }
  }
  tags = var.tags
}

resource "azurerm_monitor_alert_prometheus_rule_group" "pod_level_alerts" {
  count               = var.azure_prometheus_grafana_monitor.enabled ? 1 : 0
  name                = "${var.cluster_name}-pod-level-alerts"
  location            = var.azure_prometheus_grafana_monitor.azure_monitor_location
  resource_group_name = var.azure_prometheus_grafana_monitor.azure_monitor_rg_name
  cluster_name        = azurerm_kubernetes_cluster.cluster.name
  description         = "Pod level Alert RuleGroup-RecommendedAlerts"
  rule_group_enabled  = true
  interval            = "PT5M"
  scopes              = [azurerm_monitor_workspace.monitor_workspace[0].id, azurerm_kubernetes_cluster.cluster.id]

  dynamic "rule" {
    for_each = var.prometheus_pod_alert_rules != null ? var.prometheus_pod_alert_rules : []

    content {
      alert      = rule.value.alert
      enabled    = rule.value.enabled
      expression = rule.value.expression
      for        = rule.value.for != null ? rule.value.for : null
      severity   = rule.value.severity

      dynamic "action" {
        for_each = rule.value.action != null ? [rule.value.action] : (var.alert_configuration.email_receiver != null ? [{ action_group_id = azurerm_monitor_action_group.aks_alerts[0].id }] : [])
        content {
          action_group_id = action.value.action_group_id
        }
      }

      dynamic "alert_resolution" {
        for_each = rule.value.alert_resolution != null ? [rule.value.alert_resolution] : []
        content {
          auto_resolved   = alert_resolution.value.auto_resolved
          time_to_resolve = alert_resolution.value.time_to_resolve
        }
      }

      annotations = rule.value.annotations
      labels      = rule.value.labels
    }
  }
  tags = var.tags
}

resource "azurerm_monitor_action_group" "aks_alerts" {
  count               = var.azure_prometheus_grafana_monitor.enabled && var.alert_configuration != null ? 1 : 0
  name                = "${var.cluster_name}-alerts"
  resource_group_name = var.azure_prometheus_grafana_monitor.azure_monitor_rg_name
  short_name          = var.alert_configuration.action_group != null ? var.alert_configuration.action_group.short_name : "aks-alerts"
  location            = var.alert_configuration.action_group != null ? var.alert_configuration.action_group.location : "germanywestcentral"

  email_receiver {
    name                    = var.alert_configuration.email_receiver.name
    email_address           = var.alert_configuration.email_receiver.email_address
    use_common_alert_schema = true
  }

  tags = var.tags
} 