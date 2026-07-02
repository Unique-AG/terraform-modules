variable "basic_log_tables" {
  description = "Log Analytics workspace tables to configure with the Basic plan."
  type = map(object({
    retention_in_days = optional(number)
  }))
  default = {}
}

variable "data_collection_rule" {
  description = <<-EOT
    Workspace-transform DCR configuration. By default, creates a DCR with kind
    WorkspaceTransforms and attaches it to the workspace via defaultDataCollectionRuleResourceId.
    Set to null or enabled = false to skip DCR creation and attachment.
  EOT
  type = object({
    destination_name = optional(string)
    enabled          = optional(bool, true)
    name             = optional(string)
    transformations  = optional(map(string))
  })
  default = {}
}

variable "local_authentication_enabled" {
  description = "Whether local authentication using workspace keys is enabled."
  type        = bool
  default     = false
}

variable "location" {
  description = "Azure region for the workspace and optional DCR."
  type        = string
}

variable "name" {
  description = "Name of the Log Analytics workspace."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name for the workspace and optional DCR."
  type        = string
}

variable "retention_in_days" {
  description = "Workspace retention period in days."
  type        = number
  default     = 90

  validation {
    condition     = var.retention_in_days >= 7
    error_message = "retention_in_days must be at least 7."
  }
}

variable "sku" {
  description = "SKU of the Log Analytics workspace."
  type        = string
  default     = "PerGB2018"
}

variable "tags" {
  description = "Tags applied to the workspace and optional DCR."
  type        = map(string)
  default     = {}
}
