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
}


variable "cognitive_accounts" {
  description = "Map of cognitive accounts"
  type = map(object({
    name                          = string
    location                      = string
    kind                          = optional(string, "OpenAI")
    sku_name                      = optional(string, "S0")
    local_auth_enabled            = optional(bool, false)
    public_network_access_enabled = optional(bool, false)
    cognitive_deployments = list(object({
      name                   = string
      model_name             = string
      model_version          = string
      model_format           = optional(string, "OpenAI")
      sku_capacity           = number
      sku_type               = optional(string, "Standard")
      custom_subdomain_name  = optional(string)
      rai_policy_name        = optional(string)
      version_upgrade_option = optional(string, "NoAutoUpgrade")
    }))
    custom_subdomain_name = optional(string)

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


  default = {
    "cognitive-account-switzerlandnorth" = {
      name     = "cognitive-account-switzerlandnorth"
      location = "switzerlandnorth"
      cognitive_deployments = [
        {
          name          = "text-embedding-ada-002-2"
          model_name    = "text-embedding-ada-002"
          model_version = "2"
          sku_capacity  = 350
        },
        {
          name          = "gpt-4-0613"
          model_name    = "gpt-4"
          model_version = "0613"
          sku_capacity  = 20
        }
      ]
    }
  }
}