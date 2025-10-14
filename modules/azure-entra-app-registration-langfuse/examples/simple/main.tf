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

module "langfuse_app_with_secret" {
  source       = "../.."
  display_name = "langfuse-example-with-secret"

  client_secret_generation_config = {
    keyvault_id = data.azurerm_key_vault.example.id
    secret_name = "langfuse-app"
  }

  redirect_uris = ["https://yourapplication.com/api/auth/callback/azure-ad"]
  homepage_url  = "https://yourapplication.com"

  # Assign groups - all members will have access
  allowed_groups = ["11111111-1111-1111-1111-111111111111"]
}