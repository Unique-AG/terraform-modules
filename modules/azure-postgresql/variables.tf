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

variable "postgresql_server_tags" {
  description = "Additional tags that apply only to the PostgreSQL server. These will be merged with the general tags variable."
  type        = map(string)
  default     = {}
}

variable "databases" {
  description = "Map of databases and its properties"
  type = map(
    object({
      name            = string
      collation       = optional(string, null)
      charset         = optional(string, null)
      lifecycle       = optional(bool, false)
      prevent_destroy = optional(bool, true)
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
    delete = optional(string)
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

variable "key_vault_id" {
  description = "The ID of the Key Vault where the secrets will be stored"
  default     = null
  type        = string
}

variable "host_secret_name" {
  description = "Name of the secret containing the host"
  default     = null
  type        = string
}

variable "port_secret_name" {
  description = "Name of the secret containing the port"
  default     = null
  type        = string
}

variable "username_secret_name" {
  description = "Name of the secret containing the admin username"
  default     = null
  type        = string
}

variable "password_secret_name" {
  description = "Name of the secret containing the admin password"
  default     = null
  type        = string
}
variable "database_connection_string_secret_prefix" {
  description = "Prefix of the secret containing the full connection string. The full name of the secret is this prefix + database name"
  default     = "database-url-"
  type        = string
}

variable "auto_grow_enabled" {
  description = "Specifies whether the PostgreSQL Flexible Server should be automatically grow the storage."
  type        = string
  default     = true
}

variable "metric_alerts" {
  description = "Map of metric alerts to create for the PostgreSQL server. By default, includes CPU (>80% for 30min) and memory (>90% for 1h) alerts. Set to {} to disable all default alerts."
  type = map(object({
    name                     = string
    description              = optional(string, "")
    severity                 = optional(number, 3)
    frequency                = optional(string, "PT5M")
    window_size              = optional(string, "PT15M")
    enabled                  = optional(bool, true)
    auto_mitigate            = optional(bool, true)
    target_resource_type     = optional(string, null)
    target_resource_location = optional(string, null)

    # Static criteria (one of criteria, dynamic_criteria, or application_insights_web_test_location_availability_criteria must be specified)
    criteria = optional(object({
      metric_namespace       = optional(string, "Microsoft.DBforPostgreSQL/flexibleServers")
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

    # Dynamic criteria (alternative to static criteria)
    dynamic_criteria = optional(object({
      metric_namespace         = optional(string, "Microsoft.DBforPostgreSQL/flexibleServers")
      metric_name              = string
      aggregation              = string
      operator                 = string
      alert_sensitivity        = optional(string, "Medium")
      evaluation_total_count   = optional(number, 4)
      evaluation_failure_count = optional(number, 4)
      ignore_data_before       = optional(string, null)
      skip_metric_validation   = optional(bool, false)
      dimension = optional(list(object({
        name     = string
        operator = string # Include, Exclude, StartsWith
        values   = list(string)
      })), [])
    }))

    # Application Insights web test location availability criteria (alternative to other criteria types)
    application_insights_web_test_location_availability_criteria = optional(object({
      web_test_id           = string
      component_id          = string
      failed_location_count = number
    }))

    # Actions configuration
    actions = optional(list(object({
      action_group_id    = string
      webhook_properties = optional(map(string), {})
    })), [])

    # Backward compatibility - will be deprecated in favor of actions
    action_group_ids = optional(list(string), [])
  }))
  default = {
    default_cpu_alert = {
      name        = "PostgreSQL High CPU Usage"
      description = "Alert when CPU usage is above 80% for more than 30 minutes"
      severity    = 2
      frequency   = "PT5M"
      window_size = "PT30M"
      enabled     = true
      criteria = {
        metric_name = "cpu_percent"
        aggregation = "Average"
        operator    = "GreaterThan"
        threshold   = 80
      }
    }

    default_memory_alert = {
      name        = "PostgreSQL High Memory Usage"
      description = "Alert when memory usage is above 90% for more than 1 hour"
      severity    = 1
      frequency   = "PT15M"
      window_size = "PT1H"
      enabled     = true
      criteria = {
        metric_name = "memory_percent"
        aggregation = "Average"
        operator    = "GreaterThan"
        threshold   = 90
      }
    }

    default_absence_alert = {
      name        = "PostgreSQL Heartbeat Absent"
      description = "Alert when Database Is Alive metric drops to 0."
      severity    = 1
      frequency   = "PT5M"
      window_size = "PT1H"
      enabled     = true
      criteria = {
        metric_name = "is_db_alive"
        aggregation = "Maximum"
        operator    = "LessThan"
        threshold   = 1
      }
    }
  }

  validation {
    condition = alltrue([
      for k, v in var.metric_alerts :
      (v.criteria != null && v.dynamic_criteria == null && v.application_insights_web_test_location_availability_criteria == null) ||
      (v.criteria == null && v.dynamic_criteria != null && v.application_insights_web_test_location_availability_criteria == null) ||
      (v.criteria == null && v.dynamic_criteria == null && v.application_insights_web_test_location_availability_criteria != null)
    ])
    error_message = "Each metric alert must specify exactly one of 'criteria', 'dynamic_criteria', or 'application_insights_web_test_location_availability_criteria'."
  }

  validation {
    condition = alltrue([
      for k, v in var.metric_alerts :
      contains([0, 1, 2, 3, 4], v.severity)
    ])
    error_message = "Severity must be one of: 0 (Critical), 1 (Error), 2 (Warning), 3 (Informational), 4 (Verbose)."
  }

  validation {
    condition = alltrue([
      for k, v in var.metric_alerts :
      contains(["PT1M", "PT5M", "PT15M", "PT30M", "PT1H"], v.frequency)
    ])
    error_message = "Frequency must be one of: PT1M, PT5M, PT15M, PT30M, PT1H."
  }

  validation {
    condition = alltrue([
      for k, v in var.metric_alerts :
      contains(["PT1M", "PT5M", "PT15M", "PT30M", "PT1H", "PT6H", "PT12H", "P1D"], v.window_size)
    ])
    error_message = "Window size must be one of: PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H, P1D and must be greater than frequency."
  }
}

variable "metric_alerts_external_action_group_ids" {
  description = "List of external Action Group IDs to apply to all metric alerts that do not explicitly define actions or action_group_ids. If an alert defines actions or action_group_ids, those take precedence."
  type        = list(string)
}

variable "management_lock" {
  description = "Management lock properties for the PostgreSQL server. Once created, the lock can't be destroyed by code, only manually via the Portal or other manual, PIM-enabled, means. Null disables the lock."
  type = object({
    name  = optional(string)
    notes = optional(string)
  })
  default = {
    name  = "TerraformModuleLock-CanNotDelete"
    notes = "Lock from the terraform module that prevents deletion of the Database Server. The lock, once created, can't be destroyed by the module itself with terraform, only manually via the Portal or other manual, PIM-enabled, means."
  }

  validation {
    condition     = var.management_lock == null || (var.management_lock.name != null && var.management_lock.notes != null)
    error_message = "When management_lock is not null, both name and notes must be set."
  }
}

variable "maintenance_window" {
  description = "Maintenance window properties for the PostgreSQL server. Null sets the window to System-Managed."
  type = object({
    day_of_week  = optional(number)
    start_hour   = optional(number)
    start_minute = optional(number)
  })
  default = {
    day_of_week  = 0
    start_hour   = 3
    start_minute = 15
  }
}
