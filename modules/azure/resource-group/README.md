This module is a pet-project to setup the `terraform-modules` repository. Do not use it in production.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.6 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 3.115.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.115.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/3.115.0/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_groups"></a> [resource\_groups](#input\_resource\_groups) | n/a | <pre>map(object({<br/>    location   = string<br/>    managed_by = optional(string, null)<br/>    tags       = optional(map(string), {})<br/>  }))</pre> | <pre>{<br/>  "rg1": {<br/>    "location": "eastus",<br/>    "tags": {<br/>      "environment": "dev"<br/>    }<br/>  },<br/>  "rg2": {<br/>    "location": "westus",<br/>    "tags": {<br/>      "environment": "dev"<br/>    }<br/>  }<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group_ids"></a> [resource\_group\_ids](#output\_resource\_group\_ids) | Map of resource group tags by name |
| <a name="output_resource_group_locations"></a> [resource\_group\_locations](#output\_resource\_group\_locations) | Map of resource group locations by name |
| <a name="output_resource_group_names"></a> [resource\_group\_names](#output\_resource\_group\_names) | List of resource group names created by this configuration |
<!-- END_TF_DOCS -->
