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

variable "kubernetes_default_node_size" {
  description = "The size of the default node pool VMs."
  type        = string
  default     = "Standard_D2s_v5"

  validation {
    condition     = length(var.kubernetes_default_node_size) > 0
    error_message = "The default node size must not be empty."
  }
}

variable "kubernetes_default_node_count_min" {
  description = "The minimum number of nodes in the default node pool."
  type        = number
  default     = 2

  validation {
    condition     = var.kubernetes_default_node_count_min >= 1
    error_message = "The minimum node count must be at least 1."
  }
}

variable "kubernetes_default_node_count_max" {
  description = "The maximum number of nodes in the default node pool."
  type        = number
  default     = 5

  validation {
    condition     = var.kubernetes_default_node_count_max >= 1
    error_message = "The maximum node count must be at least one."
  }
}

variable "kubernetes_default_node_os_disk_size" {
  description = "The OS disk size in GB for default node pool VMs."
  type        = number
  default     = 100

  validation {
    condition     = var.kubernetes_default_node_os_disk_size >= 30
    error_message = "The OS disk size must be at least 30 GB."
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
    grafana_major_version  = optional(number, 10)
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
      max_surge = string
    })
  }))
  default = {
    stable = {
      vm_size         = "Standard_D8s_v5"
      node_count      = 1
      min_count       = 2
      max_count       = 10
      os_disk_size_gb = 100
      os_sku          = "AzureLinux"
      node_labels = {
        pool = "stable"
      }
      node_taints                 = []
      auto_scaling_enabled        = true
      mode                        = "User"
      zones                       = ["1", "3"]
      temporary_name_for_rotation = "stablerepl"
      upgrade_settings = {
        max_surge = "10%"
      }
    }
    burst = {
      vm_size         = "Standard_D8s_v5"
      node_count      = 0
      min_count       = 0
      max_count       = 10
      os_disk_size_gb = 100
      node_labels = {
        pool = "burst"
      }
      node_taints                 = ["burst=true:NoSchedule"]
      auto_scaling_enabled        = true
      mode                        = "User"
      zones                       = ["1", "3"]
      temporary_name_for_rotation = "burstrepl"
      upgrade_settings = {
        max_surge = "10%"
      }
    }
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

variable "kubernetes_default_node_zones" {
  description = "The availability zones for the default node pool."
  type        = list(string)
  default     = ["1", "3"]
}

variable "admin_group_object_ids" {
  description = "The object IDs of the admin groups for the Kubernetes Cluster."
  type        = list(string)
  default     = []
}

//If network_profile is not defined this might lead to unexpected aks behavior.

variable "network_profile" {
  description = "Network profile configuration for the AKS cluster. Note: managed_outbound_ip_count, outbound_ip_address_ids, and outbound_ip_prefix_ids are mutually exclusive."
  type = object({
    network_data_plane        = optional(string)
    network_plugin            = optional(string, "azure")
    network_plugin_mode       = optional(string, null)
    network_policy            = optional(string)
    service_cidr              = optional(string, "172.20.0.0/16")
    dns_service_ip            = optional(string, "172.20.0.10")
    outbound_type             = optional(string, "loadBalancer")
    managed_outbound_ip_count = optional(number, null)
    outbound_ip_address_ids   = optional(list(string), null)
    outbound_ip_prefix_ids    = optional(list(string), null)
    idle_timeout_in_minutes   = optional(number, 30)
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
