# Input validations are checked on the module itself with a mocked provider; no credentials are needed.
mock_provider "azurerm" {}

variables {
  cluster_name            = "aks-example-tenant-env"
  resource_group_name     = "rg-example"
  resource_group_location = "switzerlandnorth"
  node_rg_name            = "rg-example-nodes"
  tenant_id               = "00000000-0000-0000-0000-000000000000"
  default_subnet_nodes_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/virtualNetworks/vnet/subnets/nodes"

  default_action_group_ids = null
  network_profile = {
    network_plugin            = "azure"
    network_plugin_mode       = "overlay"
    managed_outbound_ip_count = 1
  }
}

run "pod_cidr_requires_overlay" {
  command = plan

  variables {
    network_profile = {
      network_plugin            = "azure"
      managed_outbound_ip_count = 1
      pod_cidr                  = "10.244.0.0/16"
    }
  }

  expect_failures = [var.network_profile]
}

run "pod_cidr_must_be_a_cidr" {
  command = plan

  variables {
    network_profile = {
      network_plugin            = "azure"
      network_plugin_mode       = "overlay"
      managed_outbound_ip_count = 1
      pod_cidr                  = "not-a-cidr"
    }
  }

  expect_failures = [var.network_profile]
}

run "user_assigned_identity_requires_one_id" {
  command = plan

  variables {
    control_plane_identity = {
      type = "UserAssigned"
    }
  }

  expect_failures = [var.control_plane_identity]
}

run "system_assigned_identity_rejects_ids" {
  command = plan

  variables {
    control_plane_identity = {
      identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id"]
    }
  }

  expect_failures = [var.control_plane_identity]
}
