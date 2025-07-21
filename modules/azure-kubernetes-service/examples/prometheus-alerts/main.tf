terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

data "azurerm_client_config" "current" {
}

# Variables for alert configuration
variable "alert_configuration" {
  description = "Configuration for AKS alerts and monitoring"
  type = object({
    email_receiver = optional(object({
      email_address = string
      name          = optional(string, "aks-alerts-email")
    }), null)
    action_group = optional(object({
      short_name = optional(string, "aks-alerts")
      location   = optional(string, "germanywestcentral")
    }), null)
  })
  default = null
}

resource "azurerm_resource_group" "aks_rg" {
  name     = "aks-prometheus-alerts-rg"
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

resource "azurerm_log_analytics_workspace" "aks_logs" {
  name                = "aks-logs-workspace"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Prometheus alert rules are defined in prometheus-alerts.tfvars
# This allows for easy reuse and modification of alert configurations

module "aks" {
  source              = "../.."
  resource_group_name = azurerm_resource_group.aks_rg.name
  tags = {
    environment = "test"
    purpose     = "prometheus-alerts-demo"
  }
  resource_group_location              = "switzerlandnorth"
  node_rg_name                         = "node-rg"
  default_subnet_nodes_id              = azurerm_subnet.aks_subnet.id
  default_subnet_pods_id               = azurerm_subnet.aks_subnet_pods.id
  cluster_name                         = "aks-prometheus-alerts"
  tenant_id                            = data.azurerm_client_config.current.tenant_id
  kubernetes_version                   = "1.32.3"
  kubernetes_default_node_size         = "Standard_D2s_v6"
  kubernetes_default_node_count_min    = 1
  kubernetes_default_node_count_max    = 3
  kubernetes_default_node_os_disk_size = 30
  log_analytics_workspace_id           = azurerm_log_analytics_workspace.aks_logs.id
  network_profile = {
    network_plugin          = "azure"
    outbound_ip_address_ids = [azurerm_public_ip.aks_ingress.id]
  }

  # Enable Prometheus monitoring
  azure_prometheus_grafana_monitor = {
    enabled                = true
    azure_monitor_location = "switzerlandnorth"
    azure_monitor_rg_name  = "monitor-rg"
    grafana_major_version  = 11
  }

  # Alert configuration - can be provided via tfvars or command line
  alert_configuration = var.alert_configuration

  # Alert rules are defined in prometheus-alerts.tfvars
  # To use this example, run: terraform apply -var-file="prometheus-alerts.tfvars"
} 