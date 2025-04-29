# Azure document intelligence

## Pre-requisites
- To deploy this module, you have at least the following permissions:
    + Reader of the subscription
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
| [azurerm_cognitive_account.aca](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account) | resource |
| [azurerm_key_vault_secret.azure_document_intelligence_endpoint_definitions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.azure_document_intelligence_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_private_endpoint.pe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accounts"></a> [accounts](#input\_accounts) | values for the cognitive accounts | <pre>map(object({<br/>    location                      = string<br/>    account_kind                  = optional(string, "FormRecognizer")<br/>    account_sku_name              = optional(string, "S0")<br/>    custom_subdomain_name         = optional(string)<br/>    local_auth_enabled            = optional(bool, false)<br/>    public_network_access_enabled = optional(bool, false)<br/>    private_endpoint = optional(object({<br/>      private_dns_zone_id = string<br/>      subnet_id           = string<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_doc_intelligence_name"></a> [doc\_intelligence\_name](#input\_doc\_intelligence\_name) | The name prefix for the cognitive accounts | `string` | n/a | yes |
| <a name="input_endpoint_definitions_secret_name"></a> [endpoint\_definitions\_secret\_name](#input\_endpoint\_definitions\_secret\_name) | Name of the secret for the endpoint definitions | `string` | `"azure-document-intelligence-endpoint-definitions"` | no |
| <a name="input_endpoints_secret_name"></a> [endpoints\_secret\_name](#input\_endpoints\_secret\_name) | Name of the secret for the endpoints | `string` | `"azure-document-intelligence-endpoints"` | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | The ID of the Key Vault where to store the secrets. If not set, the secrets will not be stored in the Key Vault | `string` | `null` | no |
| <a name="input_primary_access_key_secret_name_suffix"></a> [primary\_access\_key\_secret\_name\_suffix](#input\_primary\_access\_key\_secret\_name\_suffix) | The suffix of the secret name where the Primary Access Key is stored for the Cognitive Account. The secret name will be Cognitive Account Name + this suffix | `string` | `"-key"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azure_document_intelligence_endpoint_definitions"></a> [azure\_document\_intelligence\_endpoint\_definitions](#output\_azure\_document\_intelligence\_endpoint\_definitions) | Object containing list of objects containing endpoint definitions with name, endpoint and location |
| <a name="output_azure_document_intelligence_endpoints"></a> [azure\_document\_intelligence\_endpoints](#output\_azure\_document\_intelligence\_endpoints) | Object containing list of endpoints |
| <a name="output_endpoint_definitions_secret_name"></a> [endpoint\_definitions\_secret\_name](#output\_endpoint\_definitions\_secret\_name) | Name of the secret containing the list of objects containing endpoint definitions with name, endpoint and location (content of `azure_document_intelligence_endpoint_definitions` output). Returns null if Key Vault integration is disabled |
| <a name="output_endpoints_secret_name"></a> [endpoints\_secret\_name](#output\_endpoints\_secret\_name) | Name of the secret containing the list of endpoints. Returns null if Key Vault integration is disabled |
| <a name="output_keys_secret_names"></a> [keys\_secret\_names](#output\_keys\_secret\_names) | List of names of the secrets containing the primary access key to connect to the endpoints. Returns null if Key Vault integration is disabled |
| <a name="output_primary_access_keys"></a> [primary\_access\_keys](#output\_primary\_access\_keys) | The primary access key of the Cognitive Services Account |
<!-- END_TF_DOCS -->

## Compatibility

| Module Version | Compatibility |
|---|---|
| `> 3.0.0` | `unique.ai`: `~> 2025.16` |

## Upgrading

### ~> `3.0.0`

- removes support for `user_assigned_identity_ids`, property was not actively used as the resource does not perform any action/uses its identity
- `accounts.[].local_auth_enabled` and `accounts.[].public_network_access_enabled` default to `false`, set them to `true` to allow public access or key authentication (discouraged for secure by default setups)