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
| [azuread_app_role_assignment.application_support](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_app_role_assignment.infrastructure_support](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_app_role_assignment.maintainers](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_app_role_assignment.system_support](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_app_role_assignment.user](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_application.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_app_role.application_support](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_app_role) | resource |
| [azuread_application_app_role.infrastructure_support](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_app_role) | resource |
| [azuread_application_app_role.maintainers](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_app_role) | resource |
| [azuread_application_app_role.system_support](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_app_role) | resource |
| [azuread_application_app_role.user](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_app_role) | resource |
| [azuread_application_password.aad_app_password](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password) | resource |
| [azuread_service_principal.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurerm_key_vault_secret.aad_app_gitops_client_id](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.aad_app_gitops_client_secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [random_uuid.application_support](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [random_uuid.infrastructure_support](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [random_uuid.maintainers](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [random_uuid.system_support](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [random_uuid.user](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_support_object_ids"></a> [application\_support\_object\_ids](#input\_application\_support\_object\_ids) | The object ids of the user/groups that should be able to support the application. | `list(string)` | `[]` | no |
| <a name="input_client_secret_generation_config"></a> [client\_secret\_generation\_config](#input\_client\_secret\_generation\_config) | When enabled, a client secret will be generated and stored in the keyvault. | <pre>object({<br/>    enabled     = bool<br/>    keyvault_id = optional(string)<br/>    secret_name = optional(string, "entra-app-client-secret")<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | The displayed name in Entra ID. | `string` | n/a | yes |
| <a name="input_infrastructure_support_object_ids"></a> [infrastructure\_support\_object\_ids](#input\_infrastructure\_support\_object\_ids) | The object ids of the user/groups that should be able to support the infrastructure of the platform. Roles trickle down so this role includes both system and application support. | `list(string)` | `[]` | no |
| <a name="input_owner_user_object_ids"></a> [owner\_user\_object\_ids](#input\_owner\_user\_object\_ids) | n/a | `list(string)` | `[]` | no |
| <a name="input_redirect_uris"></a> [redirect\_uris](#input\_redirect\_uris) | Authorized redirects | `list(string)` | `[]` | no |
| <a name="input_redirect_uris_public_native"></a> [redirect\_uris\_public\_native](#input\_redirect\_uris\_public\_native) | Public client/native (mobile & desktop) redirects | `list(string)` | `[]` | no |
| <a name="input_required_resource_access_list"></a> [required\_resource\_access\_list](#input\_required\_resource\_access\_list) | A map of resource\_app\_ids with their access configurations. | <pre>map(list(object({<br/>    id   = string<br/>    type = string<br/>  })))</pre> | <pre>{<br/>  "00000003-0000-0000-c000-000000000000": [<br/>    {<br/>      "id": "14dad69e-099b-42c9-810b-d002981feec1",<br/>      "type": "Scope"<br/>    },<br/>    {<br/>      "id": "e1fe6dd8-ba31-4d61-89e7-88639da4683d",<br/>      "type": "Scope"<br/>    },<br/>    {<br/>      "id": "37f7f235-527c-4136-accd-4a02d197296e",<br/>      "type": "Scope"<br/>    },<br/>    {<br/>      "id": "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0",<br/>      "type": "Scope"<br/>    }<br/>  ]<br/>}</pre> | no |
| <a name="input_role_assignments_required"></a> [role\_assignments\_required](#input\_role\_assignments\_required) | Whether role assignments are required to be able to use the app. Least privilege principle encourages true. | `bool` | `true` | no |
| <a name="input_system_support_object_ids"></a> [system\_support\_object\_ids](#input\_system\_support\_object\_ids) | The object ids of the user/groups that should be able to support the system or core of the platform. Roles trickle down so this role includes application support. | `list(string)` | `[]` | no |
| <a name="input_user_object_ids"></a> [user\_object\_ids](#input\_user\_object\_ids) | The object ids of the user/groups that should be able to just use the application/login. | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Compatibility

| Module Version | Compatibility |
|---|---|
| `> 2.1.0` | `unique.ai`: `~> 2025.16` |

## Upgrading

### ~> `3.0.0`

> [!CAUTION]
> Make sure to transition through 3.0.0 in order to not break your applications introducing a chicken-egg problem. Do not skip `3.0.0`.

Version `3.0.0` introduces significant changes to how application roles and permissions are managed, shifting from a single `maintainers` role to a more granular, hierarchical system. It also introduces stricter defaults for role assignments.

#### Role System Change

*   The `maintainers_principal_object_ids` input variable has been **removed**.
*   Three new input variables have been introduced to define access based on support tiers:
    *   `application_support_object_ids`: For users/groups providing direct application support.
    *   `system_support_object_ids`: For users/groups supporting the underlying system/platform. This tier implicitly includes Application Support permissions.
    *   `infrastructure_support_object_ids`: For users/groups supporting the infrastructure. This tier implicitly includes both System and Application Support permissions.
*   **Action Required:** Replace the usage of `maintainers_principal_object_ids` with the appropriate new variable(s) based on the level of access required. For example, if the previous maintainers only needed application-level access, use `application_support_object_ids`.

    ```diff
    module "my_app_registration" {
      source = "github.com/Unique-AG/terraform-modules.git//modules/azure-entra-app-registration?ref=azure-entra-app-registration-3.0.0"

      display_name = "My Application"
    - maintainers_principal_object_ids = ["00000000-0000-0000-0000-000000000001", "00000000-0000-0000-0000-000000000002"]
    + user_object_ids                = ["00000000-0000-0000-0000-000000000002"]
    + application_support_object_ids = ["00000000-0000-0000-0000-000000000001", "00000000-0000-0000-0000-000000000002"]
    + # Optionally add system_support_object_ids = [...]
    + # Optionally add infrastructure_support_object_ids = [...]

      # ... other variables
    }
    ```

#### Backward Compatibility

*   To ease the transition and avoid breaking existing Single Sign-On (SSO) configurations relying on the old `maintain` app role, this role still exists in `3.0.0`.
*   Assignments for this legacy `maintain` role are now automatically created based on the `application_support_object_ids` variable.
*   **Warning:** This legacy `maintain` role and its associated resources will be **removed in version `4.0.0`**. Update your relying applications to use the new roles (`application_support`, `system_support`, `infrastructure_support`) before upgrading to `4.0.0`.

#### Role Assignment Requirement

*   A new boolean variable `role_assignments_required` has been added. It defaults to `true`.
*   When `true`, users must be assigned one of the defined app roles (`application_support`, `system_support`, or `infrastructure_support`) to successfully sign in to the application. This enforces the principle of least privilege.
*   If you'd like users to just be able to login, use `user_object_ids`.
*   **Action Required:** If your application does *not* require users to have specific roles assigned for login, explicitly set `role_assignments_required = false`.

#### Minor Changes

*   Internal URLs for privacy statements and terms of service have been updated from `unique.ch` to `unique.ai`. This typically requires no action.

Please review your module configurations and update them according to these changes when upgrading to `v3.0.0`.

