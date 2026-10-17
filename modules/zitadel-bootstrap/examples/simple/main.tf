terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
  required_providers {
    zitadel = {
      source  = "zitadel/zitadel"
      version = "= 3.4.0"
    }
  }
}

provider "zitadel" {
  domain       = "id.example.com"
  access_token = "example-token"
}

module "zitadel_bootstrap" {
  source = "../.."

  target_org_name   = "Example Tenant"
  frontend_base_url = "https://unique.example.com"

  human_users = {
    "alice@example.com" = {
      first_name = "Alice"
      last_name  = "Example"
      email      = "alice@example.com"
      roles      = ["chat.chat.basic", "chat.admin.all"]
    }
  }
  human_users_initial_password = "change-me-Example1!"
}
