variable "cluster_name" {
  description = "The name of the Kubernetes cluster."
  type        = string
  validation {
    condition     = length(var.cluster_name) > 0
    error_message = "The cluster name must not be empty."
  }
}

variable "resource_group_location" {
  description = "The location of the resource group."
  type        = string
  validation {
    condition     = length(var.resource_group_location) > 0
    error_message = "The resource group location must not be empty."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "The resource group name must not be empty."
  }
}

variable "kubernetes_version" {
  description = "The Kubernetes version to use for the AKS cluster. If not specified (null), the latest stable version will be used and version changes will be ignored. If specified, version changes will be tracked."
  type        = string
  default     = null
}

variable "maintenance_window_day" {
  description = "The day of the maintenance window."
  type        = string
  default     = "Sunday"

  validation {
    condition     = contains(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], var.maintenance_window_day)
    error_message = "The maintenance window day must be a valid day of the week."
  }
}

variable "maintenance_window_start" {
  description = "The start hour of the maintenance window."
  type        = number
  default     = 16

  validation {
    condition     = var.maintenance_window_start >= 0 && var.maintenance_window_start <= 23
    error_message = "The maintenance window start hour must be between 0 and 23."
  }
}

variable "maintenance_window_end" {
  description = "The end hour of the maintenance window."
  type        = number
  default     = 23

  validation {
    condition     = var.maintenance_window_end >= 0 && var.maintenance_window_end <= 23
    error_message = "The maintenance window end hour must be between 0 and 23."
  }
}

variable "max_surge" {
  description = "The maximum number of nodes to surge during upgrades."
  type        = number
  default     = 1

  validation {
    condition     = var.max_surge >= 1
    error_message = "The maximum number of nodes to surge during upgrades must be at least 1."
  }
}

variable "drain_timeout_in_minutes" {
  description = "Maximum minutes AKS will wait for pods on a node to drain during an upgrade. AKS uses a short internal default (~6 min) which is too tight for slow-to-evict workloads (Kata-VM, large stateful pods, custom controllers). Range 0-1440."
  type        = number
  default     = null

  validation {
    condition     = var.drain_timeout_in_minutes == null || (try(var.drain_timeout_in_minutes, 0) >= 0 && try(var.drain_timeout_in_minutes, 0) <= 1440)
    error_message = "drain_timeout_in_minutes must be between 0 and 1440 (or null to use the AKS default)."
  }
}

variable "node_soak_duration_in_minutes" {
  description = "Time AKS waits after a new node becomes Ready before moving on to the next node during an upgrade. Range 0-30."
  type        = number
  default     = null

  validation {
    condition     = var.node_soak_duration_in_minutes == null || (try(var.node_soak_duration_in_minutes, 0) >= 0 && try(var.node_soak_duration_in_minutes, 0) <= 30)
    error_message = "node_soak_duration_in_minutes must be between 0 and 30 (or null to use the AKS default)."
  }
}

variable "undrainable_node_behavior" {
  description = "What AKS does when a node can't be drained within the timeout (default_node_pool only). \"Schedule\" (AKS default) fails the upgrade. \"Cordon\" leaves the node cordoned and continues so one stuck workload doesn't block the whole upgrade. Set per-pool via *_node_pool_settings.upgrade_settings.undrainable_node_behavior for user pools."
  type        = string
  default     = null

  validation {
    condition     = var.undrainable_node_behavior == null || contains(["Cordon", "Schedule"], coalesce(var.undrainable_node_behavior, "null"))
    error_message = "undrainable_node_behavior must be \"Cordon\", \"Schedule\", or null."
  }
}

variable "api_server_authorized_ip_ranges" {
  description = "The IP ranges that are allowed to access the Kubernetes API server."
  type        = list(string)
  default     = null

}

variable "node_rg_name" {
  description = "The name of the node resource group for the AKS cluster."
  type        = string
  validation {
    condition     = length(var.node_rg_name) > 0
    error_message = "The node resource group name must not be empty."
  }
}

variable "default_node_pool" {
  description = "Default system node pool configuration."
  type = object({
    vm_size                     = optional(string, "Standard_D2s_v5")
    node_count                  = optional(number)
    min_count                   = optional(number)
    max_count                   = optional(number)
    os_disk_size_gb             = optional(number, 100)
    os_sku                      = optional(string)
    zones                       = optional(list(string), ["1", "3"])
    temporary_name_for_rotation = optional(string, "defaultrepl")
  })
  default = {
    min_count = 2
    max_count = 5
  }

  validation {
    condition     = length(var.default_node_pool.vm_size) > 0
    error_message = "default_node_pool.vm_size must not be empty."
  }

  validation {
    condition     = var.default_node_pool.node_count == null || var.default_node_pool.node_count >= 1
    error_message = "default_node_pool.node_count must be at least 1 when set."
  }

  validation {
    condition     = var.default_node_pool.min_count == null || var.default_node_pool.min_count >= 1
    error_message = "default_node_pool.min_count must be at least 1 when set."
  }

  validation {
    condition     = var.default_node_pool.max_count == null || var.default_node_pool.max_count >= 1
    error_message = "default_node_pool.max_count must be at least 1 when set."
  }

  validation {
    condition     = var.default_node_pool.os_disk_size_gb >= 30
    error_message = "default_node_pool.os_disk_size_gb must be at least 30 GB."
  }

  validation {
    condition     = var.default_node_pool.os_sku == null || contains(["AzureLinux", "AzureLinux3", "Ubuntu", "Ubuntu2204", "Ubuntu2404"], var.default_node_pool.os_sku)
    error_message = "default_node_pool.os_sku must be one of AzureLinux, AzureLinux3, Ubuntu, Ubuntu2204, or Ubuntu2404."
  }

  validation {
    condition     = var.node_autoscaling.mode != "cluster-autoscaler" || (var.default_node_pool.min_count != null && var.default_node_pool.max_count != null && var.default_node_pool.min_count <= var.default_node_pool.max_count)
    error_message = "default_node_pool.min_count and default_node_pool.max_count are required for cluster-autoscaler mode, and min_count must be less than or equal to max_count."
  }

  validation {
    condition     = var.node_autoscaling.mode == "cluster-autoscaler" || var.default_node_pool.node_count != null
    error_message = "default_node_pool.node_count is required when node_autoscaling.mode is node-auto-provisioning or none."
  }
}

variable "node_autoscaling" {
  description = "Cluster node autoscaling mode. Use cluster-autoscaler for managed node pool autoscaling, node-auto-provisioning for AKS NAP, or none for fixed pools only."
  type = object({
    mode = optional(string, "cluster-autoscaler")
    node_auto_provisioning = optional(object({
      default_node_pools = optional(string, "None")
    }), {})
    profile = optional(object({
      max_graceful_termination_sec     = optional(number, 14400)
      skip_nodes_with_local_storage    = optional(bool, false)
      expander                         = optional(string, "least-waste")
      scale_down_unneeded              = optional(string, "10m")
      scale_down_delay_after_delete    = optional(string, "120s")
      scale_down_utilization_threshold = optional(number, 0.6)
    }), {})
  })
  default = {
    mode = "cluster-autoscaler"
  }

  validation {
    condition     = contains(["cluster-autoscaler", "node-auto-provisioning", "none"], var.node_autoscaling.mode)
    error_message = "node_autoscaling.mode must be cluster-autoscaler, node-auto-provisioning, or none."
  }

  validation {
    condition     = contains(["Auto", "None"], var.node_autoscaling.node_auto_provisioning.default_node_pools)
    error_message = "node_autoscaling.node_auto_provisioning.default_node_pools must be Auto or None."
  }

  validation {
    condition     = contains(["least-waste", "random", "most-pods", "priority"], var.node_autoscaling.profile.expander)
    error_message = "node_autoscaling.profile.expander must be one of: least-waste, random, most-pods, priority."
  }

  validation {
    condition     = can(regex("^[0-9]+s$", var.node_autoscaling.profile.scale_down_delay_after_delete))
    error_message = "node_autoscaling.profile.scale_down_delay_after_delete must be in seconds format (e.g. \"120s\"). The Azure AKS API rejects minute-format values for this parameter — it uses the same unit as scan-interval."
  }

  validation {
    condition = !contains(["node-auto-provisioning", "none"], var.node_autoscaling.mode) ? true : alltrue([
      for k, v in var.node_pool_settings : v.auto_scaling_enabled == false
    ])
    error_message = "When node_autoscaling.mode is node-auto-provisioning or none, all node_pool_settings entries must have auto_scaling_enabled = false."
  }

  validation {
    condition = !contains(["node-auto-provisioning", "none"], var.node_autoscaling.mode) ? true : alltrue([
      for k, v in var.spot_node_pool_settings : v.auto_scaling_enabled == false
    ])
    error_message = "When node_autoscaling.mode is node-auto-provisioning or none, all spot_node_pool_settings entries must have auto_scaling_enabled = false."
  }

  validation {
    condition = !contains(["node-auto-provisioning", "none"], var.node_autoscaling.mode) ? true : alltrue([
      for k, v in var.kata_node_pool_settings : v.auto_scaling_enabled == false
    ])
    error_message = "When node_autoscaling.mode is node-auto-provisioning or none, all kata_node_pool_settings entries must have auto_scaling_enabled = false."
  }
}

variable "default_subnet_nodes_id" {
  description = "The ID of the subnet for nodes. Primarily used for the default node pool. For additional node pools, supply subnet settings in the node_pool_settings for more granular control."
  type        = string
}

variable "default_subnet_pods_id" {
  description = "The ID of the subnet for pods. Primarily used for the default node pool. If not provided, the node subnet will be used for pods. While this can be null for backwards compatibility, segregating pods and nodes into separate subnets is recommended for production environments. For additional node pools, supply subnet settings in the node_pool_settings for more granular control."
  type        = string
  default     = null
}

variable "segregated_node_and_pod_subnets_enabled" {
  description = "Some legacy or smaller clusters might not want to split nodes and pods into different subnets. Falsifying this will force the module to only use 1 subnet for both nodes and pods. It is not recommended for production use cases."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}

variable "log_analytics_workspace" {
  description = "The Log Analytics Workspace configuration for monitoring and logging."
  type = object({
    id                  = string
    location            = string
    resource_group_name = string
  })
  default  = null
  nullable = true
}

variable "application_gateway_id" {
  description = "The ID of the Application Gateway."
  type        = string
  default     = null
}

variable "azure_prometheus_grafana_monitor" {
  description = "Specifies a Prometheus-Grafana add-on profile for the Kubernetes Cluster."
  type = object({
    enabled                = bool
    azure_monitor_location = string
    azure_monitor_rg_name  = string
    grafana_major_version  = optional(number, 11)
    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
      }), {
      type = "SystemAssigned"
    })
  })
  default = {
    enabled                = false
    azure_monitor_location = "westeurope"
    grafana_major_version  = 11
    azure_monitor_rg_name  = "monitor-rg"
    identity = {
      type = "SystemAssigned"
    }
  }
}

variable "tenant_id" {
  description = "The tenant ID for the Azure subscription."
  type        = string
  validation {
    condition     = length(var.tenant_id) > 0
    error_message = "The tenant ID must not be empty."
  }

}

variable "retention_in_days" {
  description = "The retention period in days for the Log Analytics Workspace."
  type        = number
  default     = 30

  validation {
    condition     = var.retention_in_days >= 7
    error_message = "The retention period must be at least 7 days."
  }
}

variable "log_table_plan" {
  description = "The pricing tier for the Log Analytics Workspace Table."
  type        = string
  default     = "Basic"
}

# DEPRECATION NOTICE: The three variables below (`diagnostic_logs_categories`, `basic_log_tables`,
# `container_insights_streams`) are transitional. An upcoming major version will introduce a
# breaking refactor of the entire logging setup. These variables will be removed and replaced.

variable "diagnostic_logs_categories" {
  description = <<-EOT
    AKS diagnostic log categories to enable. Only categories present in the supported set are used.
    See https://learn.microsoft.com/en-gb/azure/aks/monitor-aks-reference#resource-logs

    DEPRECATED: Will be removed in the next major version as part of a breaking logging refactor.
  EOT
  type        = list(string)
  default     = null
}

variable "basic_log_tables" {
  description = <<-EOT
    Log Analytics workspace tables to configure with the specified log table plan.

    DEPRECATED: Will be removed in the next major version as part of a breaking logging refactor.
  EOT
  type        = list(string)
  default     = ["ContainerLogV2", "AKSControlPlane"]
}

variable "container_insights_streams" {
  description = <<-EOT
    Container Insights data collection streams. Defaults to the Group-Default stream.

    DEPRECATED: Will be removed in the next major version as part of a breaking logging refactor.
  EOT
  type        = list(string)
  default     = ["Microsoft-ContainerInsights-Group-Default"]
}

variable "node_pool_settings" {
  description = "The settings for the node pools. Note that if you specify a subnet_pods_id for one of the node pools, you must specify it for all node pools."
  type = map(object({
    vm_size                     = string
    min_count                   = optional(number)
    max_count                   = optional(number)
    max_pods                    = optional(number)
    os_disk_size_gb             = number
    os_sku                      = optional(string, "AzureLinux")
    os_type                     = optional(string, "Linux")
    node_labels                 = map(string)
    node_taints                 = list(string)
    auto_scaling_enabled        = bool
    mode                        = string
    zones                       = list(string)
    subnet_nodes_id             = optional(string, null)
    subnet_pods_id              = optional(string, null)
    temporary_name_for_rotation = optional(string, null)
    upgrade_settings = object({
      max_surge                     = string
      drain_timeout_in_minutes      = optional(number)
      node_soak_duration_in_minutes = optional(number)
      undrainable_node_behavior     = optional(string)
    })
  }))
  validation {
    condition = alltrue([
      for k, v in var.node_pool_settings :
      v.upgrade_settings.undrainable_node_behavior == null || contains(["Cordon", "Schedule"], coalesce(v.upgrade_settings.undrainable_node_behavior, "null"))
    ])
    error_message = "node_pool_settings.upgrade_settings.undrainable_node_behavior must be \"Cordon\", \"Schedule\", or null on every node pool."
  }
  default = {}
}

variable "spot_node_pool_settings" {
  description = <<-EOT
    Settings for spot instance node pools. Spot VMs offer unused Azure capacity at
    significant discounts but can be evicted at any time when Azure needs the capacity back.

    The following label and taint are automatically added to every spot pool:
      - Label: kubernetes.azure.com/scalesetpriority=spot
      - Taint: kubernetes.azure.com/scalesetpriority=spot:NoSchedule

    Workloads must tolerate the taint to be scheduled on spot nodes. To prefer spot
    but fall back to regular nodes, use a preferredDuringScheduling node affinity:

      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              preference:
                matchExpressions:
                  - key: kubernetes.azure.com/scalesetpriority
                    operator: In
                    values:
                      - spot
      tolerations:
        - key: kubernetes.azure.com/scalesetpriority
          operator: Equal
          value: spot
          effect: NoSchedule

    eviction_policy:
      - "Delete"      (default) - VM and its OS disk are deleted on eviction.
                        Nodes scale back via the autoscaler when capacity returns.
      - "Deallocate"  - VM is stopped and deallocated, keeping the OS disk.
                        Allows faster restart but incurs storage costs for the disk.

    spot_max_price:
      - -1            (default) - Caps at the current on-demand price for the VM SKU.
                        The VM is only evicted for capacity reasons, never for price.
      - positive value - Hard USD-per-hour ceiling (up to 5 decimal places).
                        The VM is evicted when the spot price exceeds this value.

    Spot pools can only run in "User" mode (not "System") and should not host
    workloads that cannot tolerate interruptions (e.g. stateful services without
    checkpointing, single-replica controllers).
  EOT
  type = map(object({
    vm_size                     = string
    min_count                   = optional(number)
    max_count                   = optional(number)
    max_pods                    = optional(number)
    os_disk_size_gb             = number
    os_sku                      = optional(string, "AzureLinux")
    os_type                     = optional(string, "Linux")
    node_labels                 = optional(map(string), {})
    node_taints                 = optional(list(string), [])
    auto_scaling_enabled        = bool
    mode                        = optional(string, "User")
    zones                       = list(string)
    subnet_nodes_id             = optional(string, null)
    subnet_pods_id              = optional(string, null)
    temporary_name_for_rotation = optional(string, null)
    eviction_policy             = optional(string, "Delete")
    spot_max_price              = optional(number, -1)
    upgrade_settings = object({
      max_surge                     = string
      drain_timeout_in_minutes      = optional(number)
      node_soak_duration_in_minutes = optional(number)
      undrainable_node_behavior     = optional(string)
    })
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.spot_node_pool_settings :
      contains(["Deallocate", "Delete"], v.eviction_policy)
    ])
    error_message = "eviction_policy must be either 'Deallocate' or 'Delete'."
  }

  validation {
    condition = alltrue([
      for k, v in var.spot_node_pool_settings :
      v.upgrade_settings.undrainable_node_behavior == null || contains(["Cordon", "Schedule"], coalesce(v.upgrade_settings.undrainable_node_behavior, "null"))
    ])
    error_message = "spot_node_pool_settings.upgrade_settings.undrainable_node_behavior must be \"Cordon\", \"Schedule\", or null on every spot node pool."
  }
}

variable "kata_node_pool_settings" {
  description = <<-EOT
    Settings for Kata Containers node pools with hardware-isolated VM workload runtime.
    Kata Containers provide strong isolation by running each container in a lightweight
    VM, offering an additional security boundary between containers and the host.

    The following label and taint are automatically added to every Kata pool:
      - Label: workload-runtime=kata
      - Taint: workload-runtime=kata:NoSchedule

    Workloads must tolerate the taint to be scheduled on Kata nodes. Use a RuntimeClass
    with handler 'kata' for pods that should run in Kata containers:

      apiVersion: node.k8s.io/v1
      kind: RuntimeClass
      metadata:
        name: kata
      handler: kata
      scheduling:
        nodeSelector:
          workload-runtime: kata
        tolerations:
          - key: workload-runtime
            operator: Equal
            value: kata
            effect: NoSchedule

    Note: Kata node pools require VM sizes that support nested virtualization.
    The azapi provider is used because azurerm doesn't yet support KataVmIsolation workload_runtime.
  EOT
  type = map(object({
    vm_size              = string
    min_count            = optional(number)
    max_count            = optional(number)
    max_pods             = optional(number)
    os_disk_size_gb      = number
    os_sku               = optional(string, "AzureLinux")
    os_type              = optional(string, "Linux")
    node_labels          = optional(map(string), {})
    node_taints          = optional(list(string), [])
    auto_scaling_enabled = bool
    mode                 = optional(string, "User")
    zones                = list(string)
    subnet_nodes_id      = optional(string, null)
    subnet_pods_id       = optional(string, null)
    upgrade_settings = object({
      max_surge                     = string
      drain_timeout_in_minutes      = optional(number)
      node_soak_duration_in_minutes = optional(number)
      undrainable_node_behavior     = optional(string)
    })
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.kata_node_pool_settings :
      v.upgrade_settings.undrainable_node_behavior == null || contains(["Cordon", "Schedule"], coalesce(v.upgrade_settings.undrainable_node_behavior, "null"))
    ])
    error_message = "kata_node_pool_settings.upgrade_settings.undrainable_node_behavior must be \"Cordon\", \"Schedule\", or null on every kata node pool."
  }
}

variable "monitoring_account_name" {
  description = "The name of the monitoring account"
  default     = "MonitoringAccount1"
  type        = string
  validation {
    condition     = length(var.monitoring_account_name) > 0
    error_message = "The monitoring account name must not be empty."
  }
}

variable "azure_policy_enabled" {
  description = "Specifies whether Azure Policy is enabled for the Kubernetes Cluster."
  type        = bool
  default     = true
}

variable "local_account_disabled" {
  description = "Specifies whether the local account is disabled for the Kubernetes Cluster."
  type        = bool
  default     = true
}

variable "oidc_issuer_enabled" {
  description = "The OIDC issuer URL for the Kubernetes Cluster."
  type        = bool
  default     = true
}

variable "workload_identity_enabled" {
  description = "Specifies whether workload identity is enabled for the Kubernetes Cluster."
  type        = bool
  default     = true
}

variable "private_cluster_enabled" {
  description = "Specifies whether the Kubernetes Cluster is private."
  type        = bool
  default     = true
}

variable "cost_analysis_enabled" {
  description = "Specifies whether cost analysis is enabled for the Kubernetes Cluster."
  type        = bool
  default     = true
}

variable "private_cluster_public_fqdn_enabled" {
  description = "Specifies whether the private cluster has a public FQDN."
  type        = bool
  default     = true
}

variable "sku_tier" {
  description = "The SKU tier for the Kubernetes Cluster."
  type        = string
  default     = "Standard"
}

variable "private_dns_zone_id" {
  description = "The ID of the private DNS zone."
  type        = string
  default     = "None"
}

variable "automatic_upgrade_channel" {
  description = "The automatic upgrade channel for the Kubernetes Cluster."
  type        = string
  default     = "stable"
}

variable "service_cidr" {
  description = "The service CIDR for the Kubernetes Cluster."
  type        = string
  default     = "172.20.0.0/16"
}

variable "dns_service_ip" {
  description = "The DNS service IP for the Kubernetes Cluster."
  type        = string
  default     = "172.20.0.10"
}

variable "admin_group_object_ids" {
  description = "The object IDs of the admin groups for the Kubernetes Cluster."
  type        = list(string)
  default     = []
}

//If network_profile is not defined this might lead to unexpected aks behavior.

variable "network_profile" {
  description = <<-EOT
    Network profile configuration for the AKS cluster.

    outbound_type:
      - "loadBalancer" (default) - Requires exactly one of managed_outbound_ip_count,
        outbound_ip_address_ids, or outbound_ip_prefix_ids. These are mutually exclusive.
      - "userDefinedRouting" - Uses custom routing rules; no outbound IP configuration needed.

    Cilium requirements:
      - network_data_plane = "cilium" requires network_plugin = "azure"
      - network_policy = "cilium" requires network_data_plane = "cilium"
      - advanced_networking_enabled requires network_data_plane = "cilium"
  EOT
  type = object({
    network_data_plane          = optional(string)
    network_plugin              = optional(string, "azure")
    network_plugin_mode         = optional(string, null)
    network_policy              = optional(string)
    service_cidr                = optional(string, "172.20.0.0/16")
    dns_service_ip              = optional(string, "172.20.0.10")
    outbound_type               = optional(string, "loadBalancer")
    managed_outbound_ip_count   = optional(number, null)
    outbound_ip_address_ids     = optional(list(string), null)
    outbound_ip_prefix_ids      = optional(list(string), null)
    idle_timeout_in_minutes     = optional(number, 30)
    advanced_networking_enabled = optional(bool, false)
  })
  default = {
    network_plugin = "azure"
  }

  validation {
    condition = var.network_profile == null ? true : (
      (var.network_profile.managed_outbound_ip_count != null ? 1 : 0) +
      (var.network_profile.outbound_ip_address_ids != null ? 1 : 0) +
      (var.network_profile.outbound_ip_prefix_ids != null ? 1 : 0) <= 1
    )
    error_message = "Only one of managed_outbound_ip_count, outbound_ip_address_ids, or outbound_ip_prefix_ids can be specified in the network profile."
  }

  validation {
    condition = var.network_profile == null ? true : (
      var.network_profile.outbound_type != "loadBalancer" ||
      var.network_profile.managed_outbound_ip_count != null ||
      var.network_profile.outbound_ip_address_ids != null ||
      var.network_profile.outbound_ip_prefix_ids != null
    )
    error_message = "When outbound_type is 'loadBalancer', one of managed_outbound_ip_count, outbound_ip_address_ids, or outbound_ip_prefix_ids must be specified."
  }
  validation {
    condition = var.network_profile == null ? true : (
      var.network_profile.network_data_plane != "cilium" ||
      var.network_profile.network_plugin == "azure"
    )
    error_message = "When network_data_plane is set to 'cilium', network_plugin must be set to 'azure'."
  }
  validation {
    condition = var.network_profile == null ? true : (
      var.network_profile.network_policy != "azure" ||
      var.network_profile.network_plugin == "azure"
    )
    error_message = "When network_policy is set to 'azure', network_plugin must be set to 'azure'."
  }
  validation {
    condition = var.network_profile == null ? true : (
      var.network_profile.network_policy != "cilium" ||
      var.network_profile.network_data_plane == "cilium"
    )
    error_message = "When network_policy is set to 'cilium', network_data_plane must be set to 'cilium'."
  }
  validation {
    condition = var.network_profile == null ? true : (
      !var.network_profile.advanced_networking_enabled ||
      var.network_profile.network_data_plane == "cilium"
    )
    error_message = "When advanced_networking_enabled is set to true, network_data_plane must be set to 'cilium'."
  }
}

variable "defender_log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace for Microsoft Defender"
  type        = string
  default     = null
}

variable "maintenance_window_auto_upgrade" {
  description = "The maintenance window for automatic upgrades of the Kubernetes cluster."
  type = object({
    frequency    = optional(string, "Weekly")
    interval     = optional(number, 2)
    duration     = optional(number, 6)
    day_of_week  = optional(string, "Sunday")
    day_of_month = optional(number, null)
    week_index   = optional(string, null)
    start_time   = optional(string, "18:00")
    utc_offset   = optional(string, "+00:00")
    start_date   = optional(string, null)
    not_allowed = optional(list(object({
      start = string
      end   = string
    })), [])
  })
  default = null
  validation {
    condition     = var.maintenance_window_auto_upgrade == null ? true : contains(local.maintenance_window_validations.valid_frequencies, var.maintenance_window_auto_upgrade.frequency)
    error_message = "Frequency must be one of: Daily, Weekly, AbsoluteMonthly, RelativeMonthly"
  }

  validation {
    condition     = var.maintenance_window_auto_upgrade == null ? true : var.maintenance_window_auto_upgrade.interval > 0
    error_message = "Interval must be a positive number"
  }

  validation {
    condition     = var.maintenance_window_auto_upgrade == null ? true : var.maintenance_window_auto_upgrade.duration >= 4 && var.maintenance_window_auto_upgrade.duration <= 24
    error_message = "Duration must be between 4 and 24 hours"
  }

  validation {
    condition = var.maintenance_window_auto_upgrade == null ? true : (
      var.maintenance_window_auto_upgrade.frequency != "Weekly" ||
      contains(local.maintenance_window_validations.valid_days_of_week, var.maintenance_window_auto_upgrade.day_of_week)
    )
    error_message = "When frequency is Weekly, day_of_week must be one of: Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday"
  }

  validation {
    condition = var.maintenance_window_auto_upgrade == null ? true : (
      var.maintenance_window_auto_upgrade.frequency != "AbsoluteMonthly" ||
      (
        var.maintenance_window_auto_upgrade.day_of_month == null ? false : (
          var.maintenance_window_auto_upgrade.day_of_month >= 0 &&
          var.maintenance_window_auto_upgrade.day_of_month <= 31
        )
      )
    )
    error_message = "When frequency is AbsoluteMonthly, day_of_month must be between 0 and 31"
  }

  validation {
    condition = var.maintenance_window_auto_upgrade == null ? true : (
      var.maintenance_window_auto_upgrade.frequency != "RelativeMonthly" ||
      (var.maintenance_window_auto_upgrade.week_index == null ? false : contains(local.maintenance_window_validations.valid_week_indexes, var.maintenance_window_auto_upgrade.week_index))
    )
    error_message = "When frequency is RelativeMonthly, week_index must be one of: First, Second, Third, Fourth, Last"
  }

  validation {
    condition = var.maintenance_window_auto_upgrade == null ? true : (
      var.maintenance_window_auto_upgrade.start_time != null ||
      can(regex(local.maintenance_window_validations.time_format_regex, var.maintenance_window_auto_upgrade.start_time))
    )
    error_message = "start_time must be in HH:mm format"
  }

  validation {
    condition = var.maintenance_window_auto_upgrade == null ? true : (
      var.maintenance_window_auto_upgrade.utc_offset != null ||
      can(regex(local.maintenance_window_validations.utc_offset_regex, var.maintenance_window_auto_upgrade.utc_offset))
    )
    error_message = "utc_offset must be in +/-HH:mm format"
  }
}

variable "maintenance_window_node_os" {
  description = "The maintenance window for node OS upgrades of the Kubernetes cluster."
  type = object({
    frequency    = optional(string, "Weekly")
    interval     = optional(number, 1)
    duration     = optional(number, 6)
    day_of_week  = optional(string, "Sunday")
    day_of_month = optional(number, null)
    week_index   = optional(string, null)
    start_time   = optional(string, "00:00")
    utc_offset   = optional(string, "+00:00")
    start_date   = optional(string, null)
    not_allowed = optional(list(object({
      start = string
      end   = string
    })), [])
  })
  default = null
  validation {
    condition     = var.maintenance_window_node_os == null ? true : contains(local.maintenance_window_validations.valid_frequencies, var.maintenance_window_node_os.frequency)
    error_message = "Frequency must be one of: Daily, Weekly, AbsoluteMonthly, RelativeMonthly"
  }

  validation {
    condition     = var.maintenance_window_node_os == null ? true : var.maintenance_window_node_os.interval > 0
    error_message = "Interval must be a positive number"
  }

  validation {
    condition     = var.maintenance_window_node_os == null ? true : var.maintenance_window_node_os.duration >= 4 && var.maintenance_window_node_os.duration <= 24
    error_message = "Duration must be between 4 and 24 hours"
  }

  validation {
    condition = var.maintenance_window_node_os == null ? true : (
      var.maintenance_window_node_os.frequency != "Weekly" ||
      contains(local.maintenance_window_validations.valid_days_of_week, var.maintenance_window_node_os.day_of_week)
    )
    error_message = "When frequency is Weekly, day_of_week must be one of: Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday"
  }

  validation {
    condition = var.maintenance_window_node_os == null ? true : (
      var.maintenance_window_node_os.frequency != "AbsoluteMonthly" ||
      (
        var.maintenance_window_node_os.day_of_month == null ? false : (
          var.maintenance_window_node_os.day_of_month >= 0 &&
          var.maintenance_window_node_os.day_of_month <= 31
        )
      )
    )
    error_message = "When frequency is AbsoluteMonthly, day_of_month must be between 0 and 31"
  }

  validation {
    condition = var.maintenance_window_node_os == null ? true : (
      var.maintenance_window_node_os.frequency != "RelativeMonthly" ||
      (var.maintenance_window_node_os.week_index == null ? false : contains(local.maintenance_window_validations.valid_week_indexes, var.maintenance_window_node_os.week_index))
    )
    error_message = "When frequency is RelativeMonthly, week_index must be one of: First, Second, Third, Fourth, Last"
  }

  validation {
    condition = var.maintenance_window_node_os == null ? true : (
      var.maintenance_window_node_os.start_time != null ||
      can(regex(local.maintenance_window_validations.time_format_regex, var.maintenance_window_node_os.start_time))
    )
    error_message = "start_time must be in HH:mm format"
  }

  validation {
    condition = var.maintenance_window_node_os == null ? true : (
      var.maintenance_window_node_os.utc_offset != null ||
      can(regex(local.maintenance_window_validations.utc_offset_regex, var.maintenance_window_node_os.utc_offset))
    )
    error_message = "utc_offset must be in +/-HH:mm format"
  }
}

variable "node_os_upgrade_channel" {
  description = "The upgrade channel for the node OS image. Possible values are Unmanaged, SecurityPatch, NodeImage, None."
  type        = string
  default     = "NodeImage"

  validation {
    condition     = contains(["Unmanaged", "SecurityPatch", "NodeImage", "None"], var.node_os_upgrade_channel)
    error_message = "node_os_upgrade_channel must be one of: Unmanaged, SecurityPatch, NodeImage, None"
  }
}

variable "upgrade_override" {
  description = "Override settings for AKS cluster upgrades. Forces upgrades past safeguards. Once set, this block cannot be removed from the configuration. effective_until is required due to azurerm provider bug #28960."
  type = object({
    force_upgrade_enabled = bool
    effective_until       = string
  })
  default = null

  validation {
    condition = var.upgrade_override == null ? true : (
      can(regex("^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z$", var.upgrade_override.effective_until))
    )
    error_message = "effective_until is required (azurerm provider bug #28960 sends empty string for null) and must be in RFC 3339 format (e.g. 2025-10-01T13:00:00Z)."
  }
}

variable "alert_configuration" {
  description = "Configuration for AKS alerts and monitoring"
  type = object({
    email_receiver = optional(object({
      email_address = string
      name          = optional(string, "aks-alerts-email")
    }), null)
    action_group = optional(object({
      short_name = optional(string, "aks-alerts")
      location   = optional(string, "germanywestcentral")
    }), null)
  })
  default = null
}

variable "alerts" {
  description = "Map of alerts to create for the AKS cluster. Supports both activity log alerts and metric alerts. Set to {} to disable all default alerts. The alert type is determined by which criteria block is specified (activity_log_criteria or metric_criteria)."
  type = map(object({
    name        = string
    description = optional(string, "")
    enabled     = optional(bool, true)

    # For metric alerts only
    severity    = optional(number, 3)
    frequency   = optional(string, "PT5M")
    window_size = optional(string, "PT15M")

    # Activity log alert criteria (mutually exclusive with metric_criteria)
    activity_log_criteria = optional(object({
      operation_name = string
      category       = string
      levels         = optional(list(string), ["Error"])
      statuses       = optional(list(string), ["Failed"])
    }))

    # Metric alert criteria (mutually exclusive with activity_log_criteria)
    metric_criteria = optional(object({
      metric_namespace       = optional(string, "Microsoft.ContainerService/managedClusters")
      metric_name            = string
      aggregation            = string
      operator               = string
      threshold              = number
      skip_metric_validation = optional(bool, false)
      dimension = optional(list(object({
        name     = string
        operator = string # Include, Exclude, StartsWith
        values   = list(string)
      })), [])
    }))

    actions = optional(list(object({
      action_group_id    = string
      webhook_properties = optional(map(string), {})
    })))
  }))
  default = {
    aks_agent_pool_write_error = {
      name        = "AKS Agent Pool Write Error"
      description = "Alerts when agent pool write operations fail"
      enabled     = true
      activity_log_criteria = {
        operation_name = "Microsoft.ContainerService/managedClusters/agentpools/write"
        category       = "Administrative"
        levels         = ["Error"]
        statuses       = ["Failed"]
      }
    }
  }

  validation {
    condition = alltrue([
      for k, v in var.alerts :
      (v.activity_log_criteria != null) != (v.metric_criteria != null)
    ])
    error_message = "Each alert must specify exactly one of activity_log_criteria or metric_criteria, not both or neither."
  }
}

variable "default_action_group_ids" {
  description = "List of action group IDs to use for alerts that don't have explicit actions defined. Required to receive alert notifications."
  type        = list(string)
  validation {
    condition     = var.default_action_group_ids == null || length(var.default_action_group_ids) > 0
    error_message = "At least one action group ID must be provided to receive alert notifications. If you don't want to use any action groups, set default_action_group_ids to null."
  }
}

