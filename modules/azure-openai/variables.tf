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

variable "cognitive_account_tags" {
  description = "Additional tags that apply only to the cognitive account. These will be merged with the general tags variable."
  type        = map(string)
  default     = {}
}

variable "cognitive_accounts" {
  description = "Map of cognitive accounts, refer to the README for more details."
  type = map(object({
    name                                     = string
    location                                 = string
    kind                                     = optional(string, "OpenAI")
    sku_name                                 = optional(string, "S0")
    local_auth_enabled                       = optional(bool, false)
    model_definitions_auth_strategy_injected = optional(string, "WorkloadIdentity")
    public_network_access_enabled            = optional(bool, false)
    private_endpoint = optional(object({
      subnet_id           = string
      private_dns_zone_id = string
    }))
    custom_subdomain_name = string
    cognitive_deployments = list(object({
      name                   = string
      model_name             = string
      model_version          = string
      model_format           = optional(string, "OpenAI")
      sku_capacity           = number
      sku_type               = optional(string, "Standard")
      rai_policy_name        = optional(string, "Microsoft.Default")
      version_upgrade_option = optional(string, "NoAutoUpgrade")
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
}

variable "key_vault_id" {
  description = "The ID of the Key Vault where to store the secrets. If not set, the secrets will not be stored in the Key Vault"
  default     = null
}

variable "endpoint_definitions_secret_name" {
  description = "Name of the secret for the endpoint definitions"
  default     = "azure-openai-endpoint-definitions"
}
variable "endpoints_secret_name" {
  description = "Name of the secret for the endpoints"
  default     = "azure-openai-endpoints"
}
variable "primary_access_key_secret_name_suffix" {
  description = "The suffix of the secret name where the Primary Access Key is stored for the Cognitive Account. The secret name will be Cognitive Account Name + this suffix"
  default     = "-key"
}
variable "endpoint_secret_name_suffix" {
  description = "The suffix of the secret name where the Cognitive Account Endpoint is stored for the Cognitive Account. The secret name will be Cognitive Account Name + this suffix"
  default     = "-endpoint"
}
