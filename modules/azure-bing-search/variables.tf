variable "resource_group_name" {
  description = "The name of the resource group where the Bing Search resources will be deployed"
  type        = string
  nullable    = false
}

variable "key_vault_id" {
  type        = string
  description = "The ID of the Key Vault where the Bing Search secrets will be stored. If not provided, secrets will not be stored"
  default     = null
}

variable "secret_name_bing_search_api_url" {
  type        = string
  description = "Name of the Key Vault secret that will store the Bing Search API endpoint URL"
  default     = "bing-search-api-url"
  nullable    = false
  validation {
    condition     = can(regex("^[a-z-]+$", var.secret_name_bing_search_api_url))
    error_message = "The secret name must contain only lowercase letters and dashes."
  }
}

variable "secret_name_bing_search_subscription_key" {
  type        = string
  description = "Name of the Key Vault secret that will store the Bing Search subscription key"
  default     = "bing-search-subscription-key"
  nullable    = false
  validation {
    condition     = can(regex("^[a-z-]+$", var.secret_name_bing_search_subscription_key))
    error_message = "The secret name must contain only lowercase letters and dashes."
  }
}

variable "bing_search_v7_sku_name" {
  type        = string
  description = "The SKU name for the Bing Search v7 service. Valid values are F1 (Free), S1, S2, S3, S4, S5, S6, S7, S8, S9"
  default     = "S2"
  nullable    = false
}
