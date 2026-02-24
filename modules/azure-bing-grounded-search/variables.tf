variable "resource_group_name" {
  description = "Default resource group name for resources that don't specify their own"
  type        = string
}

variable "tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "foundry_account" {
  description = "Configuration for the AI Foundry cognitive account"
  type = object({
    name                               = string
    custom_subdomain_name              = string
    location                           = string
    resource_group_name                = optional(string)
    sku_name                           = optional(string, "S0")
    extra_tags                         = optional(map(string), {})
    virtual_network_subnet_ids_allowed = optional(list(string), [])
    ip_rules_allowed                   = optional(list(string), [])
  })
}

variable "foundry_projects" {
  description = "Configuration for the AI Foundry projects."
  type = map(object({
    description  = string
    display_name = string
  }))
}

variable "private_endpoint" {
  description = "Configuration for the private endpoint. Set to null to enable public access (e.g., for development)"
  type = object({
    subnet_id           = string
    location            = optional(string)
    resource_group_name = optional(string)
    private_dns_zone_id = string
  })
  default = null # PE requires a VNET injected machine, we don't want to invest into that right now https://learn.microsoft.com/en-us/azure/ai-foundry/how-to/configure-private-link#securely-connect-to-foundry
}

variable "deployment" {
  description = "Configuration for the cognitive services deployment"
  type = object({
    name                   = string
    model_name             = string
    model_version          = string
    model_format           = optional(string, "OpenAI")
    sku_name               = optional(string, "Standard")
    sku_capacity           = number
    version_upgrade_option = optional(string, "NoAutoUpgrade")
    rai_policy_name        = optional(string, "Microsoft.Default")
  })
}

variable "bing_account" {
  description = "Configuration for the Bing Grounding account"
  type = object({
    name              = string
    resource_group_id = string
    sku_name          = optional(string, "G1")
    extra_tags        = optional(map(string), {})
  })
}

variable "key_vault_id" {
  description = "The ID of the Key Vault where secrets will be stored."
  type        = string
}

variable "secret_names" {
  description = "Base names and expiration dates of the Key Vault secrets. Per-project secrets (project_endpoint, bing_connection_string) are suffixed with the project key, e.g. 'azure-ai-project-endpoint-uat-agents-001'. Check the 'secret_names' output for the actual composed names."
  type = object({
    project_endpoint = optional(object({
      name            = optional(string, "azure-ai-project-endpoint")
      expiration_date = optional(string, "2099-12-31T23:59:59Z")
    }), {})
    bing_connection_string = optional(object({
      name            = optional(string, "azure-ai-bing-resource-connection-string")
      expiration_date = optional(string, "2099-12-31T23:59:59Z")
    }), {})
    bing_agent_model = optional(object({
      name            = optional(string, "azure-ai-bing-agent-model")
      expiration_date = optional(string, "2099-12-31T23:59:59Z")
    }), {})
  })
  default = {}
}
