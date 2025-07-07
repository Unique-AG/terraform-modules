
This Terraform module creates a PostgreSQL flexible server on Azure and configures the server's parameters and databases. It's designed to be reusable as a module, allowing you to easily deploy PostgreSQL servers with different configurations.

## Pre-requisites
- To deploy this module, you have at least the following permissions:
    + Reader of the subscription
    + Access to the [Key Vault where the Customer-Managed Key is stored](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_customer_managed_key) in case one is used
    + Contributor of the resource group

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
| [azurerm_key_vault_key.psql-account-byok](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_key_vault_secret.database_connection_strings](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.host](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.port](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.username](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_postgresql_flexible_server.apfs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server) | resource |
| [azurerm_postgresql_flexible_server_configuration.parameters](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_configuration) | resource |
| [azurerm_postgresql_flexible_server_database.destructible_database_server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_database) | resource |
| [azurerm_postgresql_flexible_server_database.indestructible_database_server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_database) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | The Password associated with the administrator\_login for the PostgreSQL Flexible Server | `string` | n/a | yes |
| <a name="input_administrator_login"></a> [administrator\_login](#input\_administrator\_login) | The Administrator login for the PostgreSQL Flexible Server | `string` | n/a | yes |
| <a name="input_auto_grow_enabled"></a> [auto\_grow\_enabled](#input\_auto\_grow\_enabled) | Specifies whether the PostgreSQL Flexible Server should be automatically grow the storage. | `string` | `true` | no |
| <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key) | Customer managed key properties for the storage account. Refer to the readme for more information on what is needed to enable customer-managed key encryption. It is recommended to not use key\_version unless you have a specific reason to do so as leaving it out will allow automatic key rotation. The key\_vault\_id must be accessible to the user\_assigned\_identity\_id. | <pre>object({<br/>    key_vault_key_id          = string<br/>    user_assigned_identity_id = string<br/>  })</pre> | `null` | no |
| <a name="input_database_connection_string_secret_prefix"></a> [database\_connection\_string\_secret\_prefix](#input\_database\_connection\_string\_secret\_prefix) | Prefix of the secret containing the full connection string. The full name of the secret is this prefix + database name | `string` | `"database-url-"` | no |
| <a name="input_databases"></a> [databases](#input\_databases) | Map of databases and its properties | <pre>map(<br/>    object({<br/>      name            = string<br/>      collation       = optional(string, null)<br/>      charset         = optional(string, null)<br/>      lifecycle       = optional(bool, false)<br/>      prevent_destroy = optional(bool, true)<br/>    })<br/>  )</pre> | `{}` | no |
| <a name="input_delegated_subnet_id"></a> [delegated\_subnet\_id](#input\_delegated\_subnet\_id) | The ID of the delegated subnet. | `string` | `null` | no |
| <a name="input_flex_pg_backup_retention_days"></a> [flex\_pg\_backup\_retention\_days](#input\_flex\_pg\_backup\_retention\_days) | The number of days to retain backups for the PostgreSQL server. | `number` | `7` | no |
| <a name="input_flex_pg_version"></a> [flex\_pg\_version](#input\_flex\_pg\_version) | The version of the PostgreSQL server. | `string` | `"14"` | no |
| <a name="input_flex_sku"></a> [flex\_sku](#input\_flex\_sku) | The SKU for the PostgreSQL server. | `string` | `"GP_Standard_D2ds_v5"` | no |
| <a name="input_flex_storage_mb"></a> [flex\_storage\_mb](#input\_flex\_storage\_mb) | The storage size in MB for the PostgreSQL server. | `number` | `32768` | no |
| <a name="input_host_secret_name"></a> [host\_secret\_name](#input\_host\_secret\_name) | Name of the secret containing the host | `string` | `null` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | List of managed identity IDs to assign to the storage account. | `list(string)` | `[]` | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | The ID of the Key Vault where the secrets will be stored | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The location where the resources will be deployed. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the PostgreSQL server resource. | `string` | n/a | yes |
| <a name="input_parameter_values"></a> [parameter\_values](#input\_parameter\_values) | values for the server configuration parameters | `map(string)` | <pre>{<br/>  "azure.extensions": "PG_STAT_STATEMENTS,PG_TRGM",<br/>  "enable_seqscan": "off",<br/>  "max_connections": "400"<br/>}</pre> | no |
| <a name="input_password_secret_name"></a> [password\_secret\_name](#input\_password\_secret\_name) | Name of the secret containing the admin password | `string` | `null` | no |
| <a name="input_port_secret_name"></a> [port\_secret\_name](#input\_port\_secret\_name) | Name of the secret containing the port | `string` | `null` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | The ID of the private DNS zone. | `string` | `null` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Specifies whether this PostgreSQL Flexible Server is publicly accessible. Defaults to false | `string` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where the resources will be created. | `string` | n/a | yes |
| <a name="input_self_cmk"></a> [self\_cmk](#input\_self\_cmk) | Details for the self customer managed key. | <pre>object({<br/>    key_name                  = string<br/>    key_vault_id              = string<br/>    key_type                  = optional(string, "RSA-HSM")<br/>    key_size                  = optional(number, 2048)<br/>    key_opts                  = optional(list(string), ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"])<br/>    user_assigned_identity_id = string<br/><br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the resources. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Timeout properties of the database | <pre>object({<br/>    create = optional(string)<br/>    read   = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | <pre>{<br/>  "update": "30m"<br/>}</pre> | no |
| <a name="input_username_secret_name"></a> [username\_secret\_name](#input\_username\_secret\_name) | Name of the secret containing the admin username | `string` | `null` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | (Optional) Specifies the Availability Zone in which the PostgreSQL Flexible Server should be located. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_connection_strings_secret_name"></a> [database\_connection\_strings\_secret\_name](#output\_database\_connection\_strings\_secret\_name) | The names of the secrets containing the full connection strings to the databases, including the admin username and password |
| <a name="output_host_secret_name"></a> [host\_secret\_name](#output\_host\_secret\_name) | The name of the secret containing the hostname |
| <a name="output_password_secret_name"></a> [password\_secret\_name](#output\_password\_secret\_name) | The name of the secret containing the admin password |
| <a name="output_port_secret_name"></a> [port\_secret\_name](#output\_port\_secret\_name) | The name of the secret containing the port |
| <a name="output_postgresql_server_fqdn"></a> [postgresql\_server\_fqdn](#output\_postgresql\_server\_fqdn) | The FQDN of the PostgreSQL server |
| <a name="output_postgresql_server_id"></a> [postgresql\_server\_id](#output\_postgresql\_server\_id) | The ID of the PostgreSQL server |
| <a name="output_username_secret_name"></a> [username\_secret\_name](#output\_username\_secret\_name) | The name of the secret containing the admin username |
<!-- END_TF_DOCS -->
