terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "aks_rg" {
  name     = "aks-nap-rg"
  location = "switzerlandnorth"
}

resource "azurerm_public_ip" "aks_egress" {
  name                = "aks-nap-egress-pip"
  sku                 = "Standard"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  allocation_method   = "Static"
}

resource "azurerm_virtual_network" "aks_vnet" {
  name                = "aks-nap-vnet"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  address_space       = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "aks_nodes" {
  name                 = "snet-aks-nodes"
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  resource_group_name  = azurerm_resource_group.aks_rg.name
  address_prefixes     = ["10.0.0.0/26"]

  delegation {
    name = "aks-delegation"
    service_delegation {
      name    = "Microsoft.ContainerService/managedClusters"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_log_analytics_workspace" "aks_logs" {
  name                = "aks-nap-logs"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "aks" {
  source = "../.."

  resource_group_name     = azurerm_resource_group.aks_rg.name
  resource_group_location = azurerm_resource_group.aks_rg.location
  node_rg_name            = "aks-nap-node-rg"
  cluster_name            = "aks-nap-cluster"
  tenant_id               = data.azurerm_client_config.current.tenant_id

  default_subnet_nodes_id = azurerm_subnet.aks_nodes.id

  segregated_node_and_pod_subnets_enabled = false

  kubernetes_version = "1.32.3"

  node_autoscaling = {
    mode = "node-auto-provisioning"
    node_auto_provisioning = {
      default_node_pools = "None"
    }
  }

  default_node_pool = {
    vm_size         = "Standard_D2ps_v6"
    node_count      = 1
    os_disk_size_gb = 30
    zones           = ["1", "3"]
  }

  node_pool_settings = {}

  log_analytics_workspace = {
    id                  = azurerm_log_analytics_workspace.aks_logs.id
    location            = azurerm_log_analytics_workspace.aks_logs.location
    resource_group_name = azurerm_resource_group.aks_rg.name
  }

  network_profile = {
    network_plugin              = "azure"
    network_plugin_mode         = "overlay"
    network_data_plane          = "cilium"
    network_policy              = "cilium"
    outbound_ip_address_ids     = [azurerm_public_ip.aks_egress.id]
    advanced_networking_enabled = true
  }

  default_action_group_ids = null

  tags = {
    environment = "test"
  }
}
