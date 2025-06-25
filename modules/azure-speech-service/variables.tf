variable "accounts" {
  type = map(object({
    location                      = string
    account_kind                  = optional(string, "SpeechServices")
    account_sku_name              = optional(string, "S0")
    custom_subdomain_name         = optional(string)
    public_network_access_enabled = optional(bool, false)
    identity = optional(object({
      type         = string
      identity_ids = list(string)
    }))
    private_endpoint = optional(object({
      subnet_id           = string
      vnet_location       = string
      private_dns_zone_id = string
    }))
    diagnostic_settings = optional(object({
      log_analytics_workspace_id = string
      enabled_log_categories     = optional(list(string), null)
      enabled_metrics            = optional(list(string), null)
    }))
    workload_identity = optional(object({
      principal_id         = string
      role_definition_name = string
    }))
  }))
  description = "values for the cognitive accounts"
  validation {
    condition = alltrue([
      for k, v in var.accounts :
      try(v.diagnostic_settings == null, true) ||
      try(v.diagnostic_settings.enabled_metrics == null, true) ||
      try(length(v.diagnostic_settings.enabled_metrics) > 0, true)
    ])
    error_message = "If diagnostic_settings.enabled_metrics is provided, it cannot be an empty list. Either provide specific metrics or omit the field entirely."
  }
  validation {
    condition     = length(keys(var.accounts)) > 0
    error_message = "At least one cognitive account must be defined"
  }
}

variable "speech_service_name" {
  type        = string
  description = "The name prefix for the cognitive accounts"
  validation {
    condition     = length(var.speech_service_name) > 0
    error_message = "The speech_service_name must be a non-empty string"
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
  default     = null
}

variable "private_dns_zone_id" {
  type        = string
  description = "The ID of the Private DNS Zone for the Speech Service"
  default     = null
}

variable "key_vault_id" {
  type        = string
  description = "The ID of the Key Vault where to store the secrets. If not set, the secrets will not be stored in the Key Vault"
  default     = null
}

variable "endpoint_definitions_secret_name" {
  type        = string
  description = "Name of the secret for the endpoint definitions"
  default     = "azure-speech-service-endpoint-definitions"
}
variable "endpoints_secret_name" {
  type        = string
  description = "Name of the secret for the endpoints"
  default     = "azure-speech-service-endpoints"
}
variable "primary_access_key_secret_name_suffix" {
  type        = string
  description = "The suffix of the secret name where the Primary Access Key is stored for the Cognitive Account. The secret name will be Cognitive Account Name + this suffix"
  default     = "-key"
}

variable "user_assigned_identity_ids" {
  type        = list(string)
  description = "values for the user assigned identities"
  default     = null
}

variable "resource_id_secret_name_suffix" {
  type        = string
  description = "Suffix for the resource ID secret name"
  default     = "-resource-id"
}

variable "fqdn_secret_name_suffix" {
  type        = string
  description = "The suffix of the secret name where the FQDN is stored for the Cognitive Account. The secret name will be Cognitive Account Name + this suffix"
  default     = "-fqdn"
}
