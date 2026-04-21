terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# Example: ArgoCD Entra app registration aligned with gitops-resources defaults/global/argocd/policies
# (application_support, system_support, infrastructure_support role values in JWT).
module "entra_app" {
  source = "../.."

  display_name = "argocd-example"

  redirect_uris               = ["https://argocd.example.com/auth/callback"]
  redirect_uris_public_native = ["http://localhost:8085/auth/callback"]

  # Map Entra groups to app roles used by Argo CD RBAC (scopes: "[roles]").
  user_object_ids                   = ["00000000-0000-0000-0000-000000000010"]
  application_support_object_ids    = ["00000000-0000-0000-0000-000000000011"]
  system_support_object_ids         = ["00000000-0000-0000-0000-000000000012"]
  infrastructure_support_object_ids = ["00000000-0000-0000-0000-000000000013"]

  # Client secret: use output_enabled for a dry-run example; in production set keyvault_id instead.
  client_secret_generation_config = {
    enabled        = true
    output_enabled = true
    # keyvault_id = azurerm_key_vault.example.id
  }
}
