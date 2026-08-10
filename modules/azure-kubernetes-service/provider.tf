
terraform {
  required_version = ">= 1.12"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # 5.0+ required for workload_runtime = "KataVmIsolation" on azurerm_kubernetes_cluster_node_pool.
      version = "~> 5"
    }
  }
}
