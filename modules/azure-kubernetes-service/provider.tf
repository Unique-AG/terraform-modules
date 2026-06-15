
terraform {
  required_version = ">= 1.12"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # 4.57+ required for node_provisioning_profile.
      version = "~> 4.57"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.4"
    }
  }
}
