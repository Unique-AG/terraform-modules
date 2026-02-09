terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  location            = "switzerlandnorth"
  resource_group_name = "my-resource-group"
  address_space       = ["10.0.0.0/22"]
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  virtual_network_name = azurerm_virtual_network.example.name
  resource_group_name  = "my-resource-group"
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "example" {
  name                = "example-public-ip"
  location            = "switzerlandnorth"
  resource_group_name = "my-resource-group"
  allocation_method   = "Static"
}

module "application_gateway" {
  source      = "../.."
  name_prefix = "example"
  zones       = ["1", "2", "3"]
  sku = {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  resource_group = {
    name     = "my-resource-group"
    location = "switzerlandnorth"
  }

  gateway_ip_configuration = {
    subnet_resource_id = azurerm_subnet.example.id
  }

  waf_custom_rules_allowed_ips_sensitive_paths = {
    chat-export-ip = {
      ip_allow_list    = ["127.0.0.1"]
      path_begin_withs = ["/chat/feature-p/some-path"]
    }
  }

  waf_custom_rules_exempted_uris = ["/scim"]

  public_frontend_ip_configuration = {
    ip_address_resource_id = azurerm_public_ip.example.id
  }

  tags = {
    environment = "example"
  }
}

