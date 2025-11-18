# Azure Event Hub

## Pre-requisites
- Reader access to the subscription
- Contributor access to the resource group

## Features
- Event Hub namespace with configurable SKU and capacity
- Multiple Event Hubs with custom configuration
- Consumer groups management
- Authorization rules at namespace level
- Network security with IP rules and VNet integration
- Customer-managed key encryption support

## Important notes
- The number of partitions cannot be increased after creation if the SKU is standard
- For Defender for Cloud export, use the `azure-defender` module with the `eventhub_export` variable

## Module

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.15 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | n/a |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.15 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_application.sp_data_receiver](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_service_principal.sp_data_receiver](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurerm_eventhub.eventhub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) | resource |
| [azurerm_eventhub_consumer_group.consumer_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_consumer_group) | resource |
| [azurerm_eventhub_namespace.namespace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace) | resource |
| [azurerm_eventhub_namespace_authorization_rule.custom](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace_authorization_rule) | resource |
| [azurerm_eventhub_namespace_authorization_rule.listen](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace_authorization_rule) | resource |
| [azurerm_eventhub_namespace_authorization_rule.manage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace_authorization_rule) | resource |
| [azurerm_eventhub_namespace_authorization_rule.send](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace_authorization_rule) | resource |
| [azurerm_eventhub_namespace_customer_managed_key.namespace_cmk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace_customer_managed_key) | resource |
| [azurerm_role_assignment.sp_data_receiver](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eventhubs"></a> [eventhubs](#input\_eventhubs) | Map of Event Hubs to create within the namespace. | <pre>map(object({<br/>    name              = string<br/>    partition_count   = optional(number, 16)<br/>    message_retention = optional(number, 7)<br/>    status            = optional(string, "Active")<br/>    capture_description = optional(object({<br/>      enabled             = bool<br/>      encoding            = optional(string)<br/>      interval_in_seconds = optional(number)<br/>      size_limit_in_bytes = optional(number)<br/>      skip_empty_archives = optional(bool, true)<br/>      destination = object({<br/>        name                = optional(string, "EventHubArchive.AzureBlockBlob")<br/>        storage_account_id  = string<br/>        blob_container_name = string<br/>        archive_name_format = optional(string, "{Namespace}_{EventHub}_{PartitionId}_{Year}_{Month}_{Day}_{Hour}_{Minute}")<br/>      })<br/>    }))<br/>    consumer_groups = optional(map(object({<br/>      name          = string<br/>      user_metadata = optional(string)<br/>    })), {})<br/>    tags = optional(map(string), {})<br/>  }))</pre> | <pre>{<br/>  "eventhub-001": {<br/>    "name": "eventhub-001"<br/>  }<br/>}</pre> | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | The ID of the Key Vault where to store the secrets. If not set, the secrets will not be stored in the Key Vault | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region where the Event Hub namespace is deployed. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Configuration for the Event Hub namespace. | <pre>object({<br/>    name                          = string<br/>    sku                           = optional(string, "Standard")<br/>    capacity                      = optional(number)<br/>    auto_inflate_enabled          = optional(bool, false)<br/>    maximum_throughput_units      = optional(number)<br/>    minimum_tls_version           = optional(string, "1.2")<br/>    public_network_access_enabled = optional(bool, true)<br/>    local_authentication_enabled  = optional(bool, true)<br/>    identity = optional(object({<br/>      type         = string<br/>      identity_ids = optional(list(string), [])<br/>    }))<br/>    customer_managed_key = optional(object({<br/>      key_vault_key_ids         = list(string)<br/>      user_assigned_identity_id = optional(string)<br/>    }))<br/>    network_rules = optional(object({<br/>      default_action                 = optional(string, "Deny")<br/>      trusted_service_access_enabled = optional(bool, false)<br/>      public_network_access_enabled  = optional(bool, true)<br/>      ip_rules = optional(list(object({<br/>        ip_mask = string<br/>        action  = optional(string, "Allow")<br/>      })), [])<br/>      virtual_network_rules = optional(list(object({<br/>        subnet_id                                       = string<br/>        ignore_missing_virtual_network_service_endpoint = optional(bool, false)<br/>      })), [])<br/>    }))<br/>    create_listen_rule = optional(bool, true)<br/>    create_send_rule   = optional(bool, true)<br/>    create_manage_rule = optional(bool, false)<br/>    tags               = optional(map(string), {})<br/>  })</pre> | <pre>{<br/>  "name": "eventhub-namespace-001"<br/>}</pre> | no |
| <a name="input_namespace_authorization_rules"></a> [namespace\_authorization\_rules](#input\_namespace\_authorization\_rules) | Map of custom authorization rules to create at the namespace level. | <pre>map(object({<br/>    name   = string<br/>    listen = optional(bool, false)<br/>    send   = optional(bool, false)<br/>    manage = optional(bool, false)<br/>  }))</pre> | `{}` | no |
| <a name="input_receiver_service_principal"></a> [receiver\_service\_principal](#input\_receiver\_service\_principal) | Configuration for creating a service principal with Azure Event Hubs Data Receiver role. If not set, no service principal will be created. | <pre>object({<br/>    display_name = string<br/>  })</pre> | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group that will contain the Event Hub namespace. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all resources created by this module. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | The client ID of the underlying Azure Entra App Registration. |
| <a name="output_eventhub_consumer_groups"></a> [eventhub\_consumer\_groups](#output\_eventhub\_consumer\_groups) | Consumer groups created for each Event Hub. |
| <a name="output_eventhubs"></a> [eventhubs](#output\_eventhubs) | Map of Event Hubs created by this module. |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Details of the Event Hub namespace. |
| <a name="output_namespace_authorization_rules"></a> [namespace\_authorization\_rules](#output\_namespace\_authorization\_rules) | Authorization rules created at the namespace scope. |
| <a name="output_object_id"></a> [object\_id](#output\_object\_id) | The object ID of the matching Service Principal to be used for effective role assignments. |
<!-- END_TF_DOCS -->
