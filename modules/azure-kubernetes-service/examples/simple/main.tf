terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
resource "azurerm_public_ip" "example" {
  name                = "example-public-ip"
  sku                 = "Standard"
  location            = "switzerlandnorth"
  resource_group_name = "my-resource-group"
  allocation_method   = "Static"
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
module "aks" {
  source              = "../.."
  resource_group_name = "my-resource-group"
  tags = {
    environment = "example"
  }
  resource_group_location = "switzerlandnorth"
  node_rg_name            = "my-resource-group-aks-nodes"
  subnet_nodes_id         = azurerm_subnet.example.id
  cluster_name            = "my-aks-cluster"
  tenant_id               = "00000000-0000-0000-0000-000000000000"
  outbound_ip_address_ids = [azurerm_public_ip.example.id]
}
