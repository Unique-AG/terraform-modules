# Azure Redis

## Pre-requisites
- To deploy this module, you have at least the following permissions:
    + Reader of the subscription

## [Examples](./examples)


# Module

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
| [azurerm_key_vault_secret.redis-cache-host](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.redis-cache-password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.redis-cache-port](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_private_endpoint.pe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_redis_cache.arc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_capacity"></a> [capacity](#input\_capacity) | The size of the Redis cache to deploy. Valid values for a SKU family of C (Basic/Standard) are 0, 1, 2, 3, 4, 5, 6, and for P (Premium) family are 1, 2, 3, 4, 5. | `number` | `1` | no |
| <a name="input_family"></a> [family](#input\_family) | The SKU family/pricing group to use. Valid values are C (for Basic/Standard SKU family) and P (for Premium) | `string` | `"C"` | no |
| <a name="input_host_secret_name"></a> [host\_secret\_name](#input\_host\_secret\_name) | Name of the secret containing the host | `string` | `null` | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | The ID of the Key Vault where the secrets will be stored | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region where the Redis Cache will be deployed. | `string` | n/a | yes |
| <a name="input_min_tls_version"></a> [min\_tls\_version](#input\_min\_tls\_version) | Minimum TLS version supported by the Redis Cache. Valid values are 1.0, 1.1, and 1.2. | `string` | `"1.2"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Redis Cache instance. | `string` | n/a | yes |
| <a name="input_password_secret_name"></a> [password\_secret\_name](#input\_password\_secret\_name) | Name of the secret containing the password | `string` | `null` | no |
| <a name="input_port_secret_name"></a> [port\_secret\_name](#input\_port\_secret\_name) | Name of the secret containing the port | `string` | `null` | no |
| <a name="input_private_endpoint"></a> [private\_endpoint](#input\_private\_endpoint) | Configuration for private endpoint to connect to the Redis Cache. When specified, creates a private endpoint in the specified subnet and links it to the provided private DNS zone. | <pre>object({<br/>    subnet_id           = string<br/>    private_dns_zone_id = string<br/>  })</pre> | `null` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether or not public network access is allowed for this Redis Cache | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group where the Redis Cache will be deployed. | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The SKU of Redis to use. Possible values are Basic, Standard and Premium | `string` | `"Standard"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the Redis Cache resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_host_secret_name"></a> [host\_secret\_name](#output\_host\_secret\_name) | Name of the secret containing Redis host |
| <a name="output_hostname"></a> [hostname](#output\_hostname) | The hostname of the Redis Cache instance |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Redis Cache instance |
| <a name="output_non_ssl_port"></a> [non\_ssl\_port](#output\_non\_ssl\_port) | The non-SSL port of the Redis Cache instance |
| <a name="output_password_secret_name"></a> [password\_secret\_name](#output\_password\_secret\_name) | Name of the secret containing Redis password |
| <a name="output_port_secret_name"></a> [port\_secret\_name](#output\_port\_secret\_name) | Name of the secret containing Redis port |
| <a name="output_primary_access_key"></a> [primary\_access\_key](#output\_primary\_access\_key) | The current primary key that clients can use to authenticate with Redis Cache |
| <a name="output_secondary_access_key"></a> [secondary\_access\_key](#output\_secondary\_access\_key) | The current secondary key that clients can use to authenticate with Redis Cache |
| <a name="output_ssl_port"></a> [ssl\_port](#output\_ssl\_port) | The SSL port of the Redis Cache instance |
<!-- END_TF_DOCS -->
