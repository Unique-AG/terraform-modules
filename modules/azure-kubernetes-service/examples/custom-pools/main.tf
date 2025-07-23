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
  address_space       = ["10.0.0.0/22"]
}

resource "azurerm_subnet" "nodes" {
  name                 = "snet  -nodes"
  virtual_network_name = azurerm_virtual_network.example.name
  resource_group_name  = "my-resource-group"
  address_prefixes     = ["10.0.0.0/23"]
}

resource "azurerm_subnet" "pods" {
  name                 = "snet-pods"
  virtual_network_name = azurerm_virtual_network.example.name
  resource_group_name  = "my-resource-group"
  address_prefixes     = ["10.0.2.0/23"]
}

resource "azurerm_log_analytics_workspace" "aks_law" {
  name                = "aks-log-analytics"
  location            = "switzerlandnorth"
  resource_group_name = "my-resource-group"
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags = {
    environment = "test"
  }
}

resource "azurerm_resource_group" "aks_rg" {
  name     = "my-resource-group"
  location = "switzerlandnorth"
}

module "aks" {
  source = "../.."

  resource_group_name     = "my-resource-group"
  resource_group_location = "switzerlandnorth"
  log_analytics_workspace = {
    id                  = azurerm_log_analytics_workspace.aks_law.id
    location            = azurerm_log_analytics_workspace.aks_law.location
    resource_group_name = azurerm_resource_group.aks_rg.name
  }

  cluster_name = "my-aks-cluster"
  node_rg_name = "my-resource-group-aks-nodes"
  tenant_id    = "00000000-0000-0000-0000-000000000000"

  # Network configuration
  default_subnet_nodes_id = azurerm_subnet.nodes.id
  default_subnet_pods_id  = azurerm_subnet.pods.id

  # Outbound configuration
  network_profile = {
    network_plugin          = "azure"
    network_policy          = "azure"
    outbound_type           = "loadBalancer"
    outbound_ip_address_ids = [azurerm_public_ip.example.id]
  }

  node_pool_settings = {
    myuserpool = {
      auto_scaling_enabled        = true
      max_count                   = 10
      max_pods                    = 45
      min_count                   = 2
      mode                        = "User"
      node_taints                 = []
      os_disk_size_gb             = 100
      os_sku                      = "AzureLinux"
      vnet_subnet_id              = azurerm_subnet.nodes.id
      pod_subnet_id               = azurerm_subnet.pods.id
      temporary_name_for_rotation = "myuserpoolrepl"
      vm_size                     = "Standard_D8s_v5"
      zones                       = ["1", "2", "3"]
      node_labels = {
        pool = "myuser"
      }
      upgrade_settings = {
        max_surge = "2"
      }
    }
  }
}
