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

variable "user_assigned_identity_ids" {
  type        = list(string)
  description = "values for the user assigned identities"
  default     = null
}
