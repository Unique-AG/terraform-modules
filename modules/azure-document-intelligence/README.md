# Azure document intelligence

## Pre-requisites
- To deploy this module, you have at least the following permissions:
    + Reader of the subscription
    + Contributor of the resource group

## [Examples](./examples)


# Module

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_cognitive_account.aca](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account) | resource |
| [azurerm_key_vault_secret.azure_document_intelligence_endpoint_definitions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.azure_document_intelligence_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accounts"></a> [accounts](#input\_accounts) | values for the cognitive accounts | <pre>map(object({<br/>    location              = string<br/>    account_kind          = optional(string, "FormRecognizer")<br/>    account_sku_name      = optional(string, "S0")<br/>    custom_subdomain_name = optional(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_doc_intelligence_name"></a> [doc\_intelligence\_name](#input\_doc\_intelligence\_name) | The name prefix for the cognitive accounts | `string` | n/a | yes |
| <a name="input_key_vault_output_settings"></a> [key\_vault\_output\_settings](#input\_key\_vault\_output\_settings) | n/a | <pre>object({<br/>    key_vault_output_enabled              = optional(boolean, true)<br/>    key_vault_id                          = string<br/>    endpoint_definitions_secret_name      = optional(string, "azure-document-intelligence-endpoint-definitions")<br/>    endpoints_secret_name                 = optional(string, "azure-document-intelligence-endpoints")<br/>    primary_access_key_secret_name_suffix = optional(list(string), "-key")<br/>  })</pre> | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource | `map(string)` | n/a | yes |
| <a name="input_user_assigned_identity_ids"></a> [user\_assigned\_identity\_ids](#input\_user\_assigned\_identity\_ids) | values for the user assigned identities | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azure_document_intelligence_endpoint_definitions"></a> [azure\_document\_intelligence\_endpoint\_definitions](#output\_azure\_document\_intelligence\_endpoint\_definitions) | n/a |
| <a name="output_azure_document_intelligence_endpoints"></a> [azure\_document\_intelligence\_endpoints](#output\_azure\_document\_intelligence\_endpoints) | n/a |
| <a name="output_primary_access_keys"></a> [primary\_access\_keys](#output\_primary\_access\_keys) | The primary access key of the Cognitive Services Account |
<!-- END_TF_DOCS -->
