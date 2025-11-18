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
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm) | ~> 4.15 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | ~> 4.15 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_eventhub.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) | resource |
| [azurerm_eventhub_consumer_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_consumer_group) | resource |
| [azurerm_eventhub_namespace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace) | resource |
| [azurerm_eventhub_namespace_authorization_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace_authorization_rule) | resource |
| [azurerm_eventhub_namespace_customer_managed_key.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace_customer_managed_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eventhubs"></a> [eventhubs](#input_eventhubs) | Map of Event Hubs to create within the namespace. | <pre>map(object({<br/>    name             = optional(string)<br/>    partition_count  = optional(number, 4)<br/>    message_retention = optional(number, 7)<br/>    status           = optional(string, "Active")<br/>    capture_description = optional(object({<br/>      enabled             = bool<br/>      encoding            = optional(string, "Avro")<br/>      interval_in_seconds = optional(number, 300)<br/>      size_limit_in_bytes = optional(number, 314572800)<br/>      skip_empty_archives = optional(bool, true)<br/>      destination = object({<br/>        name                = optional(string, "EventHubArchive.AzureBlockBlob")<br/>        storage_account_id  = string<br/>        blob_container_name = string<br/>        archive_name_format = optional(string, "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}")<br/>      })<br/>    }))<br/>    consumer_groups = optional(map(object({<br/>      name          = optional(string)<br/>      user_metadata = optional(string)<br/>    })), {})<br/>    authorization_rules = optional(map(object({<br/>      name   = optional(string)<br/>      listen = optional(bool, false)<br/>      send   = optional(bool, false)<br/>      manage = optional(bool, false)<br/>    })), {})<br/>    tags = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_location"></a> [location](#input_location) | Azure region where the Event Hub namespace is deployed. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input_namespace) | Configuration for the Event Hub namespace. | <pre>object({<br/>    name                          = string<br/>    sku                           = optional(string, "Standard")<br/>    capacity                      = optional(number)<br/>    auto_inflate_enabled          = optional(bool, false)<br/>    maximum_throughput_units      = optional(number)<br/>    minimum_tls_version           = optional(string, "1.2")<br/>    public_network_access_enabled = optional(bool, true)<br/>    local_authentication_enabled  = optional(bool, true)<br/>    zone_redundancy_enabled       = optional(bool, false)<br/>    identity = optional(object({<br/>      type         = string<br/>      identity_ids = optional(list(string), [])<br/>    }))<br/>    customer_managed_key = optional(object({<br/>      key_vault_key_ids         = list(string)<br/>      user_assigned_identity_id = optional(string)<br/>    }))<br/>    network_rules = optional(object({<br/>      default_action                 = optional(string, "Deny")<br/>      trusted_service_access_enabled = optional(bool, false)<br/>      public_network_access_enabled  = optional(bool, true)<br/>      ip_rules = optional(list(object({<br/>        ip_mask = string<br/>        action  = optional(string, "Allow")<br/>      })), [])<br/>      virtual_network_rules = optional(list(object({<br/>        subnet_id                                       = string<br/>        ignore_missing_virtual_network_service_endpoint = optional(bool, false)<br/>      })), [])<br/>    }))<br/>    authorization_rules = optional(map(object({<br/>      name   = optional(string)<br/>      listen = optional(bool, false)<br/>      send   = optional(bool, false)<br/>      manage = optional(bool, false)<br/>    })), {})<br/>    create_listen_rule = optional(bool, false)<br/>    create_send_rule   = optional(bool, false)<br/>    create_manage_rule = optional(bool, false)<br/>    tags = optional(map(string), {})<br/>  })</pre> | n/a | yes |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | Name of the resource group that will contain the Event Hub namespace. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input_tags) | Tags applied to all resources created by this module. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eventhub_consumer_groups"></a> [eventhub_consumer_groups](#output_eventhub_consumer_groups) | Consumer groups created for each Event Hub. |
| <a name="output_eventhubs"></a> [eventhubs](#output_eventhubs) | Map of Event Hubs created by this module. |
| <a name="output_namespace"></a> [namespace](#output_namespace) | Details of the Event Hub namespace. |
| <a name="output_namespace_authorization_rules"></a> [namespace_authorization_rules](#output_namespace_authorization_rules) | Authorization rules created at the namespace scope. |
<!-- END_TF_DOCS -->

