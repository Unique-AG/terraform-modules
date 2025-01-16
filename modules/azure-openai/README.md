
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
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.117 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.117 |

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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cognitive_accounts"></a> [cognitive\_accounts](#input\_cognitive\_accounts) | Map of cognitive accounts | <pre>map(object({<br/>    name                          = string<br/>    location                      = string<br/>    kind                          = optional(string, "OpenAI")<br/>    sku_name                      = optional(string, "S0")<br/>    local_auth_enabled            = optional(bool, false)<br/>    public_network_access_enabled = optional(bool, false)<br/>    cognitive_deployments = list(object({<br/>      name                   = string<br/>      model_name             = string<br/>      model_version          = string<br/>      model_format           = optional(string, "OpenAI")<br/>      sku_capacity           = number<br/>      sku_type               = optional(string, "Standard")<br/>      rai_policy_name        = optional(string)<br/>      version_upgrade_option = optional(string, "NoAutoUpgrade")<br/>    }))<br/>    custom_subdomain_name = string<br/><br/>  }))</pre> | <pre>{<br/>  "cognitive-account-switzerlandnorth": {<br/>    "cognitive_deployments": [<br/>      {<br/>        "model_name": "text-embedding-ada-002",<br/>        "model_version": "2",<br/>        "name": "text-embedding-ada-002-2",<br/>        "sku_capacity": 350<br/>      },<br/>      {<br/>        "model_name": "gpt-4",<br/>        "model_version": "0613",<br/>        "name": "gpt-4-0613",<br/>        "sku_capacity": 20<br/>      }<br/>    ],<br/>    "location": "switzerlandnorth",<br/>    "name": "cognitive-account-switzerlandnorth"<br/>  }<br/>}</pre> | no |
| <a name="input_endpoint_definitions_secret_name"></a> [endpoint\_definitions\_secret\_name](#input\_endpoint\_definitions\_secret\_name) | Name of the secret for the endpoint definitions | `string` | `"azure-openai-endpoint-definitions"` | no |
| <a name="input_endpoint_secret_name_suffix"></a> [endpoint\_secret\_name\_suffix](#input\_endpoint\_secret\_name\_suffix) | The suffix of the secret name where the Cognitive Account Endpoint is stored for the Cognitive Account. The secret name will be Cognitive Account Name + this suffix | `string` | `"-endpoint"` | no |
| <a name="input_endpoints_secret_name"></a> [endpoints\_secret\_name](#input\_endpoints\_secret\_name) | Name of the secret for the endpoints | `string` | `"azure-openai-endpoints"` | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | The ID of the Key Vault where to store the secrets. If not set, the secrets will not be stored in the Key Vault | `any` | `null` | no |
| <a name="input_primary_access_key_secret_name_suffix"></a> [primary\_access\_key\_secret\_name\_suffix](#input\_primary\_access\_key\_secret\_name\_suffix) | The suffix of the secret name where the Primary Access Key is stored for the Cognitive Account. The secret name will be Cognitive Account Name + this suffix | `string` | `"-key"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags for the resource | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cognitive_account_endpoints"></a> [cognitive\_account\_endpoints](#output\_cognitive\_account\_endpoints) | The endpoints used to connect to the Cognitive Service Account. |
| <a name="output_model_version_endpoints"></a> [model\_version\_endpoints](#output\_model\_version\_endpoints) | List of objects containing endpoint, location and list of models |
| <a name="output_primary_access_keys"></a> [primary\_access\_keys](#output\_primary\_access\_keys) | A primary access keys which can be used to connect to the Cognitive Service Accounts. |
<!-- END_TF_DOCS -->
