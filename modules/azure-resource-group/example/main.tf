terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
module "rg" {
  source = "../"
  resource_groups = {
    rg1 = {
      name     = "rg1"
      location = "eastus"
      tags = {
        environment = "dev"
      }
    }
    rg2 = {
      name     = "rg2"
      location = "westus"
      tags = {
        environment = "dev"
      }
    }
  }
}
