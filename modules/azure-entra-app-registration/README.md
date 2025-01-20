<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 3.1 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.15 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | ~> 3.1 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.15 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.6 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_app_role_assignment.maintainers](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_application.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_app_role.maintainers](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_app_role) | resource |
| [azuread_application_password.aad_app_password](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password) | resource |
| [azuread_service_principal.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurerm_key_vault_secret.aad_app_gitops_client_id](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.aad_app_gitops_client_secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [random_uuid.maintainers](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aad-app-secret-display-name"></a> [aad-app-secret-display-name](#input\_aad-app-secret-display-name) | The displayed name in kv | `string` | n/a | yes |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | The displayed name in Entra | `string` | n/a | yes |
| <a name="input_keyvault_id"></a> [keyvault\_id](#input\_keyvault\_id) | Keyvault where to store the app credentials | `string` | n/a | yes |
| <a name="input_maintainers_principal_object_ids"></a> [maintainers\_principal\_object\_ids](#input\_maintainers\_principal\_object\_ids) | The object ids of the user/groups/service\_principal | `list(string)` | n/a | yes |
| <a name="input_owner_user_object_ids"></a> [owner\_user\_object\_ids](#input\_owner\_user\_object\_ids) | n/a | `list(string)` | `[]` | no |
| <a name="input_redirect_uris"></a> [redirect\_uris](#input\_redirect\_uris) | Authorized redirects | `list(string)` | `[]` | no |
| <a name="input_redirect_uris_public_native"></a> [redirect\_uris\_public\_native](#input\_redirect\_uris\_public\_native) | Public client/native (mobile & desktop) redirects | `list(string)` | `[]` | no |
| <a name="input_required_resource_access_list"></a> [required\_resource\_access\_list](#input\_required\_resource\_access\_list) | A map of resource\_app\_ids with their access configurations. | <pre>map(list(object({<br/>    id   = string<br/>    type = string<br/>  })))</pre> | <pre>{<br/>  "00000003-0000-0000-c000-000000000000": [<br/>    {<br/>      "id": "14dad69e-099b-42c9-810b-d002981feec1",<br/>      "type": "Scope"<br/>    },<br/>    {<br/>      "id": "e1fe6dd8-ba31-4d61-89e7-88639da4683d",<br/>      "type": "Scope"<br/>    },<br/>    {<br/>      "id": "37f7f235-527c-4136-accd-4a02d197296e",<br/>      "type": "Scope"<br/>    },<br/>    {<br/>      "id": "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0",<br/>      "type": "Scope"<br/>    }<br/>  ]<br/>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
