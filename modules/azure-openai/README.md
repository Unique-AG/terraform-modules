
# Azure openai

## Pre-requisites
- To deploy this module, you have at least the following permissions:
    + Reader of the subscription

## [Examples](./examples)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.15 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.15 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_cognitive_account.aca](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account) | resource |
| [azurerm_cognitive_deployment.deployments](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_deployment) | resource |
| [azurerm_key_vault_secret.endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.model_version_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_private_endpoint.pe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cognitive_account_tags"></a> [cognitive\_account\_tags](#input\_cognitive\_account\_tags) | Additional tags that apply only to the cognitive account. These will be merged with the general tags variable. | `map(string)` | `{}` | no |
| <a name="input_cognitive_accounts"></a> [cognitive\_accounts](#input\_cognitive\_accounts) | Map of cognitive accounts, refer to the README for more details. | <pre>map(object({<br/>    name                             = string<br/>    location                         = string<br/>    kind                             = optional(string, "OpenAI")<br/>    sku_name                         = optional(string, "S0")<br/>    local_auth_enabled               = optional(bool, false)<br/>    key_in_model_definitions_exposed = optional(bool, false)<br/>    public_network_access_enabled    = optional(bool, false)<br/>    private_endpoint = optional(object({<br/>      subnet_id           = string<br/>      private_dns_zone_id = string<br/>    }))<br/>    custom_subdomain_name = string<br/>    cognitive_deployments = list(object({<br/>      name                   = string<br/>      model_name             = string<br/>      model_version          = string<br/>      model_format           = optional(string, "OpenAI")<br/>      sku_capacity           = number<br/>      sku_type               = optional(string, "Standard")<br/>      rai_policy_name        = optional(string, "Microsoft.Default")<br/>      version_upgrade_option = optional(string, "NoAutoUpgrade")<br/>    }))<br/><br/>  }))</pre> | n/a | yes |
| <a name="input_endpoint_definitions_secret_name"></a> [endpoint\_definitions\_secret\_name](#input\_endpoint\_definitions\_secret\_name) | Name of the secret for the endpoint definitions | `string` | `"azure-openai-endpoint-definitions"` | no |
| <a name="input_endpoint_secret_name_suffix"></a> [endpoint\_secret\_name\_suffix](#input\_endpoint\_secret\_name\_suffix) | The suffix of the secret name where the Cognitive Account Endpoint is stored for the Cognitive Account. The secret name will be Cognitive Account Name + this suffix | `string` | `"-endpoint"` | no |
| <a name="input_endpoints_secret_name"></a> [endpoints\_secret\_name](#input\_endpoints\_secret\_name) | Name of the secret for the endpoints | `string` | `"azure-openai-endpoints"` | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | The ID of the Key Vault where to store the secrets. If not set, the secrets will not be stored in the Key Vault | `any` | `null` | no |
| <a name="input_primary_access_key_secret_name_suffix"></a> [primary\_access\_key\_secret\_name\_suffix](#input\_primary\_access\_key\_secret\_name\_suffix) | The suffix of the secret name where the Primary Access Key is stored for the Cognitive Account. The secret name will be Cognitive Account Name + this suffix | `string` | `"-key"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags for the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cognitive_account_endpoints"></a> [cognitive\_account\_endpoints](#output\_cognitive\_account\_endpoints) | The endpoints used to connect to the Cognitive Service Account. |
| <a name="output_cognitive_account_resources"></a> [cognitive\_account\_resources](#output\_cognitive\_account\_resources) | Map of Cognitive Service Accounts where keys are the account names. |
| <a name="output_endpoints_secret_names"></a> [endpoints\_secret\_names](#output\_endpoints\_secret\_names) | List of secret names containing the endpoints for each Cognitive Service Account. Returns null if Key Vault integration is disabled. |
| <a name="output_keys_secret_names"></a> [keys\_secret\_names](#output\_keys\_secret\_names) | List of secret names containing the access keys for each Cognitive Service Account. Returns null if Key Vault integration is disabled. |
| <a name="output_model_version_endpoint_secret_name"></a> [model\_version\_endpoint\_secret\_name](#output\_model\_version\_endpoint\_secret\_name) | Name of the secret containing the model version endpoint definitions. Returns null if Key Vault integration is disabled. |
| <a name="output_model_version_endpoints"></a> [model\_version\_endpoints](#output\_model\_version\_endpoints) | List of objects containing endpoint, location and list of models |
| <a name="output_primary_access_keys"></a> [primary\_access\_keys](#output\_primary\_access\_keys) | A primary access keys which can be used to connect to the Cognitive Service Accounts. |
<!-- END_TF_DOCS -->

## Input `cognitive_accounts`

To keep the module compatible with a range of Unique versions and iterations as well as features, the flexibility to manage secrets is quite large.

The module itself defaults to the most secure variants including allowing only Workload Identity connections. For legacy components or features you can use the following flags per account to achieve the desired behaviour:

|Flag|Behaviour|
|-|-
`public_network_access_enabled`|defines, wheter the accounts are exposed to the internet / public network
|-|-
`local_auth_enabled`|defines, wheter key authentication is enabled or not
`key_in_model_definitions_exposed`|defines, wether the key is rendered into the model defintions instead of the constant `WORKLOAD_IDENTITY`, only takes effect when `local_auth_enabled` is `true`

> [!TIP]
> All secrets and/or definitions are only created if a `keyvault_id` is passed!