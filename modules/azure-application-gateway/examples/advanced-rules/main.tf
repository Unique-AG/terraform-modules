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
  source = "../.."

  file_upload_limit_in_mb                     = 100
  gateway_sku                                 = "WAF_v2"
  gateway_tier                                = "WAF_v2"
  ip_name                                     = "application-gateway-ip"
  max_request_body_size_exempted_request_uris = ["/scoped/ingestion/upload", "/ingestion/v1/content", "my/custom/upload-url"]
  max_request_body_size_in_kb                 = 128
  name_prefix                                 = "example"
  private_ip                                  = cidrhost("10.0.1.0/24", 6)
  resource_group_location                     = "switzerlandnorth"
  resource_group_name                         = "my-resource-group"
  subnet_appgw                                = azurerm_subnet.example.id
  waf_ip_allow_list                           = ["1.2.3.4", "5.6.7.8", "1.2.3.4/22"]

  tags = {
    environment = "example"
  }
}
