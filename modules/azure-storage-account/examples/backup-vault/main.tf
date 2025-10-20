terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.15"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}

# Generate random suffix for unique resource names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "example" {
  name     = "rg-backup-vault-test-${random_string.suffix.result}"
  location = "East US"
}

# Example 1: Storage account with backup vault enabled
module "storage_account_with_backup_1" {
  source = "../../"

  name                     = "stbackup1${random_string.suffix.result}"
  location                 = azurerm_resource_group.example.location
  resource_group_name      = azurerm_resource_group.example.name
  account_replication_type = "ZRS"

  containers = {
    "data" = {
      access_type = "private"
    }
  }

  # Enable backup vault with default settings
  backup_vault = {
    name                       = "storage-backup-vault"
    datastore_type             = "VaultStore"
    redundancy                 = "ZoneRedundant"
    retention_duration_in_days = 14
    immutability               = "Disabled"
    soft_delete                = "On"
  }

  # Use default backup policy settings
  backup_policy = {
    name                                   = "default-blob-backup-policy"
    operational_default_retention_duration = "P2W"
  }

  # Use default backup instance settings
  backup_instance = {
    name = "default-blob-backup-instance"
  }

  tags = {
    environment = "example"
    example     = "backup-vault"
    purpose     = "testing-backup-vault-1"
  }
}

# Example 2: Another storage account with backup vault enabled in the same resource group
# This demonstrates that the unique naming prevents conflicts
module "storage_account_with_backup_2" {
  source = "../../"

  name                     = "stbackup2${random_string.suffix.result}"
  location                 = azurerm_resource_group.example.location
  resource_group_name      = azurerm_resource_group.example.name
  account_replication_type = "LRS"

  containers = {
    "archive" = {
      access_type = "private"
    }
  }

  # Enable backup vault with the same base name
  # The random suffix will make it unique
  backup_vault = {
    name                       = "storage-backup-vault"
    datastore_type             = "VaultStore"
    redundancy                 = "LocallyRedundant"
    retention_duration_in_days = 30
    immutability               = "Disabled"
    soft_delete                = "On"
  }

  backup_policy = {
    name                                   = "extended-backup-policy"
    operational_default_retention_duration = "P4W"
  }

  backup_instance = {
    name = "extended-blob-backup-instance"
  }

  tags = {
    environment = "example"
    example     = "backup-vault"
    purpose     = "testing-backup-vault-2"
  }
}

# Example 3: Storage account with backup vault in geo-redundant mode
module "storage_account_with_backup_3" {
  source = "../../"

  name                     = "stbackup3${random_string.suffix.result}"
  location                 = azurerm_resource_group.example.location
  resource_group_name      = azurerm_resource_group.example.name
  account_replication_type = "GRS"

  containers = {
    "critical-data" = {
      access_type = "private"
    }
  }

  # Enable backup vault with geo-redundancy and cross-region restore
  backup_vault = {
    name                         = "storage-backup-vault"
    datastore_type               = "VaultStore"
    redundancy                   = "GeoRedundant"
    cross_region_restore_enabled = true
    retention_duration_in_days   = 60
    immutability                 = "Unlocked"
    soft_delete                  = "AlwaysOn"
  }

  backup_policy = {
    name                                   = "geo-backup-policy"
    operational_default_retention_duration = "P8W"
  }

  backup_instance = {
    name                            = "geo-backup-instance"
    storage_account_container_names = ["critical-data"]
  }

  tags = {
    environment = "production"
    example     = "backup-vault"
    purpose     = "testing-geo-redundant-backup"
  }
}

