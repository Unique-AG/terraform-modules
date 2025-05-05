# Azure Unique Secrets Bundle

> [!CAUTION]
> This module is for incubating and experimental. Regular releases are not yet established. If a new version is not available for a Unique release it means that the underlying secrets did not change and you can stay on the older version. The [release notes](https://unique-ch.atlassian.net/wiki/x/GIAlQ) are the source of truth.

> [!TIP]
> This module is for convenience. You can easily manage all necessary secrets yourself.

The secrets bundle for Azure creates necessary secrets in two given Azure KeyVaults (they aren't mutually exclusive, so you could pass twice the same). If you decide to split the values into more Key Vaults for more granular segregation, you can use this module as _list of secrets needed_ and self-create the values.

Not all manual values are always needed and you can leave them away if your workloads/configuration does not need them (e.g. Docker Credentials if you use a Pull Throug Mechanism).

## Versioning
Compared to the rest of the modules, this module follows the current Unique Release Versioning which roughly is: `YEAR.CalendarWeek`. Per se it is SemVer with very large increments.

## Expiration Dates
The default expiration dates date to `2099-12-31T23:59:59Z`. This is not due to the lack of security but due to the nature of these secrets. They are configuration as code, inaccessible to humans. While we allow necessary security measures by building in rotation mechanisms we refuse to put unnecessary pressure onto cluster-operators to rotate a secret that is never actually handed out and only needed to communicate between two pods within the cluster.

## Pre-requisites
- The executing principal needs at least `Key Vault Secrets Officer` permissions on both Key Vaults.

## [Examples](./examples)

# Module

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.27.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault_secret.encryption_app_repository](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.encryption_key_ingestion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.hex_encryption_key_ingestion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.hex_encryption_key_scope_management_1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.hex_encryption_key_scope_management_2](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.litellm_master_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.litellm_salt_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.manual_secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.rabbitmq_password_chat](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.zitadel_db_user_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.zitadel_main_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [random_id.hex_encryption_key_ingestion](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_id.hex_encryption_key_node_chat_lxm](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_id.hex_encryption_key_scope_management_1](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_id.hex_encryption_key_scope_management_2](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_password.encryption_key_app_repository](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.litellm_master_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.litellm_salt_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.rabbitmq_password_chat](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.zitadel_db_user_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.zitadel_main_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_secrets_placeholders"></a> [default\_secrets\_placeholders](#input\_default\_secrets\_placeholders) | List of secrets that are manually created and need to be placed in the core key vault. The manual- prefix is prepended automatically. | <pre>map(object({<br/>    create          = optional(bool, true)<br/>    expiration_date = optional(string, "2099-12-31T23:59:59Z")<br/>  }))</pre> | <pre>{<br/>  "litellm-anthropic-api-key": {<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z"<br/>  },<br/>  "litellm-bedrock-access-key": {<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z"<br/>  },<br/>  "litellm-bedrock-secret-key": {<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z"<br/>  },<br/>  "litellm-gemini-api-key": {<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z"<br/>  },<br/>  "litellm-openai-api-key": {<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z"<br/>  },<br/>  "litellm-together-ai-api-key": {<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z"<br/>  },<br/>  "litellm-voyage-api-key": {<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z"<br/>  },<br/>  "quartr-api-creds": {<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z"<br/>  },<br/>  "zitadel-scope-mgmt-pat": {<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z"<br/>  }<br/>}</pre> | no |
| <a name="input_extra_secrets_placeholders"></a> [extra\_secrets\_placeholders](#input\_extra\_secrets\_placeholders) | List of secrets that are additionally, manually created and need to be placed in the core key vault. The manual- prefix is prepended automatically. | <pre>map(object({<br/>    expiration_date = optional(string, "2099-12-31T23:59:59Z")<br/>  }))</pre> | `{}` | no |
| <a name="input_kv_id_core"></a> [kv\_id\_core](#input\_kv\_id\_core) | The ID of the core key vault, all manually created secrets will be placed here. | `string` | n/a | yes |
| <a name="input_kv_id_sensitive"></a> [kv\_id\_sensitive](#input\_kv\_id\_sensitive) | The ID of the sensitive key vault, all automatically generated secrets will be stored here. | `string` | n/a | yes |
| <a name="input_secrets_to_create"></a> [secrets\_to\_create](#input\_secrets\_to\_create) | List of secrets that are automatically generated and need to be placed in the sensitive key vault. Increment a counter to rotate the secret. | <pre>map(object({<br/>    create           = optional(bool, true)<br/>    name             = optional(string)<br/>    content_type     = optional(string, "text/plain")<br/>    special          = optional(bool, false)<br/>    length           = optional(number)<br/>    rotation_counter = optional(number, 0)<br/>    expiration_date  = optional(string, "2099-12-31T23:59:59Z")<br/>  }))</pre> | <pre>{<br/>  "encryption_app_repository": {<br/>    "content_type": "text/plain",<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z",<br/>    "name": "encryption-app-repository",<br/>    "rotation_counter": 0,<br/>    "special": false<br/>  },<br/>  "hex_encryption_key_ingestion": {<br/>    "content_type": "text/hex",<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z",<br/>    "name": "encryption-key-ingestion",<br/>    "rotation_counter": 0<br/>  },<br/>  "hex_encryption_key_node_chat_lxm": {<br/>    "content_type": "text/hex",<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z",<br/>    "name": "encryption-key-node-chat-lxm",<br/>    "rotation_counter": 0<br/>  },<br/>  "hex_encryption_key_scope_management_1": {<br/>    "content_type": "text/hex",<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z",<br/>    "name": "encryption-key-scope-management-1",<br/>    "rotation_counter": 0<br/>  },<br/>  "hex_encryption_key_scope_management_2": {<br/>    "content_type": "text/hex",<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z",<br/>    "name": "encryption-key-scope-management-2",<br/>    "rotation_counter": 0<br/>  },<br/>  "litellm_master_key": {<br/>    "content_type": "text/plain",<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z",<br/>    "length": 32,<br/>    "name": "litellm-master-key",<br/>    "rotation_counter": 0,<br/>    "special": false<br/>  },<br/>  "litellm_salt_key": {<br/>    "content_type": "text/plain",<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z",<br/>    "length": 32,<br/>    "name": "litellm-salt-key",<br/>    "rotation_counter": 0,<br/>    "special": false<br/>  },<br/>  "rabbitmq_password_chat": {<br/>    "content_type": "text/plain",<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z",<br/>    "length": 24,<br/>    "name": "rabbitmq-password-chat",<br/>    "rotation_counter": 0,<br/>    "special": false<br/>  },<br/>  "zitadel_db_user_password": {<br/>    "content_type": "text/plain",<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z",<br/>    "length": 32,<br/>    "name": "zitadel-db-user-password",<br/>    "rotation_counter": 0,<br/>    "special": false<br/>  },<br/>  "zitadel_main_key": {<br/>    "content_type": "text/plain",<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z",<br/>    "length": 32,<br/>    "name": "zitadel-main-key",<br/>    "rotation_counter": 0,<br/>    "special": false<br/>  }<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_manual_secrets_created"></a> [manual\_secrets\_created](#output\_manual\_secrets\_created) | List of names of secrets created in the core key vault. |
<!-- END_TF_DOCS -->

## Compatibility

| Module Version | Compatibility |
|---|---|
| `> 1.0.0` | `unique.ai`: `~> 2025.16` |

## Upgrading

### ~> `2.0.0`

Module was not used by anyone except a test tenant. Sticking to semver, we mark it as breaking change.
