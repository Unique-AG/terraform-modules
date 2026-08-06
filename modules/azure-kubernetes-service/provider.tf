
terraform {
  required_version = ">= 1.12"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # 4.78+ required for workload_runtime = "KataVmIsolation" on azurerm_kubernetes_cluster_node_pool.
      version = "~> 4.78"
    }
  }
}
