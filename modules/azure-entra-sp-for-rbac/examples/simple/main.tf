terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# Example: With client secret stored in Key Vault
data "azurerm_key_vault" "example" {
  name                = "example-keyvault"
  resource_group_name = "example-rg"
}

module "entra_sp_with_secret" {
  source       = "../.."
  display_name = "entra-sp-example-with-secret"

  client_secret_generation_config = {
    keyvault_id = data.azurerm_key_vault.example.id
    secret_name = "sp-create-for-rbac"
  }
}
