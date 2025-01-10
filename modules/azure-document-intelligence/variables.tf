variable "accounts" {
  type = map(object({
    location              = string
    account_kind          = optional(string, "FormRecognizer")
    account_sku_name      = optional(string, "S0")
    custom_subdomain_name = optional(string)
  }))
  description = "values for the cognitive accounts"
  validation {
    condition     = length(keys(var.accounts)) > 0
    error_message = "At least one cognitive account must be defined"
  }
}

variable "doc_intelligence_name" {
  type        = string
  description = "The name prefix for the cognitive accounts"
  validation {
    condition     = length(var.doc_intelligence_name) > 0
    error_message = "The doc_intelligence_name must be a non-empty string"
  }
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "The resource_group_name must be a non-empty string"
  }
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource"
  validation {
    condition     = length(keys(var.tags)) > 0
    error_message = "At least one tag must be defined"
  }
}
variable "key_vault_output_settings" {
  type = object({
    key_vault_output_enabled              = optional(bool, true)
    key_vault_id                          = string
    endpoint_definitions_secret_name      = optional(string, "azure-document-intelligence-endpoint-definitions")
    endpoints_secret_name                 = optional(string, "azure-document-intelligence-endpoints")
    primary_access_key_secret_name_suffix = optional(string, "-key")
  })
  default  = null
  nullable = true
}

variable "user_assigned_identity_ids" {
  type        = list(string)
  description = "values for the user assigned identities"
  default     = null
}
