terraform {
  backend "local" {
    path             = "terraform.tfstate"
    use_azuread_auth = true
  }
}

# Random string for unique naming
resource "random_string" "unique" {
  length  = 6
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-storage-data-protection-${random_string.unique.result}"
  location = "switzerlandnorth"

  tags = {
    environment = "example"
    purpose     = "data-protection-testing"
  }
}

# Example demonstrating shared access keys and data protection settings
module "storage_account_with_data_protection" {
  source              = "../.."
  name                = "storagedata${random_string.unique.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  # Enable shared access keys for this example
  shared_access_key_enabled = true

  # Configure comprehensive data protection settings
  data_protection_settings = {
    versioning_enabled                   = true
    change_feed_enabled                  = true
    blob_soft_delete_retention_days      = 30
    container_soft_delete_retention_days = 30
    change_feed_retention_days           = 30
    point_in_time_restore_days           = 7
  }

  # Create some containers to test with
  containers = {
    "backup-data" = {
      access_type = "private"
    }
    "logs" = {
      access_type = "private"
    }
    "assets" = {
      access_type = "private"
    }
  }

  tags = {
    environment = "example"
    purpose     = "data-protection-testing"
    features    = "shared-keys,soft-delete,versioning,change-feed,point-in-time-restore"
  }
}

# Example with minimal data protection settings
module "storage_account_minimal_protection" {
  source              = "../.."
  name                = "storagemin${random_string.unique.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  # Enable shared access keys for this example
  shared_access_key_enabled = true

  # Minimal data protection - just versioning and soft delete
  data_protection_settings = {
    versioning_enabled                   = true
    change_feed_enabled                  = false
    blob_soft_delete_retention_days      = 7
    container_soft_delete_retention_days = 7
    change_feed_retention_days           = 0
    point_in_time_restore_days           = 0
  }

  tags = {
    environment = "example"
    purpose     = "minimal-protection-testing"
    features    = "versioning,soft-delete"
  }
}

# Example with aggressive data protection settings
module "storage_account_aggressive_protection" {
  source              = "../.."
  name                = "storageagg${random_string.unique.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  shared_access_key_enabled = false

  # Aggressive data protection settings for critical data
  data_protection_settings = {
    versioning_enabled                   = true
    change_feed_enabled                  = true
    blob_soft_delete_retention_days      = 365
    container_soft_delete_retention_days = 365
    change_feed_retention_days           = 365
    point_in_time_restore_days           = 30
  }

  containers = {
    "critical-data" = {
      access_type = "private"
    }
    "audit-logs" = {
      access_type = "private"
    }
  }

  tags = {
    environment = "example"
    purpose     = "aggressive-protection-testing"
    features    = "shared-keys,extended-retention,point-in-time-restore"
    data_class  = "critical"
  }
} 