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
| [azurerm_key_vault_secret.bing_api_url](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.bing_subscription_key_1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.bing_subscription_key_2](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_resource_group_template_deployment.argtd_bing_search_v7](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_template_deployment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bing_search_v7_sku_name"></a> [bing\_search\_v7\_sku\_name](#input\_bing\_search\_v7\_sku\_name) | The SKU name for the Bing Search v7 service. Valid values are F1 (Free), S1, S2, S3, S4, S5, S6, S7, S8, S9 | `string` | `"S2"` | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | The ID of the Key Vault where the Bing Search secrets will be stored. If not provided, secrets will not be stored | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Search service. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where the Bing Search resources will be deployed | `string` | n/a | yes |
| <a name="input_secret_name_bing_search_api_url"></a> [secret\_name\_bing\_search\_api\_url](#input\_secret\_name\_bing\_search\_api\_url) | Name of the Key Vault secret that will store the Bing Search API endpoint URL | `string` | `"bing-search-api-url"` | no |
| <a name="input_secret_name_bing_search_subscription_key"></a> [secret\_name\_bing\_search\_subscription\_key](#input\_secret\_name\_bing\_search\_subscription\_key) | Name of the Key Vault secret that will store the Bing Search subscription key | `string` | `"bing-search-subscription-key"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
