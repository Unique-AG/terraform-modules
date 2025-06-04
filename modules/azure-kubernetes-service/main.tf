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
  node_os_upgrade_channel             = var.node_os_upgrade_channel

  dynamic "network_profile" {
    for_each = var.network_profile != null ? [1] : []
    content {
      network_plugin = var.network_profile.network_plugin
      network_policy = var.network_profile.network_policy
      service_cidr   = var.network_profile.service_cidr
      dns_service_ip = var.network_profile.dns_service_ip
      outbound_type  = var.network_profile.outbound_type
      dynamic "load_balancer_profile" {
        for_each = var.network_profile.outbound_type == "loadBalancer" ? [1] : []
        content {
          idle_timeout_in_minutes   = var.network_profile.idle_timeout_in_minutes
          managed_outbound_ip_count = var.network_profile.managed_outbound_ip_count
          outbound_ip_address_ids   = var.network_profile.outbound_ip_address_ids
          outbound_ip_prefix_ids    = var.network_profile.outbound_ip_prefix_ids
        }
      }
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
    os_disk_size_gb              = var.kubernetes_default_node_os_disk_size
    type                         = "VirtualMachineScaleSets"
    vnet_subnet_id               = var.default_subnet_nodes_id
    pod_subnet_id                = var.segregated_node_and_pod_subnets_enabled ? coalesce(var.default_subnet_pods_id, var.default_subnet_nodes_id) : null
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

  dynamic "maintenance_window_auto_upgrade" {
    for_each = var.maintenance_window_auto_upgrade != null ? [1] : []
    content {
      frequency    = var.maintenance_window_auto_upgrade.frequency
      interval     = var.maintenance_window_auto_upgrade.interval
      duration     = var.maintenance_window_auto_upgrade.duration
      day_of_week  = var.maintenance_window_auto_upgrade.day_of_week
      day_of_month = var.maintenance_window_auto_upgrade.day_of_month
      week_index   = var.maintenance_window_auto_upgrade.week_index
      start_time   = var.maintenance_window_auto_upgrade.start_time
      utc_offset   = var.maintenance_window_auto_upgrade.utc_offset
      start_date   = var.maintenance_window_auto_upgrade.start_date
      not_allowed {
        start = var.maintenance_window_auto_upgrade.not_allowed.start
        end   = var.maintenance_window_auto_upgrade.not_allowed.end
      }
    }
  }

  dynamic "maintenance_window_node_os" {
    for_each = var.maintenance_window_node_os != null ? [1] : []
    content {
      frequency    = var.maintenance_window_node_os.frequency
      interval     = var.maintenance_window_node_os.interval
      duration     = var.maintenance_window_node_os.duration
      day_of_week  = var.maintenance_window_node_os.day_of_week
      day_of_month = var.maintenance_window_node_os.day_of_month
      week_index   = var.maintenance_window_node_os.week_index
      start_time   = var.maintenance_window_node_os.start_time
      utc_offset   = var.maintenance_window_node_os.utc_offset
      start_date   = var.maintenance_window_node_os.start_date
      not_allowed {
        start = var.maintenance_window_node_os.not_allowed.start
        end   = var.maintenance_window_node_os.not_allowed.end
      }
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
  for_each              = var.node_pool_settings
  kubernetes_cluster_id = azurerm_kubernetes_cluster.cluster.id

  auto_scaling_enabled        = each.value.auto_scaling_enabled
  max_count                   = each.value.max_count
  max_pods                    = try(each.value.max_pods, null)
  min_count                   = each.value.min_count
  mode                        = each.value.mode
  name                        = each.key
  node_labels                 = each.value.node_labels
  node_taints                 = each.value.node_taints
  os_disk_size_gb             = each.value.os_disk_size_gb
  os_sku                      = each.value.os_sku
  pod_subnet_id               = var.segregated_node_and_pod_subnets_enabled ? coalesce(each.value.subnet_pods_id, each.value.subnet_nodes_id, var.default_subnet_pods_id, var.default_subnet_nodes_id) : null
  tags                        = var.tags
  temporary_name_for_rotation = coalesce(each.value.temporary_name_for_rotation, "${each.key}repl")
  vm_size                     = each.value.vm_size
  vnet_subnet_id              = coalesce(each.value.subnet_nodes_id, var.default_subnet_nodes_id)
  zones                       = each.value.zones

  upgrade_settings {
    max_surge = each.value.upgrade_settings.max_surge
  }
}
