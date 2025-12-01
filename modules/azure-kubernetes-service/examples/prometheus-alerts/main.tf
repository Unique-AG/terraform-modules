terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# Data sources
data "azurerm_client_config" "current" {
}

# Random resources for unique naming
resource "random_string" "unique_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Local variables
locals {
  location      = "switzerlandnorth"
  log_location  = "westeurope"
  unique_suffix = random_string.unique_suffix.result
}

# Resource Group (foundation)
resource "azurerm_resource_group" "aks_rg" {
  name     = "aks-prometheus-alerts-rg-${local.unique_suffix}"
  location = local.location
}

# Networking resources
resource "azurerm_virtual_network" "aks_vnet" {
  name                = "aks-vnet-${local.unique_suffix}"
  location            = local.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet-${local.unique_suffix}"
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  resource_group_name  = azurerm_resource_group.aks_rg.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "aks_subnet_pods" {
  name                 = "aks-subnet-pods-${local.unique_suffix}"
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  resource_group_name  = azurerm_resource_group.aks_rg.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "aks-delegation-${local.unique_suffix}"
    service_delegation {
      name    = "Microsoft.ContainerService/managedClusters"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_public_ip" "aks_ingress" {
  name                = "aks-ingress-pip-${local.unique_suffix}"
  sku                 = "Standard"
  location            = local.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  allocation_method   = "Static"
}

# Logging and Monitoring
resource "azurerm_log_analytics_workspace" "aks_logs" {
  name                = "aks-logs-workspace-${local.unique_suffix}"
  location            = local.log_location
  resource_group_name = azurerm_resource_group.aks_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Identity and Access Management
resource "azurerm_user_assigned_identity" "grafana_identity" {
  name                = "aks-grafana-identity-${local.unique_suffix}"
  location            = azurerm_log_analytics_workspace.aks_logs.location
  resource_group_name = azurerm_resource_group.aks_rg.name
}

resource "azurerm_role_assignment" "grafana_admin" {
  scope                = azurerm_resource_group.aks_rg.id
  role_definition_name = "Grafana Admin"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "monitor_metrics_reader" {
  scope                = azurerm_resource_group.aks_rg.id
  role_definition_name = "Monitoring Data Reader"
  principal_id         = azurerm_user_assigned_identity.grafana_identity.principal_id
}

# Main AKS Module
module "aks" {
  source              = "../.."
  resource_group_name = azurerm_resource_group.aks_rg.name
  tags = {
    environment = "test"
    purpose     = "prometheus-alerts-demo"
  }
  resource_group_location              = local.location
  node_rg_name                         = "node-rg-${local.unique_suffix}"
  default_subnet_nodes_id              = azurerm_subnet.aks_subnet.id
  default_subnet_pods_id               = azurerm_subnet.aks_subnet_pods.id
  cluster_name                         = "aks-prometheus-alerts-${local.unique_suffix}"
  tenant_id                            = data.azurerm_client_config.current.tenant_id
  kubernetes_version                   = "1.32.3"
  kubernetes_default_node_size         = "Standard_D2s_v5"
  kubernetes_default_node_count_min    = 1
  kubernetes_default_node_count_max    = 3
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
  prometheus_node_alert_rules           = var.prometheus_node_alert_rules
  prometheus_cluster_alert_rules        = var.prometheus_cluster_alert_rules
  prometheus_pod_alert_rules            = var.prometheus_pod_alert_rules
  prometheus_node_recording_rules       = var.prometheus_node_recording_rules
  prometheus_kubernetes_recording_rules = var.prometheus_kubernetes_recording_rules
  prometheus_ux_recording_rules         = var.prometheus_ux_recording_rules
  # Enable Prometheus monitoring
  azure_prometheus_grafana_monitor = {
    enabled                = true
    azure_monitor_location = local.log_location
    azure_monitor_rg_name  = azurerm_resource_group.aks_rg.name
    grafana_major_version  = 11
    identity = {
      type         = "UserAssigned"
      identity_ids = [azurerm_user_assigned_identity.grafana_identity.id]
    }
  }

  # Alert configuration - can be provided via tfvars or command line
  alert_configuration = var.alert_configuration

  # Disable default action groups for this example (no alert notifications)
  default_action_group_ids = null
} 