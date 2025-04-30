terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

module "entra_app" {
  source = "../.."
  client_secret_generation_config = {
    enabled = false
  }
  display_name                   = "example-app"
  user_object_ids                = ["00000000-0000-0000-0000-000000000002"]
  application_support_object_ids = ["00000000-0000-0000-0000-000000000001"]
}
