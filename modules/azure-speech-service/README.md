# Azure Speech Service

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
| [azurerm_key_vault_secret.azure_speech_service_endpoint_definitions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.azure_speech_service_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.resource_id](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_monitor_diagnostic_setting.diag](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_network_security_group.nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_private_endpoint.pe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.workload_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accounts"></a> [accounts](#input\_accounts) | values for the cognitive accounts | <pre>map(object({<br/>    location              = string<br/>    account_kind          = optional(string, "SpeechServices")<br/>    account_sku_name      = optional(string, "S0")<br/>    custom_subdomain_name = optional(string)<br/>    identity = optional(object({<br/>      type         = string<br/>      identity_ids = list(string)<br/>    }))<br/>    private_endpoint = optional(object({<br/>      subnet_id           = string<br/>      vnet_id             = string<br/>      private_dns_zone_id = string<br/>    }))<br/>    diagnostic_settings = optional(object({<br/>      log_analytics_workspace_id = string<br/>      enabled_log_categories     = optional(list(string))<br/>      enabled_metrics            = optional(list(string))<br/>    }))<br/>    network_security_group = optional(object({<br/>      security_rules = optional(list(object({<br/>        name                       = string<br/>        priority                   = number<br/>        direction                  = string<br/>        access                     = string<br/>        protocol                   = string<br/>        source_port_range          = optional(string)<br/>        destination_port_range     = optional(string)<br/>        source_address_prefix      = optional(string)<br/>        destination_address_prefix = optional(string)<br/>      })))<br/>    }))<br/>    workload_identity = optional(object({<br/>      principal_id         = string<br/>      role_definition_name = string<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_endpoint_definitions_secret_name"></a> [endpoint\_definitions\_secret\_name](#input\_endpoint\_definitions\_secret\_name) | Name of the secret for the endpoint definitions | `string` | `"azure-document-intelligence-endpoint-definitions"` | no |
| <a name="input_endpoints_secret_name"></a> [endpoints\_secret\_name](#input\_endpoints\_secret\_name) | Name of the secret for the endpoints | `string` | `"azure-document-intelligence-endpoints"` | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | The ID of the Key Vault where to store the secrets. If not set, the secrets will not be stored in the Key Vault | `string` | `null` | no |
| <a name="input_primary_access_key_secret_name_suffix"></a> [primary\_access\_key\_secret\_name\_suffix](#input\_primary\_access\_key\_secret\_name\_suffix) | The suffix of the secret name where the Primary Access Key is stored for the Cognitive Account. The secret name will be Cognitive Account Name + this suffix | `string` | `"-key"` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | The ID of the Private DNS Zone for the Speech Service | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group | `string` | n/a | yes |
| <a name="input_resource_id_secret_name_suffix"></a> [resource\_id\_secret\_name\_suffix](#input\_resource\_id\_secret\_name\_suffix) | Suffix for the resource ID secret name | `string` | `"-resource-id"` | no |
| <a name="input_speech_service_name"></a> [speech\_service\_name](#input\_speech\_service\_name) | The name prefix for the cognitive accounts | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource | `map(string)` | `null` | no |
| <a name="input_user_assigned_identity_ids"></a> [user\_assigned\_identity\_ids](#input\_user\_assigned\_identity\_ids) | values for the user assigned identities | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azure_speech_service_endpoint_definitions"></a> [azure\_speech\_service\_endpoint\_definitions](#output\_azure\_speech\_service\_endpoint\_definitions) | Object containing list of objects containing endpoint definitions with name, endpoint and location |
| <a name="output_azure_speech_service_endpoints"></a> [azure\_speech\_service\_endpoints](#output\_azure\_speech\_service\_endpoints) | Object containing list of endpoints |
| <a name="output_cognitive_account_ids"></a> [cognitive\_account\_ids](#output\_cognitive\_account\_ids) | Resource IDs of the Cognitive Services Accounts |
| <a name="output_endpoint_definitions_secret_name"></a> [endpoint\_definitions\_secret\_name](#output\_endpoint\_definitions\_secret\_name) | Name of the secret containing the list of objects containing endpoint definitions with name, endpoint and location (content of `azure_speech_service_endpoint_definitions` output). Returns null if Key Vault integration is disabled |
| <a name="output_endpoints_secret_name"></a> [endpoints\_secret\_name](#output\_endpoints\_secret\_name) | Name of the secret containing the list of endpoints. Returns null if Key Vault integration is disabled |
| <a name="output_keys_secret_names"></a> [keys\_secret\_names](#output\_keys\_secret\_names) | List of names of the secrets containing the primary access key to connect to the endpoints. Returns null if Key Vault integration is disabled |
| <a name="output_primary_access_keys"></a> [primary\_access\_keys](#output\_primary\_access\_keys) | The primary access key of the Cognitive Services Account |
<!-- END_TF_DOCS -->
