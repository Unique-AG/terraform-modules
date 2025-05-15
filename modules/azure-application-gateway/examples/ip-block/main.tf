terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  location            = "switzerlandnorth"
  resource_group_name = "my-resource-group"
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  virtual_network_name = azurerm_virtual_network.example.name
  resource_group_name  = "my-resource-group"
  address_prefixes     = ["10.0.1.0/24"]
}

module "application_gateway" {
  source                  = "../.."
  name_prefix             = "example"
  subnet_appgw            = azurerm_subnet.example.id
  gateway_sku             = "WAF_v2"
  gateway_tier            = "WAF_v2"
  private_ip              = cidrhost("10.0.1.0/24", 6)
  ip_name                 = "application-gateway-ip"
  resource_group_name     = "my-resource-group"
  resource_group_location = "switzerlandnorth"
  tags = {
    environment = "example"
  }

  waf_ip_allow_list = ["1.2.3.4", "5.6.7.8", "1.2.3.4/22"]
}
