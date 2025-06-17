
locals {
  defender_configs = [
    {
      resource_type = "CloudPosture"
      config        = var.cloud_posture_defender_settings
    },
    {
      resource_type = "StorageAccounts"
      config        = var.storage_accounts_defender_settings
    },
    {
      resource_type = "VirtualMachines"
      config        = var.virtual_machines_defender_settings
    },
    {
      resource_type = "KeyVaults"
      config        = var.key_vaults_defender_settings
    },
    {
      resource_type = "Arm"
      config        = var.arm_defender_settings

    },
    {
      resource_type = "OpenSourceRelationalDatabases"
      config        = var.open_source_relational_databases_defender_settings

    },
    {
      resource_type = "Containers"
      config        = var.containers_defender_settings
    },
    {
      resource_type = "AI"
      config        = var.ai_defender_settings
    }
  ]
  defender_configs_free_plan     = [for config in local.defender_configs : config if config.config.tier == "Free"]
  defender_configs_standard_plan = [for config in local.defender_configs : config if config.config.tier == "Standard"]
}

resource "azurerm_security_center_subscription_pricing" "standard_plan" {
  for_each      = { for config in local.defender_configs_standard_plan : config.resource_type => config }
  resource_type = each.value.resource_type
  tier          = each.value.config.tier
  subplan       = lookup(each.value.config, "subplan", null)

  dynamic "extension" {
    for_each = each.value.config.extensions
    content {
      name                            = extension.value.name
      additional_extension_properties = extension.value.additional_extension_properties
    }
  }
}
resource "azurerm_security_center_subscription_pricing" "free_plan" {
  for_each      = { for config in local.defender_configs_free_plan : config.resource_type => config }
  resource_type = each.value.resource_type
  tier          = each.value.config.tier
}

resource "azapi_resource" "security_contact" {
  type = "Microsoft.Security/securityContacts@2023-12-01-preview"
  # The only valid name for security contact is 'default'
  name      = "default"
  parent_id = var.subscription_id

  body = {
    properties = {
      emails    = var.security_contact_settings.email
      phone     = var.security_contact_settings.phone
      isEnabled = var.security_contact_settings.isEnabled
      notificationsByRole = {
        state = var.security_contact_settings.notificationsByRole.state
        roles = var.security_contact_settings.notificationsByRole.roles
      }
      notificationsSources = var.security_contact_settings.notificationsSources
    }
  }

  # The API returns a readonly location field which triggers a replacement - https://github.com/Azure/terraform-provider-azapi/issues/655
  schema_validation_enabled = false
  lifecycle {
    ignore_changes = [location]
  }
}