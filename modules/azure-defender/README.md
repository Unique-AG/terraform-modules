
# Azure Defender

This Terraform code configures Azure Defender for a subscription, enabling various security features and settings.

## Pre-requisites
- Contributor access to the subscription
- If using Event Hub export: Access to the Event Hub connection string (can be in any subscription)

## Features
- Configure Defender plans for various Azure services (Cloud Posture, Storage, VMs, Key Vaults, ARM, Databases, Containers, AI)
- Security contact configuration
- **Optional: Continuous export to Event Hub** (alerts, assessments, secure scores)
  - Supports cross-subscription Event Hub export for centralized logging
  - For cross-subscription scenarios, use provider aliases or data sources to retrieve the connection string

## Default settings

This module is secure by default, activating paid Defender features. While this provides comprehensive security coverage, it is important to note that enabling these Defender features will incur additional costs.

### Important Notice

**Warning:** The default settings of this module activate all Defender features, which will result in additional costs. If you do not wish to incur these costs, you need to configure the `tier` settings appropriately, e.g.:
```hcl
module "defender" {
...
  cloud_posture_defender_settings = {
    tier = "Free"
  }
}
```
Possible values for the `tier` are `Free` or `Standard`.

## [Examples](./examples)

# Module

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.33 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | ~> 2.2.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.33 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.security_contact](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_security_center_automation.eventhub_export](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/security_center_automation) | resource |
| [azurerm_security_center_subscription_pricing.free_plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/security_center_subscription_pricing) | resource |
| [azurerm_security_center_subscription_pricing.standard_plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/security_center_subscription_pricing) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ai_defender_settings"></a> [ai\_defender\_settings](#input\_ai\_defender\_settings) | Settings for Defender for AI | <pre>object({<br/>    tier = optional(string, "Standard")<br/>    extensions = optional(list(object({<br/>      name                            = string<br/>      additional_extension_properties = optional(map(string))<br/>    })), [])<br/>  })</pre> | `{}` | no |
| <a name="input_arm_defender_settings"></a> [arm\_defender\_settings](#input\_arm\_defender\_settings) | n/a | <pre>object({<br/>    tier    = optional(string, "Standard")<br/>    subplan = optional(string, "PerSubscription")<br/>    extensions = optional(list(object({<br/>      name                            = string<br/>      additional_extension_properties = optional(map(string))<br/>    })), [])<br/>  })</pre> | `{}` | no |
| <a name="input_cloud_posture_defender_settings"></a> [cloud\_posture\_defender\_settings](#input\_cloud\_posture\_defender\_settings) | n/a | <pre>object({<br/>    tier = optional(string, "Standard")<br/>    extensions = optional(list(object({<br/>      name                            = string<br/>      additional_extension_properties = optional(map(string))<br/>    })), [])<br/>  })</pre> | <pre>{<br/>  "extensions": [<br/>    {<br/>      "name": "ContainerRegistriesVulnerabilityAssessments"<br/>    },<br/>    {<br/>      "additional_extension_properties": {<br/>        "ExclusionTags": "[]"<br/>      },<br/>      "name": "AgentlessVmScanning"<br/>    },<br/>    {<br/>      "name": "AgentlessDiscoveryForKubernetes"<br/>    },<br/>    {<br/>      "name": "SensitiveDataDiscovery"<br/>    },<br/>    {<br/>      "name": "EntraPermissionsManagement"<br/>    },<br/>    {<br/>      "name": "ApiPosture"<br/>    }<br/>  ]<br/>}</pre> | no |
| <a name="input_containers_defender_settings"></a> [containers\_defender\_settings](#input\_containers\_defender\_settings) | n/a | <pre>object({<br/>    tier = optional(string, "Standard")<br/>    extensions = optional(list(object({<br/>      name                            = string<br/>      additional_extension_properties = optional(map(string))<br/>    })), [])<br/>  })</pre> | <pre>{<br/>  "extensions": [<br/>    {<br/>      "name": "ContainerRegistriesVulnerabilityAssessments"<br/>    },<br/>    {<br/>      "name": "AgentlessDiscoveryForKubernetes"<br/>    },<br/>    {<br/>      "name": "ContainerSensor"<br/>    },<br/>    {<br/>      "additional_extension_properties": {<br/>        "ExclusionTags": "[]"<br/>      },<br/>      "name": "AgentlessVmScanning"<br/>    }<br/>  ]<br/>}</pre> | no |
| <a name="input_eventhub_export"></a> [eventhub\_export](#input\_eventhub\_export) | Configuration for exporting Defender for Cloud data to Event Hub. | <pre>object({<br/>    name                = string<br/>    location            = string<br/>    resource_group_name = string<br/>    eventhub = object({<br/>      id                = string<br/>      connection_string = string<br/>    })<br/>    sources = optional(map(object({<br/>      event_source  = string<br/>      property_path = optional(string, "")<br/>      labels        = optional(list(string), [])<br/>    })), {<br/>      alert = {<br/>        event_source  = "Alerts"<br/>        property_path = "properties.metadata.severity"<br/>        labels        = ["High", "Medium", "Low"]<br/>      }<br/>      assessment = {<br/>        event_source  = "Assessments"<br/>        property_path = "properties.status.code"<br/>        labels        = ["Unhealthy", "Healthy"]<br/>      }<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_key_vaults_defender_settings"></a> [key\_vaults\_defender\_settings](#input\_key\_vaults\_defender\_settings) | n/a | <pre>object({<br/>    tier    = optional(string, "Standard")<br/>    subplan = optional(string, "PerKeyVault")<br/>    extensions = optional(list(object({<br/>      name                            = string<br/>      additional_extension_properties = optional(map(string))<br/>    })), [])<br/>  })</pre> | `{}` | no |
| <a name="input_open_source_relational_databases_defender_settings"></a> [open\_source\_relational\_databases\_defender\_settings](#input\_open\_source\_relational\_databases\_defender\_settings) | n/a | <pre>object({<br/>    tier = optional(string, "Standard")<br/>    extensions = optional(list(object({<br/>      name                            = string<br/>      additional_extension_properties = optional(map(string))<br/>    })), [])<br/>  })</pre> | `{}` | no |
| <a name="input_security_contact_settings"></a> [security\_contact\_settings](#input\_security\_contact\_settings) | n/a | <pre>object({<br/>    isEnabled       = optional(bool, true)<br/>    subscription_id = optional(string, null)<br/>    email           = string<br/>    phone           = optional(string, "")<br/>    notificationsByRole = optional(object({<br/>      state = optional(string, "On")<br/>      roles = optional(list(string), ["Owner"])<br/>    }), {})<br/>    notificationsSources = optional(list(map(string)), [<br/>      {<br/>        sourceType       = "AttackPath"<br/>        minimalRiskLevel = "Critical"<br/>      },<br/>      {<br/>        sourceType      = "Alert"<br/>        minimalSeverity = "High"<br/>      }<br/>    ])<br/>  })</pre> | n/a | yes |
| <a name="input_storage_accounts_defender_settings"></a> [storage\_accounts\_defender\_settings](#input\_storage\_accounts\_defender\_settings) | n/a | <pre>object({<br/>    tier    = optional(string, "Standard")<br/>    subplan = optional(string, "DefenderForStorageV2")<br/>    extensions = optional(list(object({<br/>      name                            = string<br/>      additional_extension_properties = optional(map(string))<br/>    })), [])<br/>  })</pre> | <pre>{<br/>  "extensions": [<br/>    {<br/>      "additional_extension_properties": {<br/>        "AutomatedResponse": "None",<br/>        "BlobScanResultsOptions": "BlobIndexTags",<br/>        "CapGBPerMonthPerStorageAccount": "1000"<br/>      },<br/>      "name": "OnUploadMalwareScanning"<br/>    },<br/>    {<br/>      "name": "SensitiveDataDiscovery"<br/>    }<br/>  ]<br/>}</pre> | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Subscription ID | `string` | n/a | yes |
| <a name="input_virtual_machines_defender_settings"></a> [virtual\_machines\_defender\_settings](#input\_virtual\_machines\_defender\_settings) | n/a | <pre>object({<br/>    tier    = optional(string, "Standard")<br/>    subplan = optional(string, "P2")<br/>    extensions = optional(list(object({<br/>      name                            = string<br/>      additional_extension_properties = optional(map(string))<br/>    })), [])<br/>  })</pre> | <pre>{<br/>  "extensions": [<br/>    {<br/>      "additional_extension_properties": {<br/>        "ExclusionTags": "[]"<br/>      },<br/>      "name": "AgentlessVmScanning"<br/>    }<br/>  ]<br/>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
