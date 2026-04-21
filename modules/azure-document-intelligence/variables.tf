variable "accounts" {
  type = map(object({
    location                      = string
    account_kind                  = optional(string, "FormRecognizer")
    account_sku_name              = optional(string, "S0")
    custom_subdomain_name         = optional(string)
    local_auth_enabled            = optional(bool, false)
    public_network_access_enabled = optional(bool, false)
    customer_managed_key = optional(object({
      key_vault_key_id = string
      user_assigned_identity = object({
        client_id   = string
        resource_id = string
      })
    }))
    private_endpoint = optional(object({
      private_dns_zone_id = string
      subnet_id           = string
      vnet_location       = optional(string)
    }))

    diagnostic_settings = optional(object({
      log_analytics_workspace_id = string
      log_categories             = optional(list(string), ["Audit"])
      log_category_groups        = optional(list(string), [])
      metric_categories          = optional(list(string), ["AllMetrics"])
    }))
  }))
  description = <<-EOT
    Values for the cognitive accounts.

    Diagnostic settings precedence: each account's `diagnostic_settings` overrides the module-level `var.diagnostic_settings`.
    If both are null for an account, no diagnostic setting is created for that account.

    `log_categories` vs `log_category_groups`: mutually exclusive in Azure Monitor (each `enabled_log` block sets exactly one).
    This module mirrors the Azure portal: if `log_category_groups` is non-empty, `log_categories` is ignored (group takes precedence).
    `log_category_groups` is dynamic — new categories Azure adds to the group are auto-enabled.
    `log_categories` locks the exact list. Valid values when using explicit categories: Audit, AzureOpenAIRequestUsage, RequestResponse, Trace.
  EOT
  validation {
    condition     = length(keys(var.accounts)) > 0
    error_message = "At least one cognitive account must be defined"
  }
  validation {
    condition = alltrue([
      for account in var.accounts :
      account.diagnostic_settings == null || alltrue([
        for category in coalesce(try(account.diagnostic_settings.log_categories, null), []) :
        contains(["Audit", "AzureOpenAIRequestUsage", "RequestResponse", "Trace"], category)
      ])
    ])
    error_message = "diagnostic_settings.log_categories must only contain valid values: 'Audit', 'AzureOpenAIRequestUsage', 'RequestResponse', 'Trace'"
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

variable "key_vault_id" {
  type        = string
  description = "The ID of the Key Vault where to store the secrets. If not set, the secrets will not be stored in the Key Vault"
  default     = null
}

variable "endpoint_definitions_secret_name" {
  type        = string
  description = "Name of the secret for the endpoint definitions"
  default     = "azure-document-intelligence-endpoint-definitions"
}
variable "endpoints_secret_name" {
  type        = string
  description = "Name of the secret for the endpoints"
  default     = "azure-document-intelligence-endpoints"
}
variable "primary_access_key_secret_name_suffix" {
  type        = string
  description = "The suffix of the secret name where the Primary Access Key is stored for the Cognitive Account. The secret name will be Cognitive Account Name + this suffix"
  default     = "-key"
}

variable "diagnostic_settings" {
  description = <<-EOT
    Global diagnostic settings configuration for Azure Cognitive Services accounts.
    If null, diagnostic settings are not created (unless overridden per account).

    Per-account diagnostic_settings take precedence over this global setting.
    This serves as a fallback for accounts that don't specify their own settings.

    Available log categories (when using explicit `log_categories` and `log_category_groups` is empty):
      - Audit: Audit logs (default, recommended minimum)
      - AzureOpenAIRequestUsage: Token usage and request metering for applicable cognitive services
      - RequestResponse: Logs all request and response data including prompts and completions
      - Trace: Detailed trace logs

    `log_categories` and `log_category_groups` are mutually exclusive at the Azure API (each enabled log block sets exactly one).
    This module mirrors the Azure portal: if `log_category_groups` is non-empty, `log_categories` is ignored (group takes precedence).
    Use `log_category_groups` for dynamic groups such as `audit` or `allLogs`; see Azure Monitor documentation for valid values.

    WARNING: Enabling 'RequestResponse' or 'Trace' categories will log sensitive data such as
    user prompts and model responses. It is YOUR responsibility to:
      - Restrict access to the Log Analytics workspace appropriately
      - Ensure compliance with data protection regulations (GDPR, etc.)
      - Implement appropriate retention policies
      - Consider the cost implications of high-volume logging
  EOT
  type = object({
    log_analytics_workspace_id = string
    log_categories             = optional(list(string), ["Audit"])
    log_category_groups        = optional(list(string), [])
    metric_categories          = optional(list(string), ["AllMetrics"])
  })
  default = null

  validation {
    condition = var.diagnostic_settings == null || alltrue([
      for category in coalesce(try(var.diagnostic_settings.log_categories, null), []) :
      contains(["Audit", "AzureOpenAIRequestUsage", "RequestResponse", "Trace"], category)
    ])
    error_message = "log_categories must only contain valid values: 'Audit', 'AzureOpenAIRequestUsage', 'RequestResponse', 'Trace'"
  }
}
