terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "aks_rg" {
  name     = "aks-overlay-nap-rg"
  location = "switzerlandnorth"
}

resource "azurerm_public_ip" "aks_egress" {
  name                = "aks-overlay-nap-egress-pip"
  sku                 = "Standard"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  allocation_method   = "Static"
}

resource "azurerm_virtual_network" "aks_vnet" {
  name                = "aks-overlay-nap-vnet"
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

# The control plane identity is created and granted its subnet role before the cluster,
# so the grant survives deleting and creating the cluster again.
resource "azurerm_user_assigned_identity" "aks_control_plane" {
  name                = "id-aks-overlay-nap-control-plane"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
}

resource "azurerm_role_assignment" "aks_control_plane_subnet" {
  scope                = azurerm_subnet.aks_nodes.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_control_plane.principal_id
}

resource "azurerm_log_analytics_workspace" "aks_logs" {
  name                = "aks-overlay-nap-logs"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "aks" {
  source = "../.."

  resource_group_name     = azurerm_resource_group.aks_rg.name
  resource_group_location = azurerm_resource_group.aks_rg.location
  node_rg_name            = "aks-overlay-nap-node-rg"
  cluster_name            = "aks-overlay-nap-cluster-v2"
  tenant_id               = data.azurerm_client_config.current.tenant_id

  default_subnet_nodes_id = azurerm_subnet.aks_nodes.id

  segregated_node_and_pod_subnets_enabled = false

  kubernetes_version = "1.32.3"

  control_plane_identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_control_plane.id]
  }

  node_autoscaling = {
    mode = "node-auto-provisioning"
    node_auto_provisioning = {
      default_node_pools = "None"
    }
  }

  # Fixed system pool; the other capacity is provisioned by node auto provisioning.
  default_node_pool = {
    vm_size         = "Standard_D4ads_v6"
    node_count      = 2
    os_disk_size_gb = 128
    zones           = ["2", "3"]
  }

  # Fixed pools next to node auto provisioning need a node_count and no auto scaling.
  node_pool_settings = {
    fixedextra = {
      vm_size              = "Standard_D4ads_v6"
      node_count           = 1
      os_disk_size_gb      = 128
      node_labels          = {}
      node_taints          = []
      auto_scaling_enabled = false
      mode                 = "User"
      zones                = ["2", "3"]
      upgrade_settings = {
        max_surge = "10%"
      }
    }
  }

  kata_node_pool_settings = {
    kata = {
      vm_size              = "Standard_D8s_v5"
      node_count           = 1
      os_disk_size_gb      = 128
      auto_scaling_enabled = false
      zones                = ["2", "3"]
      upgrade_settings = {
        max_surge = "10%"
      }
    }
  }

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
    pod_cidr                    = "10.244.0.0/16"
    service_cidr                = "172.20.0.0/16"
    dns_service_ip              = "172.20.0.10"
    outbound_ip_address_ids     = [azurerm_public_ip.aks_egress.id]
    advanced_networking_enabled = true
  }

  default_action_group_ids = null

  tags = {
    environment = "test"
  }

  depends_on = [azurerm_role_assignment.aks_control_plane_subnet]
}
