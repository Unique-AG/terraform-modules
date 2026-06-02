# Private-only Application Gateway example.
# See README.md in this directory for prerequisites, migration, and troubleshooting.

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

resource "azurerm_subnet" "appgw" {
  name                 = "appgw-subnet"
  virtual_network_name = azurerm_virtual_network.example.name
  resource_group_name  = "my-resource-group"
  address_prefixes     = ["10.0.0.0/24"]

  # Mandatory delegation for any AppGW v2 created after 2025-05-05.
  delegation {
    name = "appgw-delegation"
    service_delegation {
      name = "Microsoft.Network/applicationGateways"
    }
  }
}

# No azurerm_public_ip — that is the whole point of private-only.

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
    subnet_resource_id = azurerm_subnet.appgw.id
  }

  # Private-only: public is explicitly null.
  public_frontend_ip_configuration = null

  private_frontend_ip_configuration = {
    private_ip_address = "10.0.0.5" # literal IP from the subnet CIDR (Static allocation)
    address_allocation = "Static"
    subnet_resource_id = azurerm_subnet.appgw.id
    # is_active_http_listener defaults to false; ignored in private-only mode.
  }

  # Override WAF defaults that don't apply without a public listener.
  waf_custom_rules_allowed_https_challenges = false # Let's Encrypt HTTP-01 is impractical on private-only

  tags = {
    environment = "example"
  }
}
