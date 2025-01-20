
# Azure Defender

This Terraform code configures Azure Defender for a subscription, enabling various security features and settings.

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
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | 2.2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.14.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | 2.2.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4.14.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.security_contact](https://registry.terraform.io/providers/Azure/azapi/2.2.0/docs/resources/resource) | resource |
| [azurerm_security_center_subscription_pricing.free_plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/security_center_subscription_pricing) | resource |
| [azurerm_security_center_subscription_pricing.standard_plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/security_center_subscription_pricing) | resource |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_arm_defender_settings"></a> [arm\_defender\_settings](#input\_arm\_defender\_settings) | n/a | <pre>object({<br/>    tier       = optional(string, "Standard")<br/>    subplan = optional(string, "PerSubscription")<br/>    extensions = optional(list(object({<br/>      name                          = string<br/>      additional_extension_properties = optional(map(string))<br/>    })), [])<br/>  })</pre> | `{}` | no |
| <a name="input_cloud_posture_defender_settings"></a> [cloud\_posture\_defender\_settings](#input\_cloud\_posture\_defender\_settings) | n/a | <pre>object({<br/>    tier       = optional(string, "Standard")<br/>    extensions = optional(list(object({<br/>      name                          = string<br/>      additional_extension_properties = optional(map(string))<br/>    })), [])<br/>  })</pre> | <pre>{<br/>  "extensions": [<br/>    {<br/>      "name": "ContainerRegistriesVulnerabilityAssessments"<br/>    },<br/>    {<br/>      "additional_extension_properties": {<br/>        "ExclusionTags": "[]"<br/>      },<br/>      "name": "AgentlessVmScanning"<br/>    },<br/>    {<br/>      "name": "AgentlessDiscoveryForKubernetes"<br/>    },<br/>    {<br/>      "name": "SensitiveDataDiscovery"<br/>    },<br/>    {<br/>      "name": "EntraPermissionsManagement"<br/>    },<br/>    {<br/>      "name": "ApiPosture"<br/>    }<br/>  ]<br/>}</pre> | no |
| <a name="input_containers_defender_settings"></a> [containers\_defender\_settings](#input\_containers\_defender\_settings) | n/a | <pre>object({<br/>    tier       = optional(string, "Standard")<br/>    extensions = optional(list(object({<br/>      name                          = string<br/>      additional_extension_properties = optional(map(string))<br/>    })), [])<br/>  })</pre> | <pre>{<br/>  "extensions": [<br/>    {<br/>      "name": "ContainerRegistriesVulnerabilityAssessments"<br/>    },<br/>    {<br/>      "name": "AgentlessDiscoveryForKubernetes"<br/>    },<br/>    {<br/>      "name": "ContainerSensor"<br/>    },<br/>    {<br/>      "additional_extension_properties": {<br/>        "ExclusionTags": "[]"<br/>      },<br/>      "name": "AgentlessVmScanning"<br/>    }<br/>  ]<br/>}</pre> | no |
| <a name="input_key_vaults_defender_settings"></a> [key\_vaults\_defender\_settings](#input\_key\_vaults\_defender\_settings) | n/a | <pre>object({<br/>    tier       = optional(string, "Standard")<br/>    subplan = optional(string, "PerKeyVault")<br/>    extensions = optional(list(object({<br/>      name                          = string<br/>      additional_extension_properties = optional(map(string))<br/>    })), [])<br/>  })</pre> | `{}` | no |
| <a name="input_open_source_relational_databases_defender_settings"></a> [open\_source\_relational\_databases\_defender\_settings](#input\_open\_source\_relational\_databases\_defender\_settings) | n/a | <pre>object({<br/>    tier       = optional(string, "Standard")<br/>    extensions = optional(list(object({<br/>      name                          = string<br/>      additional_extension_properties = optional(map(string))<br/>    })), [])<br/>  })</pre> | `{}` | no |
| <a name="input_security_contact_settings"></a> [security\_contact\_settings](#input\_security\_contact\_settings) | n/a | <pre>object({<br/>    isEnabled = optional(bool, true)<br/>    subscription_id = optional(string, null)<br/>    email = string<br/>    phone = optional(string, "")<br/>    notificationsByRole = optional(object({<br/>      state = optional(string, "On")<br/>      roles = optional(list(string), ["Owner"])<br/>    }), {})<br/>    notificationsSources = optional(list(map(string)), [<br/>      {<br/>        sourceType = "AttackPath"<br/>        minimalRiskLevel = "Critical"<br/>      },<br/>      {<br/>        sourceType = "Alert"<br/>        minimalSeverity = "High"<br/>      }<br/>    ])<br/>  })</pre> | n/a | yes |
| <a name="input_storage_accounts_defender_settings"></a> [storage\_accounts\_defender\_settings](#input\_storage\_accounts\_defender\_settings) | n/a | <pre>object({<br/>    tier       = optional(string, "Standard")<br/>    subplan    = optional(string, "DefenderForStorageV2")<br/>    extensions = optional(list(object({<br/>      name                          = string<br/>      additional_extension_properties = optional(map(string))<br/>    })), [])<br/>  })</pre> | <pre>{<br/>  "extensions": [<br/>    {<br/>      "additional_extension_properties": {<br/>        "CapGBPerMonthPerStorageAccount": "1000"<br/>      },<br/>      "name": "OnUploadMalwareScanning"<br/>    },<br/>    {<br/>      "name": "SensitiveDataDiscovery"<br/>    }<br/>  ]<br/>}</pre> | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Subscription ID | `string` | n/a | yes |
| <a name="input_virtual_machines_defender_settings"></a> [virtual\_machines\_defender\_settings](#input\_virtual\_machines\_defender\_settings) | n/a | <pre>object({<br/>    tier       = optional(string, "Standard")<br/>    subplan    = optional(string, "P2")<br/>    extensions = optional(list(object({<br/>      name                          = string<br/>      additional_extension_properties = optional(map(string))<br/>    })), [])<br/>  })</pre> | <pre>{<br/>  "extensions": [<br/>    {<br/>      "additional_extension_properties": {<br/>        "ExclusionTags": "[]"<br/>      },<br/>      "name": "AgentlessVmScanning"<br/>    }<br/>  ]<br/>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
