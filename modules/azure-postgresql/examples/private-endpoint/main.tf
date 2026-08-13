variable "subscription_id" {
  type = string
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "switzerlandnorth"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-vn"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "example-sn"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_private_dns_zone" "example" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                = "example-vnet-link"
  private_dns_zone_id = azurerm_private_dns_zone.example.id
  virtual_network_id  = azurerm_virtual_network.example.id
}

resource "random_password" "postgres_username" {
  length  = 16
  special = false
}

resource "random_password" "postgres_password" {
  length  = 32
  special = false
}

resource "random_string" "server_name" {
  length  = 8
  special = false
  upper   = false
}

module "apfs" {
  source              = "../.."
  admin_password      = random_password.postgres_password.result
  administrator_login = random_password.postgres_username.result
  name                = "my-postgresql-server-${random_string.server_name.result}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  public_network_access_enabled = false

  private_endpoint = {
    subnet_id           = azurerm_subnet.example.id
    private_dns_zone_id = azurerm_private_dns_zone.example.id
  }

  metric_alerts_external_action_group_ids = []

  tags = {
    environment = "example"
  }
}
