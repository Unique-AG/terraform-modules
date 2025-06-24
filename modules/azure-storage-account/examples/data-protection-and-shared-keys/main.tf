terraform {
  backend "local" {
    path = "terraform.tfstate"
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

# Virtual Network for private endpoint
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-storage-${random_string.unique.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "example"
    purpose     = "private-endpoint-testing"
  }
}

# Subnet for private endpoint
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-private-endpoint"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  # Enable private endpoint network policies
  private_endpoint_network_policies = "Enabled"
}

# Private DNS Zone for blob storage
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    environment = "example"
    purpose     = "private-endpoint-testing"
  }
}

# Link private DNS zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "blob-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.vnet.id

  tags = {
    environment = "example"
    purpose     = "private-endpoint-testing"
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

  # Enable public network access for this example
  public_network_access_enabled = true

  # Configure comprehensive data protection settings
  data_protection_settings = {
    versioning_enabled                   = true
    change_feed_enabled                  = true
    blob_soft_delete_retention_days      = 30
    container_soft_delete_retention_days = 30
    change_feed_retention_days           = 30
    point_in_time_restore_days           = 7
  }

  # Create some containers to test with different access types
  containers = {
    "backup-data" = {
      access_type = "private"
    }
    "logs" = {
      access_type = "private"
    }
    "assets" = {
      access_type = "private" # Private access only
    }
  }

  tags = {
    environment = "example"
    purpose     = "data-protection-testing"
    features    = "shared-keys,soft-delete,versioning,change-feed,point-in-time-restore,public-access"
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

  # Enable public network access for this example
  public_network_access_enabled = true

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
    features    = "versioning,soft-delete,public-access"
  }
}

# Example with aggressive data protection settings
module "storage_account_aggressive_protection" {
  source              = "../.."
  name                = "storageagg${random_string.unique.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  shared_access_key_enabled = false

  # Disable public network access for maximum security
  public_network_access_enabled = false

  # Configure private endpoint for secure access
  private_endpoint = {
    subnet_id           = azurerm_subnet.subnet.id
    private_dns_zone_id = azurerm_private_dns_zone.blob.id
    location            = azurerm_resource_group.rg.location
    subresource_names   = ["blob"]
    tags = {
      environment = "example"
      purpose     = "private-endpoint-testing"
    }
  }

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
      access_type = "private" # Private for sensitive data
    }
    "audit-logs" = {
      access_type = "private" # Private for audit logs
    }
  }

  tags = {
    environment = "example"
    purpose     = "aggressive-protection-testing"
    features    = "extended-retention,point-in-time-restore,private-access,private-endpoint"
    data_class  = "critical"
  }
} 