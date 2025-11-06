
# Azure openai

## Pre-requisites
- To deploy this module, you have at least the following permissions:
    + Reader of the subscription

## [Examples](./examples)

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
| [azurerm_cognitive_deployment.deployments](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_deployment) | resource |
| [azurerm_key_vault_secret.endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.model_version_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_private_endpoint.pe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cognitive_accounts"></a> [cognitive\_accounts](#input\_cognitive\_accounts) | Map of cognitive accounts, refer to the README for more details. | <pre>map(object({<br/>    custom_subdomain_name                    = string<br/>    kind                                     = optional(string, "OpenAI")<br/>    local_auth_enabled                       = optional(bool, false)<br/>    location                                 = string<br/>    model_definitions_auth_strategy_injected = optional(string, "WorkloadIdentity")<br/>    name                                     = string<br/>    public_network_access_enabled            = optional(bool, false)<br/>    sku_name                                 = optional(string, "S0")<br/><br/>    private_endpoint = optional(object({<br/>      private_dns_zone_id = string<br/>      subnet_id           = string<br/>      vnet_location       = optional(string)<br/>    }))<br/><br/>    cognitive_deployments = list(object({<br/>      model_format           = optional(string, "OpenAI")<br/>      model_name             = string<br/>      model_version          = string<br/>      name                   = string<br/>      rai_policy_name        = optional(string, "Microsoft.Default")<br/>      sku_capacity           = number<br/>      sku_name               = optional(string, "Standard")<br/>      version_upgrade_option = optional(string, "NoAutoUpgrade")<br/>    }))<br/><br/>  }))</pre> | n/a | yes |
| <a name="input_endpoint_definitions_secret"></a> [endpoint\_definitions\_secret](#input\_endpoint\_definitions\_secret) | Name of the secret for the endpoint definitions | <pre>object({<br/>    expiration_date = optional(string, "2099-12-31T23:59:59Z")<br/>    extra_tags      = optional(map(string), {})<br/>    name            = optional(string, "azure-openai-endpoint-definitions")<br/><br/>    # https://learn.microsoft.com/en-us/azure/ai-foundry/openai/quotas-limits<br/>    sku_capacity_field_name = optional(string, "tpmThousands") # the sku_capacity field is very technical, to further process the field, we use the correct unit name<br/>    sku_name_field_name     = optional(string, "usageTier")    # the sku_name field is very technical, to further process the field, we use the correct term from the Azure Docs<br/>  })</pre> | `{}` | no |
| <a name="input_endpoint_secret"></a> [endpoint\_secret](#input\_endpoint\_secret) | Configuration for the endpoint secret | <pre>object({<br/>    expiration_date = optional(string, "2099-12-31T23:59:59Z")<br/>    extra_tags      = optional(map(string), {})<br/>    name_suffix     = optional(string, "-endpoint")<br/>  })</pre> | `{}` | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | The ID of the Key Vault where to store the secrets. If not set, the secrets will not be stored in a Key Vault | `any` | `null` | no |
| <a name="input_primary_access_key_secret"></a> [primary\_access\_key\_secret](#input\_primary\_access\_key\_secret) | Configuration for the primary access key secret. Created per account and is populated with a placeholder if model\_definitions\_auth\_strategy\_injected is 'ApiKey' and local\_auth\_enabled is false. | <pre>object({<br/>    expiration_date = optional(string, "2099-12-31T23:59:59Z")<br/>    extra_tags      = optional(map(string), {})<br/>    name_suffix     = optional(string, "-key")<br/>  })</pre> | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags for the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cognitive_account_endpoints"></a> [cognitive\_account\_endpoints](#output\_cognitive\_account\_endpoints) | The endpoints used to connect to the Cognitive Service Account. |
| <a name="output_cognitive_account_resources"></a> [cognitive\_account\_resources](#output\_cognitive\_account\_resources) | Map of Cognitive Service Accounts where keys are the account names. |
| <a name="output_endpoints_secret_names"></a> [endpoints\_secret\_names](#output\_endpoints\_secret\_names) | List of secret names containing the endpoints for each Cognitive Service Account. Returns null if Key Vault integration is disabled. |
| <a name="output_keys_secret_names"></a> [keys\_secret\_names](#output\_keys\_secret\_names) | List of secret names containing the access keys for each Cognitive Service Account. Returns null if Key Vault integration is disabled. |
| <a name="output_model_version_endpoint_secret_name"></a> [model\_version\_endpoint\_secret\_name](#output\_model\_version\_endpoint\_secret\_name) | Name of the secret containing the model version endpoint definitions. Returns null if Key Vault integration is disabled. |
| <a name="output_model_version_endpoints"></a> [model\_version\_endpoints](#output\_model\_version\_endpoints) | List of objects containing endpoint, location and list of models |
| <a name="output_primary_access_keys"></a> [primary\_access\_keys](#output\_primary\_access\_keys) | A primary access keys which can be used to connect to the Cognitive Service Accounts. |
<!-- END_TF_DOCS -->

## Input `cognitive_accounts`

To keep the module compatible with a range of Unique versions and iterations as well as features, the flexibility to manage secrets is quite large.

The module itself defaults to the most secure variants including allowing only Workload Identity connections. For legacy components or features you can use the following flags per account to achieve the desired behaviour:

|Flag|Behaviour|
|-|-
`public_network_access_enabled`|defines, whether the accounts are exposed to the internet / public network
|-|-
`local_auth_enabled`|defines, whether key authentication is enabled or not
`model_definitions_auth_strategy_injected`|Only takes effect when `local_auth_enabled` is `true`.<br/>Can be either `WorkloadIdentity` (injects the `WORKLOAD_IDENTITY` constant as key) or `ApiKey` (injects the API Key).

> [!TIP]
> All secrets and/or definitions are only created if a `keyvault_id` is passed!

> [!WARNING]
> Switching from `WorkloadIdentity` to `ApiKey` needs two applies. This is due to the fact that an account with `local_auth_enabled = false` has no API Key at first. So the first apply puts the placeholder into both the Key Vault and potentially the definitions while the second apply actually replaces the placeholder with the real key. If any of the key places contains `<API_KEY_NOT_AVAILABLE>` it means either `local_auth` is disabled or the account does not yet have a key at all.

### `cognitive_accounts.*.private_endpoint.vnet_location`

With `>=2.4.0` Private Endpoints can be provisioned in a separate location. Supplying the variable is mandatory if the VNet resides in another location than the Cognitive Account itself.

## Upgrading

### `~> 3.0.0`

1. **Remove `cognitive_account_tags`**: Merge any values into `tags` instead.
   ```hcl
   # Before
   cognitive_account_tags = { "env" = "prod" }
   tags = { "team" = "ai" }
   
   # After
   tags = { "env" = "prod", "team" = "ai" }
   ```

2. **Update secret name variables**: Replace string variables with structured objects.
   ```hcl
   # Before
   primary_access_key_secret_name_suffix = "-key"
   endpoint_secret_name_suffix = "-endpoint"
   endpoint_definitions_secret_name = "azure-openai-endpoint-definitions"
   
   # After
   primary_access_key_secret = {
     name_suffix = "-key"
   }
   endpoint_secret = {
     name_suffix = "-endpoint"
   }
   endpoint_definitions_secret = {
     name = "azure-openai-endpoint-definitions"
   }
   ```

3. **Update SKU type to name**: Rename sku_type to sku_name.
   ```hcl
   # Before
   {
     sku_type    = "Standard"
   }
   
   # After
   {
     sku_name    = "Standard"
   }
   ```
