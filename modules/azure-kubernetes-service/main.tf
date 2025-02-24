resource "azurerm_kubernetes_cluster" "cluster" {
  name                                = var.cluster_name
  location                            = var.resource_group_location
  resource_group_name                 = var.resource_group_name
  dns_prefix                          = var.cluster_name
  kubernetes_version                  = var.kubernetes_version
  node_resource_group                 = var.node_rg_name
  tags                                = var.tags
  azure_policy_enabled                = var.azure_policy_enabled
  local_account_disabled              = var.local_account_disabled
  oidc_issuer_enabled                 = var.oidc_issuer_enabled
  workload_identity_enabled           = var.workload_identity_enabled
  private_cluster_enabled             = var.private_cluster_enabled
  cost_analysis_enabled               = var.cost_analysis_enabled
  private_cluster_public_fqdn_enabled = var.private_cluster_public_fqdn_enabled
  sku_tier                            = var.sku_tier
  private_dns_zone_id                 = var.private_dns_zone_id
  automatic_upgrade_channel           = var.automatic_upgrade_channel

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    service_cidr   = var.service_cidr
    dns_service_ip = var.dns_service_ip
    load_balancer_profile {
      idle_timeout_in_minutes = 100
      outbound_ip_address_ids = var.outbound_ip_address_ids
    }
  }

  dynamic "api_server_access_profile" {
    for_each = var.api_server_authorized_ip_ranges != null ? [1] : []
    content {
      authorized_ip_ranges = var.api_server_authorized_ip_ranges
    }
  }

  storage_profile {
    blob_driver_enabled = true
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = true
    admin_group_object_ids = var.admin_group_object_ids
    tenant_id              = var.tenant_id
  }

  workload_autoscaler_profile {
    keda_enabled                    = true
    vertical_pod_autoscaler_enabled = false
  }

  maintenance_window {
    allowed {
      day   = var.maintenance_window_day
      hours = range(var.maintenance_window_start, var.maintenance_window_end)
    }
  }

  auto_scaler_profile {
    max_graceful_termination_sec     = 14400
    skip_nodes_with_local_storage    = false
    expander                         = "least-waste"
    scale_down_unneeded              = "10m"
    scale_down_utilization_threshold = 0.6
  }

  default_node_pool {
    name                         = "default"
    temporary_name_for_rotation  = "defaultrepl"
    vm_size                      = var.kubernetes_default_node_size
    auto_scaling_enabled         = true
    min_count                    = var.kubernetes_default_node_count_min
    max_count                    = var.kubernetes_default_node_count_max
    max_pods                     = var.max_pods != "" ? var.max_pods : null
    os_disk_size_gb              = var.kubernetes_default_node_os_disk_size
    type                         = "VirtualMachineScaleSets"
    vnet_subnet_id               = var.subnet_nodes_id
    zones                        = var.kubernetes_default_node_zones
    tags                         = var.tags
    only_critical_addons_enabled = true
    upgrade_settings {
      max_surge = var.max_surge
    }
  }

  identity {
    type = "SystemAssigned"
  }

  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_id != null ? [1] : []
    content {
      log_analytics_workspace_id      = var.log_analytics_workspace_id
      msi_auth_for_monitoring_enabled = true
    }
  }

  dynamic "microsoft_defender" {
    for_each = var.log_analytics_workspace_id != null ? [1] : []
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  dynamic "ingress_application_gateway" {
    for_each = var.application_gateway_id != null ? [1] : []
    content {
      gateway_id = var.application_gateway_id
    }
  }

  dynamic "monitor_metrics" {
    for_each = var.azure_prometheus_grafana_monitor.enabled ? [1] : []
    content {
      annotations_allowed = true
      labels_allowed      = true
    }
  }

  lifecycle {
    ignore_changes = [
      kubernetes_version
    ]
  }
  timeouts {
    update = "30m"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "node_pool" {
  for_each                    = var.node_pool_settings
  kubernetes_cluster_id       = azurerm_kubernetes_cluster.cluster.id
  name                        = each.key
  vm_size                     = each.value.vm_size
  temporary_name_for_rotation = lookup(each.value, "temporary_name_for_rotation", "${each.key}repl")
  auto_scaling_enabled        = each.value.auto_scaling_enabled
  min_count                   = each.value.min_count
  max_count                   = each.value.max_count
  os_disk_size_gb             = each.value.os_disk_size_gb
  mode                        = each.value.mode
  node_labels                 = each.value.node_labels
  zones                       = each.value.zones
  node_taints                 = each.value.node_taints
  os_sku                      = each.value.os_sku
  upgrade_settings {
    max_surge = each.value.upgrade_settings.max_surge
  }

  tags           = var.tags
  vnet_subnet_id = var.subnet_nodes_id
}
