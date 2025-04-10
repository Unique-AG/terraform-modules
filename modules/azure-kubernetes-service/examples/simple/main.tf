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
  resource_group_location              = "switzerlandnorth"
  node_rg_name                         = "my-resource-group-aks-nodes"
  default_subnet_nodes_id              = azurerm_subnet.example.id
  cluster_name                         = "my-aks-cluster"
  tenant_id                            = "00000000-0000-0000-0000-000000000000"
  kubernetes_version                   = "1.30.0"
  kubernetes_default_node_size         = "Standard_D2s_v5"
  kubernetes_default_node_count_min    = 2
  kubernetes_default_node_count_max    = 5
  kubernetes_default_node_os_disk_size = 100
}
