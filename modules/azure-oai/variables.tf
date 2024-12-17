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

    custom_subdomain_name = optional(string, "S0")

  }))
  validation {
    condition     = length(keys(var.cognitive_accounts)) > 0
    error_message = "cognitive_accounts cannot be empty"
  }
  # validation {
  #   #for each of the cognitive deployments location there should be at least one cognitive account with that location
  #   condition = alltrue([
  #     for cognitive_deployment in cognitive_deployments :
  #     anytrue([
  #       for cognitive_account in cognitive_accounts :
  #       cognitive_deployment["location"] == cognitive_account["location"]
  #     ])
  #     ]
  #   )
  #   error_message = "Fro each cognitive deploment location there must be at least one cognitive account in that location"
  # }
  default = {
    "cognitive-account-switzerlandnorth" = {
      name     = "cognitive-account-switzerlandnorth"
      location = "switzerlandnorth"
    }
  }
}

variable "cognitive_deployments" {
  description = "Map of deployments with model details, location, and custom subdomain name"
  type = map(object({
    name                   = string
    model_name             = string
    model_version          = string
    sku_capacity           = number
    sku_type               = optional(string, "Standard")
    location               = string
    custom_subdomain_name  = optional(string)
    cognitive_account      = string
    rai_policy_name        = optional(string)
    version_upgrade_option = optional(string, "NoAutoUpgrade")
    deployment_format      = optional(string, "OpenAI")
  }))
  validation {
    condition     = length(keys(var.cognitive_deployments)) > 0
    error_message = "cognitive_deployments cannot be empty"
  }
  # validation {
  #   condition = alltrue([
  #     for cognitive_deployment in cognitive_deployments :
  #     can(cognitive_accounts[cognitive_deployment.cognitive_account])
  #   ])
  #   error_message = "there must exist cognitive_accounts entry for each cognitive_deployments.cognitive_account defined"
  # }
  default = {
    "text-embedding-ada-002-switzerlandnorth" = {
      name              = "text-embedding-ada-002"
      model_name        = "text-embedding-ada-002"
      model_version     = "2"
      sku_capacity      = 350
      location          = "switzerlandnorth"
      cognitive_account = "cognitive-account-switzerlandnorth"
    },
    "gpt-4-switzerlandnorth" = {
      name              = "gpt-4"
      model_name        = "gpt-4"
      model_version     = "0613"
      sku_capacity      = 20
      location          = "switzerlandnorth"
      cognitive_account = "cognitive-account-switzerlandnorth"
    }
  }
}