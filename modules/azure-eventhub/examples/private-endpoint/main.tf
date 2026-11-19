variable "subscription_id" {
  type = string
}

resource "azurerm_resource_group" "example" {
  name     = "rg-eventhub-pe-example"
  location = "switzerlandnorth"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-eventhub-pe-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_private_dns_zone" "servicebus" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "servicebus" {
  name                = "servicebus-vnet-link"
  private_dns_zone_id = azurerm_private_dns_zone.servicebus.id
  virtual_network_id  = azurerm_virtual_network.example.id
}

module "eventhub" {
  source = "../.."

  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  namespace = {
    name = "evhns-pe-example-001"
    network_rules = {
      default_action                 = "Deny"
      trusted_service_access_enabled = true
    }
  }

  eventhubs = {
    eventhub-001 = {
      name = "eventhub-001"
    }
  }

  private_endpoint = {
    subnet_id           = azurerm_subnet.private_endpoints.id
    private_dns_zone_id = azurerm_private_dns_zone.servicebus.id
  }
}
