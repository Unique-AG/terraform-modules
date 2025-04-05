# Example of a complex storage account configuration with all major features
module "sa" {
  source              = "../.."
  name                = "st${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  # Basic storage account settings
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "GRS"
  access_tier              = "Cool"
  min_tls_version          = "TLS1_2"

  # CORS configuration
  cors_rules = [
    {
      allowed_origins    = ["https://example.com"]
      allowed_methods    = ["GET", "POST", "PUT", "DELETE"]
      allowed_headers    = ["*"]
      exposed_headers    = ["ETag"]
      max_age_in_seconds = 3600
    }
  ]

  # Network Security Group
  network_security_group = {
    name                = "nsg-storage-${random_string.suffix.result}"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    security_rules = [
      {
        name                       = "AllowHttpsInbound"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "Internet"
        destination_address_prefix = "VirtualNetwork"
      }
    ]
  }

  # Private Endpoint configuration
  private_endpoint = {
    subnet_id           = azurerm_subnet.subnet.id
    private_dns_zone_id = azurerm_private_dns_zone.blob.id
    resource_group_name = azurerm_resource_group.rg.name
    subresource_names   = ["blob"] # Only one subresource allowed
    tags = {
      environment = "production"
    }
  }

  # Customer managed key configuration
  customer_managed_key = {
    key_name                  = azurerm_key_vault_key.storage_key.name
    key_vault_id              = azurerm_key_vault.kv.id
    user_assigned_identity_id = azurerm_user_assigned_identity.storage_identity.id
  }

  # Storage containers
  containers = {
    "datafsfw" = {
      access_type = "private"
    }
  }

  # Lifecycle management policy
  storage_management_policy_default = {
    enabled                                  = true
    blob_to_cool_after_last_modified_days    = 30
    blob_to_cold_after_last_modified_days    = 90
    blob_to_archive_after_last_modified_days = 180
    blob_to_deleted_after_last_modified_days = 365
  }

  # Connection string storage in Key Vault
  connection_settings = {
    connection_string_1 = "conn-storage-1-${random_string.suffix.result}"
    connection_string_2 = "conn-storage-2-${random_string.suffix.result}"
    key_vault_id        = azurerm_key_vault.kv.id
    expiration_date     = "2025-12-31T23:59:59Z"
  }

  # Retention policies
  deleted_retain_days           = 30
  container_deleted_retain_days = 30

  # Tags
  tags = {
    environment = "production"
    project     = "example"
    managed-by  = "terraform"
  }
}
