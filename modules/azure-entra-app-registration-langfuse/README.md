<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 3.6 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.15 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | ~> 3.6 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.15 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_app_role_assignment.user_role_assignment](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_application.langfuse](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_app_role.user_role](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_app_role) | resource |
| [azuread_application_password.langfuse_password](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password) | resource |
| [azuread_service_principal.langfuse](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azuread_service_principal.msgraph](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurerm_key_vault_secret.client_id](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.client_secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azuread_application_published_app_ids.well_known](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/application_published_app_ids) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_role"></a> [app\_role](#input\_app\_role) | The app role to assign to the application. All more detailed roles have to be assigned manually. | <pre>object({<br/>    role_id      = optional(string, "6a902661-cfac-44f4-846c-bc5ceaa012d4")<br/>    description  = optional(string, "User, allows to use the application or login without any additional permissions.")<br/>    display_name = optional(string, "User")<br/>    value        = optional(string, "user")<br/>    members      = optional(set(string), [])<br/>  })</pre> | n/a | yes |
| <a name="input_client_secret_generation_config"></a> [client\_secret\_generation\_config](#input\_client\_secret\_generation\_config) | When enabled, a client secret will be generated and stored in the keyvault. | <pre>object({<br/>    keyvault_id     = optional(string)<br/>    secret_name     = optional(string, "langfuse-client-secret")<br/>    expiration_date = optional(string, "2099-12-31T23:59:59Z")<br/>  })</pre> | `{}` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | The display name for the Azure AD application registration. | `string` | n/a | yes |
| <a name="input_homepage_url"></a> [homepage\_url](#input\_homepage\_url) | The homepage url of the app. | `string` | n/a | yes |
| <a name="input_redirect_uris"></a> [redirect\_uris](#input\_redirect\_uris) | Authorized redirects. Has to be in format https://yourapplication.com/api/auth/callback/azure-ad | `list(string)` | n/a | yes |
| <a name="input_role_assignments_required"></a> [role\_assignments\_required](#input\_role\_assignments\_required) | Whether role assignments are required to be able to use the app. Least privilege principle encourages true. | `bool` | `true` | no |
| <a name="input_sign_in_audience"></a> [sign\_in\_audience](#input\_sign\_in\_audience) | The Microsoft identity platform audiences that are supported by this application. Valid values are 'AzureADMyOrg', 'AzureADMultipleOrgs', 'AzureADandPersonalMicrosoftAccount', or 'PersonalMicrosoftAccount'. We default to AzureADMultipleOrgs as it's the most common use case. Stricter setups can revert back to 'AzureADMyOrg'. | `string` | `"AzureADMultipleOrgs"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_id"></a> [application\_id](#output\_application\_id) | The application ID (object ID) of the Azure AD application |
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | The application (client) ID of the Azure AD application |
| <a name="output_client_id_key_vault_secret_id"></a> [client\_id\_key\_vault\_secret\_id](#output\_client\_id\_key\_vault\_secret\_id) | The ID of the Key Vault secret containing the client ID |
| <a name="output_client_secret_key_vault_secret_id"></a> [client\_secret\_key\_vault\_secret\_id](#output\_client\_secret\_key\_vault\_secret\_id) | The ID of the Key Vault secret containing the client secret |
<!-- END_TF_DOCS -->