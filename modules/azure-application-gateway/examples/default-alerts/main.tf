terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
resource "azurerm_resource_group" "application_gateway" {
  name     = "rg-application-gateway"
  location = "switzerlandnorth"
}

# Action group for notifications
resource "azurerm_monitor_action_group" "application_gateway_alerts" {
  name                = "ag-application-gateway-action-group"
  resource_group_name = azurerm_resource_group.application_gateway.name
  short_name          = "appgwalerts"

  email_receiver {
    name          = "platform-team"
    email_address = "platform-team@contoso.com"
  }
}

resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  location            = "switzerlandnorth"
  resource_group_name = azurerm_resource_group.application_gateway.name
  address_space       = ["10.0.0.0/22"]
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  virtual_network_name = azurerm_virtual_network.example.name
  resource_group_name  = azurerm_resource_group.application_gateway.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "example" {
  name                = "example-public-ip"
  location            = "switzerlandnorth"
  resource_group_name = azurerm_resource_group.application_gateway.name
  allocation_method   = "Static"
}

module "application_gateway" {
  source      = "../.."
  name_prefix = "example"
  zones       = ["1", "2", "3"]

  resource_group = {
    name     = azurerm_resource_group.application_gateway.name
    location = "switzerlandnorth"
  }

  metric_alerts_external_action_group_ids = [
    azurerm_monitor_action_group.application_gateway_alerts.id
  ]

  gateway_ip_configuration = {
    subnet_resource_id = azurerm_subnet.example.id
  }

  public_frontend_ip_configuration = {
    ip_address_resource_id = azurerm_public_ip.example.id
  }

  tags = {
    environment = "example"
  }
}

