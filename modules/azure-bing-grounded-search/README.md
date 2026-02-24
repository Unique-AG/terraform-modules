<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | ~> 2 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.bing_grounding](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.bing_search_connection](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.foundry_project](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource_action.bing_search_keys](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource_action) | resource |
| [azurerm_cognitive_account.foundry_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account) | resource |
| [azurerm_cognitive_deployment.agent_deployment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_deployment) | resource |
| [azurerm_key_vault_secret.bing_agent_model](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.bing_connection_string](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.project_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_private_endpoint.foundry_account_private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bing_account"></a> [bing\_account](#input\_bing\_account) | Configuration for the Bing Grounding account | <pre>object({<br/>    name              = string<br/>    resource_group_id = string<br/>    sku_name          = optional(string, "G1")<br/>    extra_tags        = optional(map(string), {})<br/>  })</pre> | n/a | yes |
| <a name="input_deployment"></a> [deployment](#input\_deployment) | Configuration for the cognitive services deployment | <pre>object({<br/>    name                   = string<br/>    model_name             = string<br/>    model_version          = string<br/>    model_format           = optional(string, "OpenAI")<br/>    sku_name               = optional(string, "Standard")<br/>    sku_capacity           = number<br/>    version_upgrade_option = optional(string, "NoAutoUpgrade")<br/>    rai_policy_name        = optional(string, "Microsoft.Default")<br/>  })</pre> | n/a | yes |
| <a name="input_foundry_account"></a> [foundry\_account](#input\_foundry\_account) | Configuration for the AI Foundry cognitive account | <pre>object({<br/>    name                               = string<br/>    custom_subdomain_name              = string<br/>    location                           = string<br/>    resource_group_name                = optional(string)<br/>    sku_name                           = optional(string, "S0")<br/>    extra_tags                         = optional(map(string), {})<br/>    virtual_network_subnet_ids_allowed = optional(list(string), [])<br/>    ip_rules_allowed                   = optional(list(string), [])<br/>  })</pre> | n/a | yes |
| <a name="input_foundry_projects"></a> [foundry\_projects](#input\_foundry\_projects) | Configuration for the AI Foundry projects. | <pre>map(object({<br/>    description  = string<br/>    display_name = string<br/>  }))</pre> | n/a | yes |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | The ID of the Key Vault where secrets will be stored. | `string` | n/a | yes |
| <a name="input_private_endpoint"></a> [private\_endpoint](#input\_private\_endpoint) | Configuration for the private endpoint. Set to null to enable public access (e.g., for development) | <pre>object({<br/>    subnet_id           = string<br/>    location            = optional(string)<br/>    resource_group_name = optional(string)<br/>    private_dns_zone_id = string<br/>  })</pre> | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Default resource group name for resources that don't specify their own | `string` | n/a | yes |
| <a name="input_secret_names"></a> [secret\_names](#input\_secret\_names) | Base names and expiration dates of the Key Vault secrets. Per-project secrets (project\_endpoint, bing\_connection\_string) are suffixed with the project key, e.g. 'azure-ai-project-endpoint-uat-agents-001'. Check the 'secret\_names' output for the actual composed names. | <pre>object({<br/>    project_endpoint = optional(object({<br/>      name            = optional(string, "azure-ai-project-endpoint")<br/>      expiration_date = optional(string, "2099-12-31T23:59:59Z")<br/>    }), {})<br/>    bing_connection_string = optional(object({<br/>      name            = optional(string, "azure-ai-bing-resource-connection-string")<br/>      expiration_date = optional(string, "2099-12-31T23:59:59Z")<br/>    }), {})<br/>    bing_agent_model = optional(object({<br/>      name            = optional(string, "azure-ai-bing-agent-model")<br/>      expiration_date = optional(string, "2099-12-31T23:59:59Z")<br/>    }), {})<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Default tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_foundry_account_endpoint"></a> [foundry\_account\_endpoint](#output\_foundry\_account\_endpoint) | The endpoint of the AI Foundry cognitive account |
| <a name="output_foundry_account_id"></a> [foundry\_account\_id](#output\_foundry\_account\_id) | The ID of the AI Foundry cognitive account |
| <a name="output_secret_names"></a> [secret\_names](#output\_secret\_names) | The composed Key Vault secret names created by this module |
<!-- END_TF_DOCS -->