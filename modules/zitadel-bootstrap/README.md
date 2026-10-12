<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_zitadel"></a> [zitadel](#requirement\_zitadel) | = 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
| <a name="provider_zitadel"></a> [zitadel](#provider\_zitadel) | = 3.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [terraform_data.bootstrap_guard](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [zitadel_application_oidc.standalone_apps](https://registry.terraform.io/providers/zitadel/zitadel/3.4.0/docs/resources/application_oidc) | resource |
| [zitadel_human_user.this](https://registry.terraform.io/providers/zitadel/zitadel/3.4.0/docs/resources/human_user) | resource |
| [zitadel_instance_member.scope_management](https://registry.terraform.io/providers/zitadel/zitadel/3.4.0/docs/resources/instance_member) | resource |
| [zitadel_machine_user.scope_management](https://registry.terraform.io/providers/zitadel/zitadel/3.4.0/docs/resources/machine_user) | resource |
| [zitadel_org.target](https://registry.terraform.io/providers/zitadel/zitadel/3.4.0/docs/resources/org) | resource |
| [zitadel_personal_access_token.scope_management](https://registry.terraform.io/providers/zitadel/zitadel/3.4.0/docs/resources/personal_access_token) | resource |
| [zitadel_project.unique_apps](https://registry.terraform.io/providers/zitadel/zitadel/3.4.0/docs/resources/project) | resource |
| [zitadel_project_grant.target](https://registry.terraform.io/providers/zitadel/zitadel/3.4.0/docs/resources/project_grant) | resource |
| [zitadel_project_role.unique_apps](https://registry.terraform.io/providers/zitadel/zitadel/3.4.0/docs/resources/project_role) | resource |
| [zitadel_user_grant.this](https://registry.terraform.io/providers/zitadel/zitadel/3.4.0/docs/resources/user_grant) | resource |
| [zitadel_organizations.root](https://registry.terraform.io/providers/zitadel/zitadel/3.4.0/docs/data-sources/organizations) | data source |
| [zitadel_organizations.target](https://registry.terraform.io/providers/zitadel/zitadel/3.4.0/docs/data-sources/organizations) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_frontend_base_url"></a> [frontend\_base\_url](#input\_frontend\_base\_url) | Unique frontend origin; the default redirect URI set appends the deployed frontend paths (/chat, /admin, /knowledge-upload, /theme). | `string` | n/a | yes |
| <a name="input_human_users"></a> [human\_users](#input\_human\_users) | Human users created in the target organization, keyed by user name, with the project roles granted to each. Intended for development and trial environments. | <pre>map(object({<br/>    first_name = string<br/>    last_name  = string<br/>    email      = string<br/>    roles      = set(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_human_users_initial_password"></a> [human\_users\_initial\_password](#input\_human\_users\_initial\_password) | Initial password of every user in human\_users. Required when human\_users is not empty. | `string` | `null` | no |
| <a name="input_oidc_dev_mode"></a> [oidc\_dev\_mode](#input\_oidc\_dev\_mode) | Enable OIDC development mode on the Standalone Apps application. Required for plain-HTTP redirect URIs. | `bool` | `false` | no |
| <a name="input_post_logout_redirect_uris"></a> [post\_logout\_redirect\_uris](#input\_post\_logout\_redirect\_uris) | Exact post-logout URI override list. An empty list derives the frontend paths from frontend\_base\_url. | `list(string)` | `[]` | no |
| <a name="input_project_roles"></a> [project\_roles](#input\_project\_roles) | Role keys of the Unique Apps project; all of them are granted to the target organization. | `set(string)` | <pre>[<br/>  "chat.chat.basic",<br/>  "chat.chat.unlimited",<br/>  "chat.knowledge.read",<br/>  "chat.knowledge.write",<br/>  "chat.feedback.read",<br/>  "chat.admin.all",<br/>  "chat.data.admin",<br/>  "chat.debug.read",<br/>  "admin.user-management.write",<br/>  "admin.space.write",<br/>  "admin.app-repository.write",<br/>  "connector.admin.read",<br/>  "connector.admin.write"<br/>]</pre> | no |
| <a name="input_redirect_uris"></a> [redirect\_uris](#input\_redirect\_uris) | Exact redirect URI override list. An empty list derives the frontend paths from frontend\_base\_url. | `list(string)` | `[]` | no |
| <a name="input_root_org_name"></a> [root\_org\_name](#input\_root\_org\_name) | Exact name of the organization created by the ZITADEL Helm chart (FirstInstance.Org.Name) that owns the Unique Apps project. | `string` | `"Cluster IAM"` | no |
| <a name="input_scope_management_pat_expiration_date"></a> [scope\_management\_pat\_expiration\_date](#input\_scope\_management\_pat\_expiration\_date) | RFC3339 expiration of the node-scope-management PAT. An explicit value avoids perpetual replacement after ZITADEL normalizes an omitted one. | `string` | `"9999-12-31T23:59:59Z"` | no |
| <a name="input_scope_management_user_name"></a> [scope\_management\_user\_name](#input\_scope\_management\_user\_name) | Username of the JWT machine user used by node-scope-management. | `string` | `"scope-management"` | no |
| <a name="input_target_org_name"></a> [target\_org\_name](#input\_target\_org\_name) | Exact name of the tenant organization that receives the Unique Apps project grant. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | Client ID of the Standalone Apps PKCE application. |
| <a name="output_human_user_ids"></a> [human\_user\_ids](#output\_human\_user\_ids) | IDs of the created human users, keyed by user name. |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | ID of the Unique Apps project. |
| <a name="output_root_org_id"></a> [root\_org\_id](#output\_root\_org\_id) | ID of the Helm-created root organization. |
| <a name="output_scope_management_pat"></a> [scope\_management\_pat](#output\_scope\_management\_pat) | PAT of the node-scope-management machine user. |
| <a name="output_scope_management_user_id"></a> [scope\_management\_user\_id](#output\_scope\_management\_user\_id) | ID of the node-scope-management JWT machine user. |
| <a name="output_target_org_id"></a> [target\_org\_id](#output\_target\_org\_id) | ID of the tenant organization. |
<!-- END_TF_DOCS -->
