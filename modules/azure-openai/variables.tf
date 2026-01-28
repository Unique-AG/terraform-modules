variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "resource_group_name cannot be empty"
  }
}

variable "tags" {
  type        = map(string)
  description = "Additional tags for the resource"
  default     = {}
}

variable "cognitive_accounts" {
  description = "Map of cognitive accounts, refer to the README for more details."
  type = map(object({
    custom_subdomain_name                    = string
    extra_tags                               = optional(map(string), {})
    kind                                     = optional(string, "OpenAI")
    local_auth_enabled                       = optional(bool, false)
    location                                 = string
    model_definitions_auth_strategy_injected = optional(string, "WorkloadIdentity")
    name                                     = string
    public_network_access_enabled            = optional(bool, false)
    sku_name                                 = optional(string, "S0")

    private_endpoint = optional(object({
      private_dns_zone_id = string
      subnet_id           = string
      vnet_location       = optional(string)
    }))

    cognitive_deployments = list(object({
      model_format           = optional(string, "OpenAI")
      model_name             = string
      model_version          = string
      name                   = string
      rai_policy_name        = optional(string, "Microsoft.Default")
      sku_capacity           = number
      sku_name               = optional(string, "Standard")
      version_upgrade_option = optional(string, "NoAutoUpgrade")
    }))

    diagnostic_settings = optional(object({
      log_analytics_workspace_id = string
      log_categories             = optional(list(string), ["Audit"])
      metric_categories          = optional(list(string), ["AllMetrics"])
    }))

  }))
  validation {
    condition     = length(keys(var.cognitive_accounts)) > 0
    error_message = "cognitive_accounts cannot be empty"
  }
  validation {
    condition = alltrue([
      for account in var.cognitive_accounts :
      length(account.cognitive_deployments) > 0
    ])
    error_message = "cognitive_deployments cannot be empty for any of the accounts"
  }
  validation {
    condition = alltrue([
      for account in var.cognitive_accounts :
      contains(["WorkloadIdentity", "ApiKey"], account.model_definitions_auth_strategy_injected)
    ])
    error_message = "model_definitions_auth_strategy_injected must be either 'WorkloadIdentity' or 'ApiKey'"
  }
  validation {
    condition = alltrue([
      for account in var.cognitive_accounts :
      account.model_definitions_auth_strategy_injected != "ApiKey" || account.local_auth_enabled == true
    ])
    error_message = "When model_definitions_auth_strategy_injected is 'ApiKey', local_auth_enabled must be true"
  }
  validation {
    condition = alltrue([
      for account in var.cognitive_accounts :
      account.diagnostic_settings == null || alltrue([
        for category in coalesce(try(account.diagnostic_settings.log_categories, null), []) :
        contains(["Audit", "RequestResponse", "Trace"], category)
      ])
    ])
    error_message = "diagnostic_settings.log_categories must only contain valid values: 'Audit', 'RequestResponse', 'Trace'"
  }
}

variable "key_vault_id" {
  description = "The ID of the Key Vault where to store the secrets. If not set, the secrets will not be stored in a Key Vault"
  default     = null
}

variable "primary_access_key_secret" {
  description = "Configuration for the primary access key secret. Created per account and is populated with a placeholder if model_definitions_auth_strategy_injected is 'ApiKey' and local_auth_enabled is false."
  type = object({
    expiration_date = optional(string, "2099-12-31T23:59:59Z")
    extra_tags      = optional(map(string), {})
    name_suffix     = optional(string, "-key")
  })
  default = {}
}

variable "endpoint_secret" {
  description = "Configuration for the endpoint secret"
  type = object({
    expiration_date = optional(string, "2099-12-31T23:59:59Z")
    extra_tags      = optional(map(string), {})
    name_suffix     = optional(string, "-endpoint")
  })
  default = {}
}

variable "endpoint_definitions_secret" {
  description = "Name of the secret for the endpoint definitions"
  type = object({
    expiration_date = optional(string, "2099-12-31T23:59:59Z")
    extra_tags      = optional(map(string), {})
    name            = optional(string, "azure-openai-endpoint-definitions")

    # https://learn.microsoft.com/en-us/azure/ai-foundry/openai/quotas-limits
    sku_capacity_field_name = optional(string, "tpmThousands") # the sku_capacity field is very technical, to further process the field, we use the correct unit name
    sku_name_field_name     = optional(string, "usageTier")    # the sku_name field is very technical, to further process the field, we use the correct term from the Azure Docs
  })
  default = {}
}

variable "diagnostic_settings" {
  description = <<-EOT
    Global diagnostic settings configuration for Azure Cognitive Services accounts.
    If null, diagnostic settings are not created (unless overridden per account).

    Per-account diagnostic_settings take precedence over this global setting.
    This serves as a fallback for accounts that don't specify their own settings.

    Available log categories:
      - Audit: Audit logs (default, recommended minimum)
      - RequestResponse: Logs all request and response data including prompts and completions
      - Trace: Detailed trace logs

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
    metric_categories          = optional(list(string), ["AllMetrics"])
  })
  default = null

  validation {
    condition = var.diagnostic_settings == null || alltrue([
      for category in coalesce(try(var.diagnostic_settings.log_categories, null), []) :
      contains(["Audit", "RequestResponse", "Trace"], category)
    ])
    error_message = "log_categories must only contain valid values: 'Audit', 'RequestResponse', 'Trace'"
  }
}
