# `azure-entra-sp-create-for-rbac`

This is the terraform variant of the often seen [`az ad sp create-for-rbac`](https://learn.microsoft.com/en-us/cli/azure/ad/sp?view=azure-cli-latest#az-ad-sp-create-for-rbac).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | ~> 3 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4 |
| <a name="provider_time"></a> [time](#provider\_time) | ~> 0.13 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_application.sp_for_rbac](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_password.sp_for_rbac_password](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password) | resource |
| [azuread_service_principal.sp_for_rbac](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurerm_key_vault_secret.client_id](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.client_secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [time_rotating.sp_for_rbac_password](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_client_secret_generation_config"></a> [client\_secret\_generation\_config](#input\_client\_secret\_generation\_config) | When enabled, a client secret will be generated and stored in the keyvault. | <pre>object({<br/>    keyvault_id     = optional(string)<br/>    secret_name     = optional(string, "sp-create-for-rbac")<br/>    expiration_date = optional(string, "2099-12-31T23:59:59Z")<br/>  })</pre> | `{}` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | The display name for the Create-For-RBAC Service Principal. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | The client ID of the underlying Azure Entra App Registration. |
| <a name="output_object_id"></a> [object\_id](#output\_object\_id) | The object ID of the matching Service Principal to be used for effective role assignments. |
<!-- END_TF_DOCS -->
