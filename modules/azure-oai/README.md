
# Azure OAI

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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cognitive_accounts"></a> [cognitive\_accounts](#input\_cognitive\_accounts) | Map of cognitive accounts | <pre>map(object({<br/>    name                          = string<br/>    location                      = string<br/>    kind                          = optional(string, "OpenAI")<br/>    sku_name                      = optional(string, "S0")<br/>    local_auth_enabled            = optional(bool, false)<br/>    public_network_access_enabled = optional(bool, false)<br/><br/>    custom_subdomain_name = optional(string, "S0")<br/><br/>  }))</pre> | <pre>{<br/>  "cognitive-account-switzerlandnorth": {<br/>    "location": "switzerlandnorth",<br/>    "name": "cognitive-account-switzerlandnorth"<br/>  }<br/>}</pre> | no |
| <a name="input_cognitive_deployments"></a> [cognitive\_deployments](#input\_cognitive\_deployments) | Map of deployments with model details, location, and custom subdomain name | <pre>map(object({<br/>    name                   = string<br/>    model_name             = string<br/>    model_version          = string<br/>    sku_capacity           = number<br/>    sku_type               = optional(string, "Standard")<br/>    location               = string<br/>    custom_subdomain_name  = optional(string)<br/>    cognitive_account      = string<br/>    rai_policy_name        = optional(string)<br/>    version_upgrade_option = optional(string, "NoAutoUpgrade")<br/>    deployment_format      = optional(string, "OpenAI")<br/>  }))</pre> | <pre>{<br/>  "gpt-4-switzerlandnorth": {<br/>    "cognitive_account": "cognitive-account-switzerlandnorth",<br/>    "location": "switzerlandnorth",<br/>    "model_name": "gpt-4",<br/>    "model_version": "0613",<br/>    "name": "gpt-4",<br/>    "sku_capacity": 20<br/>  },<br/>  "text-embedding-ada-002-switzerlandnorth": {<br/>    "cognitive_account": "cognitive-account-switzerlandnorth",<br/>    "location": "switzerlandnorth",<br/>    "model_name": "text-embedding-ada-002",<br/>    "model_version": "2",<br/>    "name": "text-embedding-ada-002",<br/>    "sku_capacity": 350<br/>  }<br/>}</pre> | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags for the resource | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cognitive_account_endpoints"></a> [cognitive\_account\_endpoints](#output\_cognitive\_account\_endpoints) | The endpoints used to connect to the Cognitive Service Account. |
| <a name="output_model_version_endpoints"></a> [model\_version\_endpoints](#output\_model\_version\_endpoints) | Map of endpoints where 'model\_name-model\_version is the key and endpoint is the value' |
| <a name="output_primary_access_keys"></a> [primary\_access\_keys](#output\_primary\_access\_keys) | A primary access keys which can be used to connect to the Cognitive Service Accounts. |
<!-- END_TF_DOCS -->