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
  name     = "rg-archive-test-${random_string.suffix.result}"
  location = "East US"
}

# Example 1: Storage account with LRS replication and Archive tier enabled
module "storage_account_lrs_archive" {
  source = "../../"

  name                     = "stlrs${random_string.suffix.result}"
  location                 = azurerm_resource_group.example.location
  resource_group_name      = azurerm_resource_group.example.name
  account_replication_type = "LRS" # LRS supports Archive tier

  storage_management_policy_default = {
    blob_to_cool_after_last_modified_days    = 30
    blob_to_cold_after_last_modified_days    = 90
    blob_to_archive_after_last_modified_days = 180 # Archive tier enabled
    blob_to_deleted_after_last_modified_days = 365
  }

  containers = {
    "archive-test" = {
      access_type = "private"
    }
  }

  tags = {
    environment = "example"
    example     = "archive-tier-lifecycle"
    purpose     = "testing-archive-tier-with-lrs"
  }
}

# Example 2: Storage account with GRS replication and Archive tier enabled
module "storage_account_grs_archive" {
  source = "../../"

  name                     = "stgrs${random_string.suffix.result}"
  location                 = azurerm_resource_group.example.location
  resource_group_name      = azurerm_resource_group.example.name
  account_replication_type = "GRS" # GRS supports Archive tier

  storage_management_policy_default = {
    blob_to_cool_after_last_modified_days    = 7
    blob_to_cold_after_last_modified_days    = 30
    blob_to_archive_after_last_modified_days = 90 # Archive tier enabled
    blob_to_deleted_after_last_modified_days = 180
  }

  containers = {
    "cold-data" = {
      access_type = "private"
    }
  }

  tags = {
    environment = "example"
    example     = "archive-tier-lifecycle"
    purpose     = "testing-archive-tier-with-grs"
  }
}

# Example 3: Storage account with ZRS replication - Archive tier will be automatically skipped
module "storage_account_zrs_no_archive" {
  source = "../../"

  name                     = "stzrs${random_string.suffix.result}"
  location                 = azurerm_resource_group.example.location
  resource_group_name      = azurerm_resource_group.example.name
  account_replication_type = "ZRS" # ZRS does NOT support Archive tier

  storage_management_policy_default = {
    blob_to_cool_after_last_modified_days    = 30
    blob_to_cold_after_last_modified_days    = 90
    blob_to_archive_after_last_modified_days = null # Must be null for ZRS
    blob_to_deleted_after_last_modified_days = 365
  }

  containers = {
    "zrs-test" = {
      access_type = "private"
    }
  }

  tags = {
    environment = "example"
    example     = "archive-tier-lifecycle"
    purpose     = "testing-zrs-without-archive-tier"
  }
}

