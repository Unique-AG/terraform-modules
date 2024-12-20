variable "cluster_name" {
  description = "The name of the Kubernetes cluster."
  type        = string
  default     = "test-cluster"

  validation {
    condition     = length(var.cluster_name) > 0
    error_message = "The cluster name must not be empty."
  }
}

variable "resource_group_location" {
  description = "The location of the resource group."
  type        = string
  default     = "eastus"

  validation {
    condition     = length(var.resource_group_location) > 0
    error_message = "The resource group location must not be empty."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
  default     = "test-rg"

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "The resource group name must not be empty."
  }
}

variable "kubernetes_version" {
  description = "The Kubernetes version to use for the AKS cluster."
  type        = string
  default     = "1.30.0"

  validation {
    condition     = length(var.kubernetes_version) > 0
    error_message = "The Kubernetes version must not be empty."
  }
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
  default     = "node-rg"

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

variable "subnet_nodes_id" {
  description = "The ID of the subnet for nodes."
  type        = string
  default     = "/subscriptions/<subscription-id>/resourceGroups/<rg-name>/providers/Microsoft.Network/virtualNetworks/<vnet-name>/subnets/<subnet-name>"

  validation {
    condition     = length(var.subnet_nodes_id) > 0
    error_message = "The subnet ID for nodes must not be empty."
  }
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default = {
    environment = "test"
    cost_center = "12345"
  }

  validation {
    condition     = length(var.tags) > 0
    error_message = "The tags map must not be empty."
  }
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace."
  type        = string
  default     = null

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
    azure_monitor_location = optional(string, "westeurope")
    azure_monitor_rg_name  = string
    grafana_major_version  = optional(number, 10)
  })
  default = {
    enabled                = false
    azure_monitor_location = "westeurope"
    grafana_major_version  = 10
    azure_monitor_rg_name  = "monitor-rg"
  }
}

variable "tenant_id" {
  description = "The tenant ID for the Azure subscription."
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"

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
  type = map(object({
    vm_size              = string
    node_count           = number
    min_count            = number
    max_count            = number
    os_disk_size_gb      = number
    os_sku               = optional(string, "Ubuntu")
    os_type              = optional(string, "Linux")
    node_labels          = map(string)
    node_taints          = list(string)
    auto_scaling_enabled = bool
    mode                 = string
    zones                = list(string)
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
      node_taints          = []
      auto_scaling_enabled = true
      mode                 = "User"
      zones                = ["1", "2", "3"]
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
      node_taints          = ["burst=true:NoSchedule"]
      auto_scaling_enabled = true
      mode                 = "User"
      zones                = ["1", "2", "3"]
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

variable "outbound_ip_address_ids" {
  description = "The IDs of the public IP addresses for outbound traffic."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.outbound_ip_address_ids) > 0
    error_message = "The outbound IP address IDs must not be empty."
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
  validation {
    condition     = contains("Free", "Premium", var.sku_tier)
    error_message = "The SKU tier must be either Free, Standard or Paid."
  }
}

variable "private_dns_zone_id" {
  description = "The ID of the private DNS zone."
  type        = string
  default     = "none"
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
