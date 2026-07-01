variable "explicit_name" {
  description = "Name for the DCR when the default is not desired."
  type        = string
  default     = null
}

variable "log_analytics_destination_name" {
  description = "Destination name referenced by data flows. Must match the destinations.log_analytics name block."
  type        = string
  default     = "law"
}

variable "log_analytics_workspace_id" {
  description = <<-EOT
    ARM resource ID of the Log Analytics workspace this DCR transforms data for.

    When the same workspace sets `data_collection_rule_id` to this module's `dcr_id`, pass a
    hand-built ARM ID string here (subscription + resource group + workspace name). Do not pass
    `azurerm_log_analytics_workspace.*.id` directly or Terraform will report a dependency cycle.
  EOT
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.OperationalInsights/workspaces/.+$", var.log_analytics_workspace_id))
    error_message = "log_analytics_workspace_id must be a valid Log Analytics workspace ARM resource ID."
  }
}

variable "name_prefix" {
  description = "Prefix for naming the DCR when explicit_name is not set."
  type        = string
  default     = "dcr-law"
}

variable "redact_query_string_parameters" {
  description = <<-EOT
    Per-table configuration for redacting sensitive query-string parameters before ingestion.
    Keys are Log Analytics table names (for example AzureDiagnostics). Generates a transformKql
    data flow per key unless the same table is defined in `transformations`.
  EOT
  type = map(object({
    category_filter = optional(string)
    parameter_names = list(string)
    query_column    = string
    redacted_value  = optional(string, "[Redacted]")
  }))
  default = {
    AzureDiagnostics = {
      category_filter = "ApplicationGatewayAccessLog"
      parameter_names = ["token"]
      query_column    = "requestQuery_s"
    }
  }

  validation {
    condition = alltrue([
      for table, cfg in var.redact_query_string_parameters :
      length(cfg.parameter_names) > 0
    ])
    error_message = "Each redact_query_string_parameters entry must include at least one parameter_names value."
  }

  validation {
    condition = alltrue([
      for table, cfg in var.redact_query_string_parameters :
      alltrue([for name in cfg.parameter_names : can(regex("^[A-Za-z0-9_-]+$", name))])
    ])
    error_message = "parameter_names must contain only alphanumeric characters, underscores, and hyphens."
  }
}

variable "resource_group" {
  description = "Resource group where the DCR is deployed."
  type = object({
    location = string
    name     = string
  })

  validation {
    condition     = length(var.resource_group.name) > 0 && length(var.resource_group.name) <= 90
    error_message = "resource_group.name must be between 1 and 90 characters long."
  }
}

variable "tags" {
  description = "Tags applied to the DCR."
  type        = map(string)
  default     = {}
}

variable "transformations" {
  description = <<-EOT
    Raw transformKql queries keyed by Log Analytics table name. Use for cases not covered by
    redact_query_string_parameters. A table key must not appear in both variables.
  EOT
  type        = map(string)
  default     = {}

  validation {
    condition = length(setintersection(
      keys(var.redact_query_string_parameters),
      keys(var.transformations)
    )) == 0
    error_message = "A table name must not appear in both redact_query_string_parameters and transformations."
  }
}

variable "workspace_name" {
  description = "Log Analytics workspace name. Used only for the default DCR name when explicit_name is null."
  type        = string
  default     = null
}
