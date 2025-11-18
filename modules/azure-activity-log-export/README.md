# Azure Activity Log Export

## Pre-requisites
- Reader access to the subscription
- Contributor access to configure diagnostic settings for the subscription
- An existing Event Hub and authorization rule for log export

## Features
- Export Azure Activity Logs to Event Hub
- Configurable log categories
- Supports all standard Activity Log categories (Administrative, Security, ServiceHealth, etc.)

## Important notes
- This module requires an existing Event Hub namespace and authorization rule
- The diagnostic setting is created at the subscription level
- Activity Logs are subscription-wide and cannot be filtered by resource

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
| [azurerm_monitor_diagnostic_setting.activity_log_export](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_categories"></a> [categories](#input_categories) | List of Activity Log categories to export. | `list(string)` | <pre>[<br/>  "Administrative",<br/>  "Security",<br/>  "ServiceHealth",<br/>  "Alert",<br/>  "Recommendation",<br/>  "Policy",<br/>  "Autoscale",<br/>  "ResourceHealth"<br/>]</pre> | no |
| <a name="input_eventhub_authorization_rule_id"></a> [eventhub_authorization_rule_id](#input_eventhub_authorization_rule_id) | The ID of the Event Hub namespace authorization rule used for sending logs. | `string` | n/a | yes |
| <a name="input_eventhub_name"></a> [eventhub_name](#input_eventhub_name) | The name of the Event Hub where Activity Logs will be sent. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input_name) | Name of the diagnostic setting for Activity Log export. | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription_id](#input_subscription_id) | Azure subscription ID whose Activity Log will be exported. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_diagnostic_setting"></a> [diagnostic_setting](#output_diagnostic_setting) | Details of the Activity Log diagnostic setting. |
| <a name="output_id"></a> [id](#output_id) | The ID of the diagnostic setting. |
| <a name="output_name"></a> [name](#output_name) | The name of the diagnostic setting. |
<!-- END_TF_DOCS -->

