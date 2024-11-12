# Azure Storage Account

<!-- https://mermaid.live/ -->
```mermaid
---
title: azure-storage-account
---
graph LR
    subgraph perimeter
        K[Key] -->|provisioned in| KV[Key Vault]
        RA[Role Assignment] <-->|binds| UAMI[User-Assigned Managed Identity]
        RA -->|"Key: Get,Unwrap,Wrap"| KV
        SANR[Storage Account Network Rules]
    end
    subgraph workloads
        subgraph module["azure-storage-account"]
            SA[Storage Account]
            CMK[Customer-Managed Key]
            CMK[Customer-Managed Key]
            SA -->|uses| CMK
        end
    end
    SANR -.->|_optional_| module
    perimeter --->|key_id<br>identity_id| module
    CMK -->|accesses using User-Assigned Managed Identity| K
```

You can learn in the [Design principles](../../DESIGN.md) about the `perimeter` and `workloads` as well as other design principles.

## Backups
> [!IMPORTANT]
> A module holding a `azurerm_data_protection_backup_vault` will be provided in an upcoming release.

This module does not and will not abstract a Backup Vault because the backup vault highly depends on the Storage Account itself introducing a chicken-egg/_apply first_ problem.

The base for this decision is laid out in [Design principles](../../DESIGN.md) as well.

## Networking

True to the [Design principles](../../DESIGN.md), Network limitations should not be done inside the module. That is why the module does not contain any networking limitations. The consumer should apply the network limitations in the `perimeter` layer, e.g. by using [`azurerm_storage_account_network_rules`](https://registry.terraform.io/providers/hashicorp/azurerm/3.117.0/docs/resources/storage_account_network_rules). The `storage_account_id` can be used to apply the network limitations.

# Module

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
| [azurerm_storage_account.storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account_customer_managed_key.cmk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_customer_managed_key) | resource |
| [azurerm_storage_management_policy.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tier"></a> [access\_tier](#input\_access\_tier) | Type of replication to use for this storage account. Learn more about storage account access tiers in the Azure Docs. Defaults to Cool as the difference is negligible for most use cases but is more cost-efficient. | `string` | `"Cool"` | no |
| <a name="input_account_kind"></a> [account\_kind](#input\_account\_kind) | Kind to use for the storage account. Learn more about storage account kinds in the Azure Docs. | `string` | `"StorageV2"` | no |
| <a name="input_account_replication_type"></a> [account\_replication\_type](#input\_account\_replication\_type) | Type of replication to use for this storage account. Learn more about storage account replication types in the Azure Docs. | `string` | `"ZRS"` | no |
| <a name="input_account_tier"></a> [account\_tier](#input\_account\_tier) | Tier to use for the storage account. Learn more about storage account tiers in the Azure Docs. | `string` | `"Standard"` | no |
| <a name="input_cors_rules"></a> [cors\_rules](#input\_cors\_rules) | CORS rules for the storage account | <pre>list(object({<br/>    allowed_origins    = list(string)<br/>    allowed_methods    = list(string)<br/>    allowed_headers    = list(string)<br/>    exposed_headers    = list(string)<br/>    max_age_in_seconds = number<br/>  }))</pre> | `[]` | no |
| <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key) | Customer managed key properties for the storage account. Refer to the readme for more information on what is needed to enable customer-managed key encryption. It is recommended to not use key\_version unless you have a specific reason to do so as leaving it out will allow automatic key rotation. | <pre>object({<br/>    key_vault_uri = string<br/>    key_name      = string<br/>    key_version   = optional(string, null)<br/>  })</pre> | `null` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | List of managed identity IDs to assign to the storage account. | `list(string)` | `[]` | no |
| <a name="input_is_nfs_mountable"></a> [is\_nfs\_mountable](#input\_is\_nfs\_mountable) | Enable NFSv3 and HNS protocol for the storage account in order to be mounted to AKS/nodes. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Location of the resources. | `string` | n/a | yes |
| <a name="input_min_tls_version"></a> [min\_tls\_version](#input\_min\_tls\_version) | Minimum TLS version supported by the storage account. | `string` | `"TLS1_2"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the storage account. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group to put the resources in. | `string` | n/a | yes |
| <a name="input_storage_management_policy_default"></a> [storage\_management\_policy\_default](#input\_storage\_management\_policy\_default) | A simple abstraction of the most common properties for storage management lifecycle policies. If the simple implementation does not meet your needs, please open an issue. If you use this module to safe files that are rarely to never accessed again, opt for a very aggressive policy (starting already cool and archiving early). If you want to implement your own storage management policy, disable the default and use the output storage\_account\_id to implement your own policies. | <pre>object({<br/>    enabled                                  = optional(bool, true)<br/>    deleted_retain_days                      = optional(number, 7)<br/>    restorable_days                          = optional(number, 6)<br/>    container_deleted_retain_days            = optional(number, 7)<br/>    blob_to_cool_after_last_modified_days    = optional(number, 10)<br/>    blob_to_cold_after_last_modified_days    = optional(number, 50)<br/>    blob_to_archive_after_last_modified_days = optional(number, 100)<br/>    blob_to_deleted_after_last_modified_days = optional(number, 730)<br/>  })</pre> | <pre>{<br/>  "blob_to_archive_after_last_modified_days": 100,<br/>  "blob_to_cold_after_last_modified_days": 50,<br/>  "blob_to_cool_after_last_modified_days": 10,<br/>  "blob_to_deleted_after_last_modified_days": 730,<br/>  "container_deleted_retain_days": 7,<br/>  "deleted_retain_days": 7,<br/>  "enabled": true,<br/>  "restorable_days": 6<br/>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_storage_account_connection_strings"></a> [storage\_account\_connection\_strings](#output\_storage\_account\_connection\_strings) | Connection strings for the storage account, provided for backward compatibility reasons. It is recommended to use Workload or Managed Identity authentication wherever possible. |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | The ID of the storage account. |
<!-- END_TF_DOCS -->

## Limitations

- This module as of now is not supporting [`azurerm_key_vault_managed_hardware_security_module` (HSM-backend Key Vaults)](https://registry.terraform.io/providers/hashicorp/azurerm/3.117.0/docs/resources/key_vault_managed_hardware_security_module).
- Neither change feed nor versioning are currently supported by this module. If you need these features, please open an issue. They are omitted for brevity and simplicity not because we do not want to support them.
