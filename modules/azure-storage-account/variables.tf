variable "name" {
  description = "Name of the storage account."
  type        = string
  nullable    = false
}

variable "location" {
  description = "Location of the resources."
  type        = string
  nullable    = false
}

variable "resource_group_name" {
  description = "Name of the resource group to put the resources in."
  type        = string
  nullable    = false
}

variable "tags" {
  description = "Tags for the resources."
  type        = map(string)
  default     = {}
}

variable "min_tls_version" {
  description = "Minimum TLS version supported by the storage account."
  type        = string
  default     = "TLS1_2"
}

variable "account_tier" {
  description = "Tier to use for the storage account. Learn more about storage account tiers in the Azure Docs."
  default     = "Standard"
}

variable "account_kind" {
  description = "Kind to use for the storage account. Learn more about storage account kinds in the Azure Docs."
  default     = "StorageV2"
}

variable "account_replication_type" {
  description = "Type of replication to use for this storage account. Learn more about storage account replication types in the Azure Docs."
  default     = "LRS"
  type        = string
  nullable    = false
}

variable "access_tier" {
  description = "Type of replication to use for this storage account. Learn more about storage account access tiers in the Azure Docs. Defaults to Cool as the difference is negligible for most use cases but is more cost-efficient."
  default     = "Cool"
  type        = string
  nullable    = false
}

variable "is_nfs_mountable" {
  description = "Enable NFSv3 and HNS protocol for the storage account in order to be mounted to AKS/nodes. In order to enable this, the account_tier and the account_kind must be set to a limited subset, refer to the Azure Docs(https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#is_hns_enabled-1) for more information."
  type        = bool
  default     = false
}

variable "identity_ids" {
  description = "List of managed identity IDs to assign to the storage account."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "cors_rules" {
  description = "CORS rules for the storage account"
  type = list(object({
    allowed_origins    = list(string)
    allowed_methods    = list(string)
    allowed_headers    = list(string)
    exposed_headers    = list(string)
    max_age_in_seconds = number
  }))
  default = []
}

variable "customer_managed_key" {
  description = "Customer managed key properties for the storage account. Refer to the readme for more information on what is needed to enable customer-managed key encryption. It is recommended to not use key_version unless you have a specific reason to do so as leaving it out will allow automatic key rotation. The key_vault_id must be accessible to the user_assigned_identity_id."
  type = object({
    key_name                  = string
    key_vault_id              = string
    key_version               = optional(string, null)
    user_assigned_identity_id = string
  })
  default  = null
  nullable = true
}

variable "deleted_retain_days" {
  description = "Number of days to retain deleted blobs."
  type        = number
  default     = 7
}

variable "container_deleted_retain_days" {
  description = "Number of days to retain deleted containers."
  type        = number
  default     = 7
}

variable "storage_management_policy_default" {
  description = "A simple abstraction of the most common properties for storage management lifecycle policies. If the simple implementation does not meet your needs, please open an issue. If you use this module to safe files that are rarely to never accessed again, opt for a very aggressive policy (starting already cool and archiving early). If you want to implement your own storage management policy, disable the default and use the output storage_account_id to implement your own policies."
  type = object({
    enabled                                  = optional(bool, true)
    blob_to_cool_after_last_modified_days    = optional(number, 10)
    blob_to_cold_after_last_modified_days    = optional(number, 50)
    blob_to_archive_after_last_modified_days = optional(number, 100)
    blob_to_deleted_after_last_modified_days = optional(number, 730)
  })
  default = {
    enabled                                  = true
    blob_to_cool_after_last_modified_days    = 10
    blob_to_cold_after_last_modified_days    = 50
    blob_to_archive_after_last_modified_days = 100
    blob_to_deleted_after_last_modified_days = 730
  }
  nullable = false
}

variable "containers" {
  description = "Map of containers to create in the storage account where the key is the name."
  type = map(object({
    access_type = optional(string, "private")
  }))
  default = {}
}

variable "network_rules" {
  description = "Generally network rules should be managed outside this module, but when using `is_nfs_mountable` then a `network_rules` variable is required as Azure does not allow the creation of such accounts without `Deny`ing traffic from creation."
  type = object({
    virtual_network_subnet_ids = list(string)
    ip_rules                   = list(string)
    bypass                     = optional(list(string), ["Metrics", "Logging", "AzureServices"])
    private_link_accesses = list(object({
      endpoint_resource_id = string
      endpoint_tenant_id   = string
    }))
  })
  default  = null
  nullable = true
}

variable "self_cmk" {
  description = "Details for the self customer managed key."
  type = object({
    key_name                  = string
    key_vault_id              = string
    key_type                  = optional(string, "RSA-HSM")
    key_size                  = optional(number, 2048)
    key_opts                  = optional(list(string), ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"])
    user_assigned_identity_id = string

  })
  default  = null
  nullable = true
}

variable "connection_settings" {
  description = "Object containing the connection strings and the Key Vault secret ID where the connection strings will be stored"
  type = object({
    connection_string_1 = string
    connection_string_2 = string
    key_vault_id        = string
    expiration_date     = optional(string, "2099-12-31T23:59:59Z")
  })
  default  = null
  nullable = true
}

variable "private_endpoint" {
  description = "Configuration for private endpoint"
  type = object({
    subnet_id                       = string
    private_dns_zone_id             = string
    resource_group_name             = string
    location                        = optional(string)
    private_service_connection_name = optional(string)
    is_manual_connection            = optional(bool, false)
    subresource_names               = optional(list(string), ["blob"])
    tags                            = optional(map(string), {})
  })
  default  = null
  nullable = true

  validation {
    condition = var.private_endpoint == null ? true : alltrue([
      for subresource in var.private_endpoint.subresource_names : contains(
        ["blob", "table", "queue", "file", "web", "dfs"], subresource
      )
    ])
    error_message = "Storage account private endpoint subresource_names must be one or more of: blob, table, queue, file, web, dfs"
  }
  validation {
    condition = var.private_endpoint == null ? true : (
      can(regex("^/subscriptions/[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/resourceGroups/[^/]+/providers/Microsoft.Network/virtualNetworks/[^/]+/subnets/[^/]+$", var.private_endpoint.subnet_id))
    )
    error_message = "The subnet_id must be a valid Azure resource ID for a subnet"
  }
  validation {
    condition = var.private_endpoint == null ? true : (
      can(regex("^/subscriptions/[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/resourceGroups/[^/]+/providers/Microsoft.Network/privateDnsZones/[^/]+$", var.private_endpoint.private_dns_zone_id))
    )
    error_message = "The private_dns_zone_id must be a valid Azure resource ID for a private DNS zone"
  }
}

variable "network_security_group" {
  description = "Configuration for network security group. Set to null to skip NSG creation."
  type = object({
    name                = optional(string)
    location            = optional(string)
    resource_group_name = optional(string)
    tags                = optional(map(string), {})
    security_rules = optional(list(object({
      name                         = string
      priority                     = number
      direction                    = string
      access                       = string
      protocol                     = string
      source_port_range            = optional(string)
      source_port_ranges           = optional(list(string))
      destination_port_range       = optional(string)
      destination_port_ranges      = optional(list(string))
      source_address_prefix        = optional(string)
      source_address_prefixes      = optional(list(string))
      destination_address_prefix   = optional(string)
      destination_address_prefixes = optional(list(string))
    })), [])
  })
  default  = null
  nullable = true

  validation {
    condition = var.network_security_group == null ? true : alltrue([
      for rule in var.network_security_group.security_rules : contains(
        ["Inbound", "Outbound"], rule.direction
      )
    ])
    error_message = "Security rule direction must be either 'Inbound' or 'Outbound'"
  }
  validation {
    condition = var.network_security_group == null ? true : alltrue([
      for rule in var.network_security_group.security_rules : contains(
        ["Allow", "Deny"], rule.access
      )
    ])
    error_message = "Security rule access must be either 'Allow' or 'Deny'"
  }
  validation {
    condition = var.network_security_group == null ? true : alltrue([
      for rule in var.network_security_group.security_rules : (
        (rule.source_port_range != null && rule.source_port_ranges == null) ||
        (rule.source_port_range == null && rule.source_port_ranges != null) ||
        (rule.source_port_range == null && rule.source_port_ranges == null)
      )
    ])
    error_message = "source_port_range and source_port_ranges are mutually exclusive. Specify only one of them."
  }
  validation {
    condition = var.network_security_group == null ? true : alltrue([
      for rule in var.network_security_group.security_rules : (
        (rule.destination_port_range != null && rule.destination_port_ranges == null) ||
        (rule.destination_port_range == null && rule.destination_port_ranges != null) ||
        (rule.destination_port_range == null && rule.destination_port_ranges == null)
      )
    ])
    error_message = "destination_port_range and destination_port_ranges are mutually exclusive. Specify only one of them."
  }
  validation {
    condition = var.network_security_group == null ? true : alltrue([
      for rule in var.network_security_group.security_rules : (
        (rule.source_address_prefix != null && rule.source_address_prefixes == null) ||
        (rule.source_address_prefix == null && rule.source_address_prefixes != null) ||
        (rule.source_address_prefix == null && rule.source_address_prefixes == null)
      )
    ])
    error_message = "source_address_prefix and source_address_prefixes are mutually exclusive. Specify only one of them."
  }
  validation {
    condition = var.network_security_group == null ? true : alltrue([
      for rule in var.network_security_group.security_rules : (
        (rule.destination_address_prefix != null && rule.destination_address_prefixes == null) ||
        (rule.destination_address_prefix == null && rule.destination_address_prefixes != null) ||
        (rule.destination_address_prefix == null && rule.destination_address_prefixes == null)
      )
    ])
    error_message = "destination_address_prefix and destination_address_prefixes are mutually exclusive. Specify only one of them."
  }
}
