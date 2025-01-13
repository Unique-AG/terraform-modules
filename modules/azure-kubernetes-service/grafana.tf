locals {
  grafana_name = "${substr(var.cluster_name, 0, 15)}-grafana"
}

resource "azurerm_dashboard_grafana" "grafana" {
  count                 = var.azure_prometheus_grafana_monitor.enabled ? 1 : 0
  name                  = local.grafana_name
  resource_group_name   = var.azure_prometheus_grafana_monitor.azure_monitor_rg_name
  grafana_major_version = var.azure_prometheus_grafana_monitor.grafana_major_version
  location              = var.azure_prometheus_grafana_monitor.azure_monitor_location

  identity {
    type = "SystemAssigned"
  }

  azure_monitor_workspace_integrations {
    resource_id = azurerm_monitor_workspace.monitor_workspace[count.index].id
  }
}
