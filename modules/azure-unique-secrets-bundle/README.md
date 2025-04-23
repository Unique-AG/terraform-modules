# Azure Unique Secrets Bundle

> [!TIP]
> This module is for convenience. You can easily manage all necessary secrets yourself.

## Versioning
Compared to the rest of the modules, this module follows the current Unique Release Versioning which roughly is: `YEAR.CalendarWeek`. Per se it is SemVer with very large increments.

## Pre-requisites
- The executing principal needs at least `Key Vault Secrets Officer` permissions on both Key Vaults

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
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault_secret.manual_secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_secrets_placeholders"></a> [default\_secrets\_placeholders](#input\_default\_secrets\_placeholders) | List of secrets that are manually created and need to be placed in the core key vault. The manual- prefix is prepended automatically. | <pre>map(object({<br/>    create          = optional(bool, true)<br/>    expiration_date = optional(string, "2099-12-31T23:59:59Z")<br/>  }))</pre> | <pre>{<br/>  "alertmanager-slack-webhook-url": {<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z"<br/>  },<br/>  "docker-io-pat": {<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z"<br/>  },<br/>  "docker-io-username": {<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z"<br/>  },<br/>  "github-app-private-key": {<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z"<br/>  },<br/>  "litellm-anthropic-api-key": {<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z"<br/>  },<br/>  "litellm-bedrock-access-key": {<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z"<br/>  },<br/>  "litellm-bedrock-secret-key": {<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z"<br/>  },<br/>  "litellm-gemini-api-key": {<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z"<br/>  },<br/>  "litellm-openai-api-key": {<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z"<br/>  },<br/>  "litellm-together-ai-api-key": {<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z"<br/>  },<br/>  "litellm-voyage-api-key": {<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z"<br/>  },<br/>  "quartr-api-creds": {<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z"<br/>  },<br/>  "uniqueapp-azurecr-io-password": {<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z"<br/>  },<br/>  "uniqueapp-azurecr-io-username": {<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z"<br/>  },<br/>  "zitadel-scope-mgmt-pat": {<br/>    "create": true,<br/>    "expiration_date": "2099-12-31T23:59:59Z"<br/>  }<br/>}</pre> | no |
| <a name="input_extra_secrets_placeholders"></a> [extra\_secrets\_placeholders](#input\_extra\_secrets\_placeholders) | List of secrets that are additionally, manually created and need to be placed in the core key vault. The manual- prefix is prepended automatically. | <pre>map(object({<br/>    expiration_date = optional(string, "2099-12-31T23:59:59Z")<br/>  }))</pre> | `{}` | no |
| <a name="input_kv_id_core"></a> [kv\_id\_core](#input\_kv\_id\_core) | The ID of the core key vault, all manually created secrets will be placed here. | `string` | n/a | yes |
| <a name="input_kv_id_sensitive"></a> [kv\_id\_sensitive](#input\_kv\_id\_sensitive) | The ID of the sensitive key vault, all automatically generated secrets will be stored here. | `string` | n/a | yes |
| <a name="input_secrets_to_create"></a> [secrets\_to\_create](#input\_secrets\_to\_create) | List of secrets that are automatically generated and need to be placed in the sensitive key vault. Increment a counter to rotate the secret. | <pre>map(object({<br/>    rabbitmq_password_chat = object({<br/>      create           = optional(bool, true)<br/>      name             = optional(string, "rabbitmq-password-chat")<br/>      content_type     = optional(string, "text/plain")<br/>      special          = optional(bool, false)<br/>      length           = optional(number, 24)<br/>      rotation_counter = optional(number, 0)<br/>      expiration_date  = optional(string, "2099-12-31T23:59:59Z")<br/>    })<br/>    zitadel_main_key = object({<br/>      create           = optional(bool, true)<br/>      name             = optional(string, "zitadel-main-key")<br/>      content_type     = optional(string, "text/plain")<br/>      special          = optional(bool, false)<br/>      length           = optional(number, 32)<br/>      rotation_counter = optional(number, 0)<br/>      expiration_date  = optional(string, "2099-12-31T23:59:59Z")<br/>    })<br/>    zitadel_db_user_password = object({<br/>      create           = optional(bool, true)<br/>      name             = optional(string, "zitadel-db-user-password")<br/>      content_type     = optional(string, "text/plain")<br/>      special          = optional(bool, false)<br/>      length           = optional(number, 32)<br/>      rotation_counter = optional(number, 0)<br/>      expiration_date  = optional(string, "2099-12-31T23:59:59Z")<br/>    })<br/>    encryption_key_ingestion = object({<br/>      create           = optional(bool, true)<br/>      name             = optional(string, "encryption-key-ingestion")<br/>      content_type     = optional(string, "text/plain")<br/>      byte_length      = optional(number, 32)<br/>      rotation_counter = optional(number, 0)<br/>      expiration_date  = optional(string, "2099-12-31T23:59:59Z")<br/>    })<br/>    encryption_key_node_chat_lxm = object({<br/>      create           = optional(bool, true)<br/>      name             = optional(string, "encryption-key-node-chat-lxm")<br/>      content_type     = optional(string, "text/plain")<br/>      byte_length      = optional(number, 32)<br/>      rotation_counter = optional(number, 0)<br/>      expiration_date  = optional(string, "2099-12-31T23:59:59Z")<br/>    })<br/>    encryption_app_repository = object({<br/>      create           = optional(bool, true)<br/>      name             = optional(string, "encryption-app-repository")<br/>      content_type     = optional(string, "text/plain")<br/>      special          = optional(bool, false)<br/>      length           = optional(number, 32)<br/>      rotation_counter = optional(number, 0)<br/>      expiration_date  = optional(string, "2099-12-31T23:59:59Z")<br/>    })<br/>    litellm_master_key = object({<br/>      create           = optional(bool, true)<br/>      name             = optional(string, "litellm-master-key")<br/>      content_type     = optional(string, "text/plain")<br/>      special          = optional(bool, false)<br/>      length           = optional(number, 32)<br/>      rotation_counter = optional(number, 0)<br/>      expiration_date  = optional(string, "2099-12-31T23:59:59Z")<br/>    })<br/>    litellm_salt_key = object({<br/>      create           = optional(bool, true)<br/>      name             = optional(string, "litellm-salt-key")<br/>      content_type     = optional(string, "text/plain")<br/>      special          = optional(bool, false)<br/>      length           = optional(number, 32)<br/>      rotation_counter = optional(number, 0)<br/>      expiration_date  = optional(string, "2099-12-31T23:59:59Z")<br/>    })<br/>    scope_management_encryption_key_1 = object({<br/>      create           = optional(bool, true)<br/>      name             = optional(string, "scope-management-encryption-key-1")<br/>      content_type     = optional(string, "text/plain")<br/>      byte_length      = optional(number, 32)<br/>      rotation_counter = optional(number, 0)<br/>      expiration_date  = optional(string, "2099-12-31T23:59:59Z")<br/>    })<br/>    scope_management_encryption_key_2 = object({<br/>      create           = optional(bool, true)<br/>      name             = optional(string, "scope-management-encryption-key-2")<br/>      content_type     = optional(string, "text/plain")<br/>      byte_length      = optional(number, 32)<br/>      rotation_counter = optional(number, 0)<br/>      expiration_date  = optional(string, "2099-12-31T23:59:59Z")<br/>    })<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_manual_secrets_created"></a> [manual\_secrets\_created](#output\_manual\_secrets\_created) | List of names of secrets created in the core key vault. |
<!-- END_TF_DOCS -->