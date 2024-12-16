variable "name" {
  type        = string
  description = "The name of the PostgreSQL server resource."
  validation {
    condition     = length(var.name) > 0
    error_message = "name must not be empty."
  }
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the resources will be created."
  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "Resource group name must not be empty."
  }
}

variable "location" {
  type        = string
  description = "The location where the resources will be deployed."
  validation {
    condition     = length(var.location) > 0
    error_message = "Location must not be empty."
  }
}

variable "flex_pg_version" {
  description = "The version of the PostgreSQL server."
  type        = string
  default     = "14"
  validation {
    condition     = length(var.flex_pg_version) > 0
    error_message = "PostgreSQL version must not be empty."
  }
}

variable "flex_sku" {
  description = "The SKU for the PostgreSQL server."
  type        = string
  default     = "GP_Standard_D2ds_v5"
  validation {
    condition     = length(var.flex_sku) > 0
    error_message = "PostgreSQL SKU must not be empty."
  }
}

variable "flex_storage_mb" {
  description = "The storage size in MB for the PostgreSQL server."
  type        = number
  default     = 32768
  validation {
    condition     = var.flex_storage_mb > 0
    error_message = "Storage size must be greater than 0."
  }
}

variable "flex_pg_backup_retention_days" {
  description = "The number of days to retain backups for the PostgreSQL server."
  type        = number
  default     = 7
  validation {
    condition     = var.flex_pg_backup_retention_days >= 0
    error_message = "Backup retention days must be greater than or equal to 0."
  }
}

variable "parameter_values" {
  type        = map(string)
  description = "values for the server configuration parameters"
  default = {
    max_connections    = "400"
    "azure.extensions" = "PG_STAT_STATEMENTS,PG_TRGM"
    enable_seqscan     = "off",
  }
}

variable "delegated_subnet_id" {
  type        = string
  description = "The ID of the delegated subnet."
  default     = null
}

variable "private_dns_zone_id" {
  type        = string
  description = "The ID of the private DNS zone."
  default     = null
}

variable "identity_ids" {
  description = "List of managed identity IDs to assign to the storage account."
  type        = list(string)
  default     = []
  nullable    = false
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

variable "customer_managed_key" {
  description = "Customer managed key properties for the storage account. Refer to the readme for more information on what is needed to enable customer-managed key encryption. It is recommended to not use key_version unless you have a specific reason to do so as leaving it out will allow automatic key rotation. The key_vault_id must be accessible to the user_assigned_identity_id."
  type = object({
    key_vault_key_id          = string
    user_assigned_identity_id = string
  })
  default  = null
  nullable = true
}

variable "tags" {
  description = "Tags for the resources."
  type        = map(string)
  default     = {}
}

variable "databases" {
  description = "Map of databases and its properties"
  type = map(
    object({
      name      = string
      collation = optional(string, null)
      charset   = optional(string, null)
      lifecycle = optional(bool, false)
    })
  )
  default = {}
}

variable "timeouts" {
  description = "Timeout properties of the database"
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(object({
    }), null)
  })

  default = {
    update = "30m"
  }
  nullable = true
}

variable "public_network_access_enabled" {
  description = "Specifies whether this PostgreSQL Flexible Server is publicly accessible. Defaults to false"
  type        = string
  default     = false
}

variable "zone" {
  description = "(Optional) Specifies the Availability Zone in which the PostgreSQL Flexible Server should be located."
  type        = string
  default     = null
  nullable    = true
}

variable "administrator_login" {
  description = "The Administrator login for the PostgreSQL Flexible Server"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "The Password associated with the administrator_login for the PostgreSQL Flexible Server"
  type        = string
  sensitive   = true
}
