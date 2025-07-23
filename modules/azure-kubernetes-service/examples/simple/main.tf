terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "aks_rg" {
  name     = "aks-rg"
  location = "switzerlandnorth"
}
resource "azurerm_public_ip" "aks_ingress" {
  name                = "aks-ingress-pip"
  sku                 = "Standard"
  location            = "switzerlandnorth"
  resource_group_name = azurerm_resource_group.aks_rg.name
  allocation_method   = "Static"
}

resource "azurerm_virtual_network" "aks_vnet" {
  name                = "aks-vnet"
  location            = "switzerlandnorth"
  resource_group_name = azurerm_resource_group.aks_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  resource_group_name  = azurerm_resource_group.aks_rg.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "aks_subnet_pods" {
  name                 = "aks-subnet-pods"
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  resource_group_name  = azurerm_resource_group.aks_rg.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "aks-delegation"
    service_delegation {
      name    = "Microsoft.ContainerService/managedClusters"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "stable_nodes" {
  name                 = "stable-nodes"
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  resource_group_name  = azurerm_resource_group.aks_rg.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "stable_pods" {
  name                 = "stable-pods"
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  resource_group_name  = azurerm_resource_group.aks_rg.name
  address_prefixes     = ["10.0.4.0/24"]

  delegation {
    name = "aks-delegation"
    service_delegation {
      name    = "Microsoft.ContainerService/managedClusters"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_log_analytics_workspace" "aks_logs" {
  name                = "aks-logs-workspace"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "aks" {
  source              = "../.."
  resource_group_name = azurerm_resource_group.aks_rg.name
  tags = {
    environment = "test"
  }
  resource_group_location              = "switzerlandnorth"
  node_rg_name                         = "node-rg"
  default_subnet_nodes_id              = azurerm_subnet.aks_subnet.id
  default_subnet_pods_id               = azurerm_subnet.aks_subnet_pods.id
  cluster_name                         = "aks-cluster"
  tenant_id                            = data.azurerm_client_config.current.tenant_id
  kubernetes_version                   = "1.32.3"
  kubernetes_default_node_size         = "Standard_D2s_v6"
  kubernetes_default_node_count_min    = 1
  kubernetes_default_node_count_max    = 1
  kubernetes_default_node_os_disk_size = 30
  log_analytics_workspace = {
    id                  = azurerm_log_analytics_workspace.aks_logs.id
    location            = azurerm_log_analytics_workspace.aks_logs.location
    resource_group_name = azurerm_resource_group.aks_rg.name
  }
  network_profile = {
    network_plugin          = "azure"
    outbound_ip_address_ids = [azurerm_public_ip.aks_ingress.id]
  }
  maintenance_window_auto_upgrade = {
    frequency   = "Weekly"
    interval    = 1
    duration    = 4
    day_of_week = "Sunday"
    start_time  = "02:00"
    utc_offset  = "+01:00"
  }

  maintenance_window_node_os = {
    frequency   = "Weekly"
    interval    = 1
    duration    = 4
    day_of_week = "Saturday"
    start_time  = "01:00"
    utc_offset  = "+01:00"
  }

  node_pool_settings = {
    stable = {
      subnet_nodes_id                      = azurerm_subnet.stable_nodes.id
      subnet_pods_id                       = azurerm_subnet.stable_pods.id
      kubernetes_default_node_os_disk_size = 30
      node_labels = {
        "app" = "stable"
      }
      node_taints = [
        "app=stable:NoSchedule"
      ]
      auto_scaling_enabled = false
      mode                 = "User"
      zones                = ["1"]
      vm_size              = "Standard_D2s_v6"
      upgrade_settings = {
        max_surge = "1"
      }
      os_disk_type    = "Standard_LRS"
      os_disk_size_gb = 30
    }
  }
}