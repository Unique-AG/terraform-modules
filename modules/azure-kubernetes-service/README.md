# Azure Kubernetes Service

## Pre-requisites
- To deploy this module, you have at least the following permissions:
    + Reader of the subscription
    + Contributor of the resource group

## SKUs
The Azure portal is unreliable to list all available SKUS to choose from (especially matching the Availibility Zones).
```
az vm list-skus --location <region> --zone --output table
az vm list-skus --location switzerlandnorth --zone --output table
```
Listing the SKUs specifically gives you insights wether your planned SKU is available for each zone.

## Examples

The module includes two example configurations:

1. **Simple Example** (`./examples/simple/`): Basic AKS cluster with default settings
2. **Custom Node Pools Example** (`./examples/custom-pools/`): Advanced configuration with multiple node pools

To run an example:

1. Navigate to the example directory:
   ```bash
   cd modules/azure-kubernetes-service/examples/simple  # or custom-pools
   ```

2. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. When done:
   ```bash
   terraform destroy
   ```

Remember to update the following variables in the example:
- `resource_group_name`
- `tenant_id`
- `resource_group_location`
- `cluster_name`
- `node_rg_name`

## Networking

The AKS module supports various networking configurations to meet different deployment requirements. Here are the key networking features:

### Network Profile
The cluster supports configurable network profiles through the `network_profile` variable:

```hcl
network_profile = {
  network_plugin = "azure"  # or "kubenet"
  network_policy = "azure"  # or "calico"
  service_cidr   = "172.20.0.0/16"
  dns_service_ip = "172.20.0.10"
  outbound_type  = "loadBalancer"  # or "userDefinedRouting"

  # Outbound configuration (mutually exclusive options)
  managed_outbound_ip_count = 1  # Option 1: Number of managed outbound IPs
  outbound_ip_address_ids   = [] # Option 2: List of existing public IP IDs
  outbound_ip_prefix_ids    = [] # Option 3: List of existing public IP prefix IDs
}
```

#### Network Profile Validation Rules:
1. When `outbound_type` is set to `"loadBalancer"`, you must specify exactly one of:
   - `managed_outbound_ip_count`: Number of managed outbound IPs to create
   - `outbound_ip_address_ids`: List of existing public IP IDs to use
   - `outbound_ip_prefix_ids`: List of existing public IP prefix IDs to use

2. These outbound configuration options are mutually exclusive - you can only specify one of them.

### Subnet Configuration
The module supports separate subnets for nodes and pods:

- **Default Node Pool**:
  - Node subnet: `default_subnet_nodes_id`
  - Pod subnet: `default_subnet_pods_id` (optional,defaults to node subnet for backwards compatibility)

- **Additional Node Pools**:
  - Each node pool can have its own subnet configuration through `node_pool_settings`
  - Supports separate subnets for nodes and pods per pool
  - Falls back to default subnets if not specified

If desired to merge node and pod subnets (not recommended for production but maybe for test and very small clusters), set `segregated_node_and_pod_subnets_enabled` to `false`, defaults to `true`.

### Outbound Traffic
The cluster supports two outbound traffic configurations:

1. **Load Balancer (Default)**:
   - Uses Azure Load Balancer for outbound traffic
   - Requires one of the following configurations:
     ```hcl
     network_profile = {
       outbound_type = "loadBalancer"
       managed_outbound_ip_count = 1  # Option 1: Create new managed IPs
     }
     # OR
     network_profile = {
       outbound_type = "loadBalancer"
       outbound_ip_address_ids = ["/subscriptions/.../publicIPs/ip1"]  # Option 2: Use existing IPs
     }
     # OR
     network_profile = {
       outbound_type = "loadBalancer"
       outbound_ip_prefix_ids = ["/subscriptions/.../publicIPPrefixes/prefix1"]  # Option 3: Use existing prefixes
     }
     ```

2. **User Defined Routing**:
   - Allows custom routing configuration
   - Useful for scenarios requiring specific routing rules
   - Configuration:
     ```hcl
     network_profile = {
       outbound_type = "userDefinedRouting"
     }
     ```

### Private Cluster
The cluster can be deployed as a private cluster with the following options:

- `private_cluster_enabled`: Enable/disable private cluster
- `private_dns_zone_id`: Specify private DNS zone for the cluster
- `private_cluster_public_fqdn_enabled`: Control public FQDN visibility

### API Server Access
Control access to the Kubernetes API server:

- `api_server_authorized_ip_ranges`: Specify allowed IP ranges
- When using private cluster, this is required for management access

### Network Security
The module includes several security features:

- Azure Policy integration (`azure_policy_enabled`)
- Microsoft Defender integration
- Network policy support (Azure or Calico)
- Private cluster deployment option

### Best Practices
1. Use separate subnets for nodes and pods when possible
2. Enable network policies for enhanced security
3. Consider private cluster deployment for production workloads
4. Use user-defined routing when specific routing rules are required
5. Configure appropriate API server access controls
6. When using Load Balancer outbound type, carefully choose between managed IPs and existing IPs/prefixes based on your requirements

# Module

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.15 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.15 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_dashboard_grafana.grafana](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dashboard_grafana) | resource |
| [azurerm_kubernetes_cluster.cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.node_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_log_analytics_workspace_table.basic_log_table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace_table) | resource |
| [azurerm_monitor_action_group.aks_alerts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_action_group) | resource |
| [azurerm_monitor_alert_prometheus_rule_group.cluster_level_alerts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_alert_prometheus_rule_group) | resource |
| [azurerm_monitor_alert_prometheus_rule_group.kubernetes_recording_rules_rule_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_alert_prometheus_rule_group) | resource |
| [azurerm_monitor_alert_prometheus_rule_group.node_level_alerts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_alert_prometheus_rule_group) | resource |
| [azurerm_monitor_alert_prometheus_rule_group.node_recording_rules_rule_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_alert_prometheus_rule_group) | resource |
| [azurerm_monitor_alert_prometheus_rule_group.pod_level_alerts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_alert_prometheus_rule_group) | resource |
| [azurerm_monitor_alert_prometheus_rule_group.ux_recording_rules_rule_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_alert_prometheus_rule_group) | resource |
| [azurerm_monitor_data_collection_endpoint.monitor_dce](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_endpoint) | resource |
| [azurerm_monitor_data_collection_rule.ci_dcr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule) | resource |
| [azurerm_monitor_data_collection_rule.monitor_dcr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule) | resource |
| [azurerm_monitor_data_collection_rule_association.ci_dcr_asc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule_association) | resource |
| [azurerm_monitor_data_collection_rule_association.monitor_dcr_asc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule_association) | resource |
| [azurerm_monitor_diagnostic_setting.aks_diagnostic_logs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_workspace.monitor_workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_workspace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_group_object_ids"></a> [admin\_group\_object\_ids](#input\_admin\_group\_object\_ids) | The object IDs of the admin groups for the Kubernetes Cluster. | `list(string)` | `[]` | no |
| <a name="input_alert_configuration"></a> [alert\_configuration](#input\_alert\_configuration) | Configuration for AKS alerts and monitoring | <pre>object({<br/>    email_receiver = optional(object({<br/>      email_address = string<br/>      name          = optional(string, "aks-alerts-email")<br/>    }), null)<br/>    action_group = optional(object({<br/>      short_name = optional(string, "aks-alerts")<br/>      location   = optional(string, "germanywestcentral")<br/>    }), null)<br/>  })</pre> | `null` | no |
| <a name="input_api_server_authorized_ip_ranges"></a> [api\_server\_authorized\_ip\_ranges](#input\_api\_server\_authorized\_ip\_ranges) | The IP ranges that are allowed to access the Kubernetes API server. | `list(string)` | `null` | no |
| <a name="input_application_gateway_id"></a> [application\_gateway\_id](#input\_application\_gateway\_id) | The ID of the Application Gateway. | `string` | `null` | no |
| <a name="input_automatic_upgrade_channel"></a> [automatic\_upgrade\_channel](#input\_automatic\_upgrade\_channel) | The automatic upgrade channel for the Kubernetes Cluster. | `string` | `"stable"` | no |
| <a name="input_azure_policy_enabled"></a> [azure\_policy\_enabled](#input\_azure\_policy\_enabled) | Specifies whether Azure Policy is enabled for the Kubernetes Cluster. | `bool` | `true` | no |
| <a name="input_azure_prometheus_grafana_monitor"></a> [azure\_prometheus\_grafana\_monitor](#input\_azure\_prometheus\_grafana\_monitor) | Specifies a Prometheus-Grafana add-on profile for the Kubernetes Cluster. | <pre>object({<br/>    enabled                = bool<br/>    azure_monitor_location = string<br/>    azure_monitor_rg_name  = string<br/>    grafana_major_version  = optional(number, 10)<br/>    identity = optional(object({<br/>      type         = string<br/>      identity_ids = optional(list(string))<br/>      }), {<br/>      type = "SystemAssigned"<br/>    })<br/>  })</pre> | <pre>{<br/>  "azure_monitor_location": "westeurope",<br/>  "azure_monitor_rg_name": "monitor-rg",<br/>  "enabled": false,<br/>  "grafana_major_version": 11,<br/>  "identity": {<br/>    "type": "SystemAssigned"<br/>  }<br/>}</pre> | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the Kubernetes cluster. | `string` | n/a | yes |
| <a name="input_cost_analysis_enabled"></a> [cost\_analysis\_enabled](#input\_cost\_analysis\_enabled) | Specifies whether cost analysis is enabled for the Kubernetes Cluster. | `bool` | `true` | no |
| <a name="input_default_subnet_nodes_id"></a> [default\_subnet\_nodes\_id](#input\_default\_subnet\_nodes\_id) | The ID of the subnet for nodes. Primarily used for the default node pool. For additional node pools, supply subnet settings in the node\_pool\_settings for more granular control. | `string` | n/a | yes |
| <a name="input_default_subnet_pods_id"></a> [default\_subnet\_pods\_id](#input\_default\_subnet\_pods\_id) | The ID of the subnet for pods. Primarily used for the default node pool. If not provided, the node subnet will be used for pods. While this can be null for backwards compatibility, segregating pods and nodes into separate subnets is recommended for production environments. For additional node pools, supply subnet settings in the node\_pool\_settings for more granular control. | `string` | `null` | no |
| <a name="input_defender_log_analytics_workspace_id"></a> [defender\_log\_analytics\_workspace\_id](#input\_defender\_log\_analytics\_workspace\_id) | The ID of the Log Analytics Workspace for Microsoft Defender | `string` | `null` | no |
| <a name="input_dns_service_ip"></a> [dns\_service\_ip](#input\_dns\_service\_ip) | The DNS service IP for the Kubernetes Cluster. | `string` | `"172.20.0.10"` | no |
| <a name="input_kubernetes_default_node_count_max"></a> [kubernetes\_default\_node\_count\_max](#input\_kubernetes\_default\_node\_count\_max) | The maximum number of nodes in the default node pool. | `number` | `5` | no |
| <a name="input_kubernetes_default_node_count_min"></a> [kubernetes\_default\_node\_count\_min](#input\_kubernetes\_default\_node\_count\_min) | The minimum number of nodes in the default node pool. | `number` | `2` | no |
| <a name="input_kubernetes_default_node_os_disk_size"></a> [kubernetes\_default\_node\_os\_disk\_size](#input\_kubernetes\_default\_node\_os\_disk\_size) | The OS disk size in GB for default node pool VMs. | `number` | `100` | no |
| <a name="input_kubernetes_default_node_size"></a> [kubernetes\_default\_node\_size](#input\_kubernetes\_default\_node\_size) | The size of the default node pool VMs. | `string` | `"Standard_D2s_v5"` | no |
| <a name="input_kubernetes_default_node_zones"></a> [kubernetes\_default\_node\_zones](#input\_kubernetes\_default\_node\_zones) | The availability zones for the default node pool. | `list(string)` | <pre>[<br/>  "1",<br/>  "3"<br/>]</pre> | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The Kubernetes version to use for the AKS cluster. If not specified (null), the latest stable version will be used and version changes will be ignored. If specified, version changes will be tracked. | `string` | `null` | no |
| <a name="input_local_account_disabled"></a> [local\_account\_disabled](#input\_local\_account\_disabled) | Specifies whether the local account is disabled for the Kubernetes Cluster. | `bool` | `true` | no |
| <a name="input_log_analytics_workspace"></a> [log\_analytics\_workspace](#input\_log\_analytics\_workspace) | The Log Analytics Workspace configuration for monitoring and logging. | <pre>object({<br/>    id                  = string<br/>    location            = string<br/>    resource_group_name = string<br/>  })</pre> | `null` | no |
| <a name="input_log_table_plan"></a> [log\_table\_plan](#input\_log\_table\_plan) | The pricing tier for the Log Analytics Workspace Table. | `string` | `"Basic"` | no |
| <a name="input_maintenance_window_auto_upgrade"></a> [maintenance\_window\_auto\_upgrade](#input\_maintenance\_window\_auto\_upgrade) | The maintenance window for automatic upgrades of the Kubernetes cluster. | <pre>object({<br/>    frequency    = optional(string, "Weekly")<br/>    interval     = optional(number, 2)<br/>    duration     = optional(number, 6)<br/>    day_of_week  = optional(string, "Sunday")<br/>    day_of_month = optional(number, null)<br/>    week_index   = optional(string, null)<br/>    start_time   = optional(string, "18:00")<br/>    utc_offset   = optional(string, "+00:00")<br/>    start_date   = optional(string, null)<br/>    not_allowed = optional(list(object({<br/>      start = string<br/>      end   = string<br/>    })), [])<br/>  })</pre> | `null` | no |
| <a name="input_maintenance_window_day"></a> [maintenance\_window\_day](#input\_maintenance\_window\_day) | The day of the maintenance window. | `string` | `"Sunday"` | no |
| <a name="input_maintenance_window_end"></a> [maintenance\_window\_end](#input\_maintenance\_window\_end) | The end hour of the maintenance window. | `number` | `23` | no |
| <a name="input_maintenance_window_node_os"></a> [maintenance\_window\_node\_os](#input\_maintenance\_window\_node\_os) | The maintenance window for node OS upgrades of the Kubernetes cluster. | <pre>object({<br/>    frequency    = optional(string, "Weekly")<br/>    interval     = optional(number, 1)<br/>    duration     = optional(number, 6)<br/>    day_of_week  = optional(string, "Sunday")<br/>    day_of_month = optional(number, null)<br/>    week_index   = optional(string, null)<br/>    start_time   = optional(string, "00:00")<br/>    utc_offset   = optional(string, "+00:00")<br/>    start_date   = optional(string, null)<br/>    not_allowed = optional(list(object({<br/>      start = string<br/>      end   = string<br/>    })), [])<br/>  })</pre> | `null` | no |
| <a name="input_maintenance_window_start"></a> [maintenance\_window\_start](#input\_maintenance\_window\_start) | The start hour of the maintenance window. | `number` | `16` | no |
| <a name="input_max_surge"></a> [max\_surge](#input\_max\_surge) | The maximum number of nodes to surge during upgrades. | `number` | `1` | no |
| <a name="input_monitoring_account_name"></a> [monitoring\_account\_name](#input\_monitoring\_account\_name) | The name of the monitoring account | `string` | `"MonitoringAccount1"` | no |
| <a name="input_network_profile"></a> [network\_profile](#input\_network\_profile) | Network profile configuration for the AKS cluster. Note: managed\_outbound\_ip\_count, outbound\_ip\_address\_ids, and outbound\_ip\_prefix\_ids are mutually exclusive. | <pre>object({<br/>    network_data_plane        = optional(string)<br/>    network_plugin            = optional(string, "azure")<br/>    network_plugin_mode       = optional(string, null)<br/>    network_policy            = optional(string)<br/>    service_cidr              = optional(string, "172.20.0.0/16")<br/>    dns_service_ip            = optional(string, "172.20.0.10")<br/>    outbound_type             = optional(string, "loadBalancer")<br/>    managed_outbound_ip_count = optional(number, null)<br/>    outbound_ip_address_ids   = optional(list(string), null)<br/>    outbound_ip_prefix_ids    = optional(list(string), null)<br/>    idle_timeout_in_minutes   = optional(number, 30)<br/>  })</pre> | <pre>{<br/>  "network_plugin": "azure"<br/>}</pre> | no |
| <a name="input_node_os_upgrade_channel"></a> [node\_os\_upgrade\_channel](#input\_node\_os\_upgrade\_channel) | The upgrade channel for the node OS image. Possible values are Unmanaged, SecurityPatch, NodeImage, None. | `string` | `"NodeImage"` | no |
| <a name="input_node_pool_settings"></a> [node\_pool\_settings](#input\_node\_pool\_settings) | The settings for the node pools. Note that if you specify a subnet\_pods\_id for one of the node pools, you must specify it for all node pools. | <pre>map(object({<br/>    vm_size                     = string<br/>    min_count                   = optional(number)<br/>    max_count                   = optional(number)<br/>    max_pods                    = optional(number)<br/>    os_disk_size_gb             = number<br/>    os_sku                      = optional(string, "AzureLinux")<br/>    os_type                     = optional(string, "Linux")<br/>    node_labels                 = map(string)<br/>    node_taints                 = list(string)<br/>    auto_scaling_enabled        = bool<br/>    mode                        = string<br/>    zones                       = list(string)<br/>    subnet_nodes_id             = optional(string, null)<br/>    subnet_pods_id              = optional(string, null)<br/>    temporary_name_for_rotation = optional(string, null)<br/>    upgrade_settings = object({<br/>      max_surge = string<br/>    })<br/>  }))</pre> | <pre>{<br/>  "burst": {<br/>    "auto_scaling_enabled": true,<br/>    "max_count": 10,<br/>    "min_count": 0,<br/>    "mode": "User",<br/>    "node_count": 0,<br/>    "node_labels": {<br/>      "pool": "burst"<br/>    },<br/>    "node_taints": [<br/>      "burst=true:NoSchedule"<br/>    ],<br/>    "os_disk_size_gb": 100,<br/>    "temporary_name_for_rotation": "burstrepl",<br/>    "upgrade_settings": {<br/>      "max_surge": "10%"<br/>    },<br/>    "vm_size": "Standard_D8s_v5",<br/>    "zones": [<br/>      "1",<br/>      "3"<br/>    ]<br/>  },<br/>  "stable": {<br/>    "auto_scaling_enabled": true,<br/>    "max_count": 10,<br/>    "min_count": 2,<br/>    "mode": "User",<br/>    "node_count": 1,<br/>    "node_labels": {<br/>      "pool": "stable"<br/>    },<br/>    "node_taints": [],<br/>    "os_disk_size_gb": 100,<br/>    "os_sku": "AzureLinux",<br/>    "temporary_name_for_rotation": "stablerepl",<br/>    "upgrade_settings": {<br/>      "max_surge": "10%"<br/>    },<br/>    "vm_size": "Standard_D8s_v5",<br/>    "zones": [<br/>      "1",<br/>      "3"<br/>    ]<br/>  }<br/>}</pre> | no |
| <a name="input_node_rg_name"></a> [node\_rg\_name](#input\_node\_rg\_name) | The name of the node resource group for the AKS cluster. | `string` | n/a | yes |
| <a name="input_oidc_issuer_enabled"></a> [oidc\_issuer\_enabled](#input\_oidc\_issuer\_enabled) | The OIDC issuer URL for the Kubernetes Cluster. | `bool` | `true` | no |
| <a name="input_private_cluster_enabled"></a> [private\_cluster\_enabled](#input\_private\_cluster\_enabled) | Specifies whether the Kubernetes Cluster is private. | `bool` | `true` | no |
| <a name="input_private_cluster_public_fqdn_enabled"></a> [private\_cluster\_public\_fqdn\_enabled](#input\_private\_cluster\_public\_fqdn\_enabled) | Specifies whether the private cluster has a public FQDN. | `bool` | `true` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | The ID of the private DNS zone. | `string` | `"None"` | no |
| <a name="input_prometheus_cluster_alert_rules"></a> [prometheus\_cluster\_alert\_rules](#input\_prometheus\_cluster\_alert\_rules) | Cluster level alert rules for Prometheus monitoring | <pre>list(object({<br/>    action = optional(object({<br/>      action_group_id = string<br/>    }))<br/>    alert       = optional(string)<br/>    annotations = optional(map(string))<br/>    enabled     = optional(bool)<br/>    expression  = string<br/>    for         = optional(string)<br/>    labels      = optional(map(string))<br/>    record      = optional(string)<br/>    alert_resolution = optional(object({<br/>      auto_resolved   = bool<br/>      time_to_resolve = string<br/>    }))<br/>    severity = optional(number)<br/>  }))</pre> | `null` | no |
| <a name="input_prometheus_kubernetes_recording_rules"></a> [prometheus\_kubernetes\_recording\_rules](#input\_prometheus\_kubernetes\_recording\_rules) | Kubernetes level recording rules for Prometheus monitoring | <pre>list(object({<br/>    enabled    = optional(bool, true)<br/>    record     = string<br/>    expression = string<br/>    labels     = optional(map(string))<br/>  }))</pre> | `null` | no |
| <a name="input_prometheus_node_alert_rules"></a> [prometheus\_node\_alert\_rules](#input\_prometheus\_node\_alert\_rules) | Node level alert rules for Prometheus monitoring | <pre>list(object({<br/>    action = optional(object({<br/>      action_group_id = string<br/>    }))<br/>    alert       = optional(string)<br/>    annotations = optional(map(string))<br/>    enabled     = optional(bool)<br/>    expression  = string<br/>    for         = optional(string)<br/>    labels      = optional(map(string))<br/>    record      = optional(string)<br/>    alert_resolution = optional(object({<br/>      auto_resolved   = bool<br/>      time_to_resolve = string<br/>    }))<br/>    severity = optional(number)<br/>  }))</pre> | `null` | no |
| <a name="input_prometheus_node_recording_rules"></a> [prometheus\_node\_recording\_rules](#input\_prometheus\_node\_recording\_rules) | Node level recording rules for Prometheus monitoring | <pre>list(object({<br/>    enabled    = optional(bool, true)<br/>    record     = string<br/>    expression = string<br/>    labels     = optional(map(string))<br/>  }))</pre> | `null` | no |
| <a name="input_prometheus_pod_alert_rules"></a> [prometheus\_pod\_alert\_rules](#input\_prometheus\_pod\_alert\_rules) | Pod level alert rules for Prometheus monitoring | <pre>list(object({<br/>    action = optional(object({<br/>      action_group_id = string<br/>    }))<br/>    alert       = optional(string)<br/>    annotations = optional(map(string))<br/>    enabled     = optional(bool)<br/>    expression  = string<br/>    for         = optional(string)<br/>    labels      = optional(map(string))<br/>    record      = optional(string)<br/>    alert_resolution = optional(object({<br/>      auto_resolved   = bool<br/>      time_to_resolve = string<br/>    }))<br/>    severity = optional(number)<br/>  }))</pre> | `null` | no |
| <a name="input_prometheus_ux_recording_rules"></a> [prometheus\_ux\_recording\_rules](#input\_prometheus\_ux\_recording\_rules) | UX level recording rules for Prometheus monitoring | <pre>list(object({<br/>    enabled    = optional(bool, true)<br/>    record     = string<br/>    expression = string<br/>    labels     = optional(map(string))<br/>  }))</pre> | `null` | no |
| <a name="input_resource_group_location"></a> [resource\_group\_location](#input\_resource\_group\_location) | The location of the resource group. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group. | `string` | n/a | yes |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | The retention period in days for the Log Analytics Workspace. | `number` | `30` | no |
| <a name="input_segregated_node_and_pod_subnets_enabled"></a> [segregated\_node\_and\_pod\_subnets\_enabled](#input\_segregated\_node\_and\_pod\_subnets\_enabled) | Some legacy or smaller clusters might not want to split nodes and pods into different subnets. Falsifying this will force the module to only use 1 subnet for both nodes and pods. It is not recommended for production use cases. | `bool` | `true` | no |
| <a name="input_service_cidr"></a> [service\_cidr](#input\_service\_cidr) | The service CIDR for the Kubernetes Cluster. | `string` | `"172.20.0.0/16"` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | The SKU tier for the Kubernetes Cluster. | `string` | `"Standard"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources. | `map(string)` | `{}` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | The tenant ID for the Azure subscription. | `string` | n/a | yes |
| <a name="input_workload_identity_enabled"></a> [workload\_identity\_enabled](#input\_workload\_identity\_enabled) | Specifies whether workload identity is enabled for the Kubernetes Cluster. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agic_identity_client_id"></a> [agic\_identity\_client\_id](#output\_agic\_identity\_client\_id) | The client ID of the identity used by the Application Gateway Ingress Controller. |
| <a name="output_agic_identity_object_id"></a> [agic\_identity\_object\_id](#output\_agic\_identity\_object\_id) | The object ID of the identity used by the Application Gateway Ingress Controller. |
| <a name="output_cluster_resource"></a> [cluster\_resource](#output\_cluster\_resource) | The properties of the Kubernetes cluster. |
| <a name="output_csi_identity_client_id"></a> [csi\_identity\_client\_id](#output\_csi\_identity\_client\_id) | The client ID of the identity used by the CSI driver. |
| <a name="output_csi_identity_object_id"></a> [csi\_identity\_object\_id](#output\_csi\_identity\_object\_id) | The object ID of the identity used by the CSI driver. |
| <a name="output_csi_user_assigned_identity_name"></a> [csi\_user\_assigned\_identity\_name](#output\_csi\_user\_assigned\_identity\_name) | The name of the user-assigned identity for the CSI driver. Prefer using the csi\_identity\_client\_id and csi\_identity\_object\_id outputs as they are more reliable. |
| <a name="output_grafana_identity_principal_id"></a> [grafana\_identity\_principal\_id](#output\_grafana\_identity\_principal\_id) | The principal ID of the Grafana identity. |
| <a name="output_kubernetes_cluster_id"></a> [kubernetes\_cluster\_id](#output\_kubernetes\_cluster\_id) | The ID of the Kubernetes cluster. |
| <a name="output_kubernetes_node_rg_name"></a> [kubernetes\_node\_rg\_name](#output\_kubernetes\_node\_rg\_name) | The name of the node resource group. This name is important as the CSI driver identity is created there. |
| <a name="output_kublet_identity_client_id"></a> [kublet\_identity\_client\_id](#output\_kublet\_identity\_client\_id) | The client ID of the identity used by the kubelet. |
| <a name="output_kublet_identity_object_id"></a> [kublet\_identity\_object\_id](#output\_kublet\_identity\_object\_id) | The object ID of the identity used by the kubelet. |
<!-- END_TF_DOCS -->

## Upgrading

### ~> `3.0.0`

Version 3.0.0 introduces several breaking changes to improve subnet configuration flexibility and network profile management:

#### Subnet Configuration Changes

1. The `subnet_nodes_id` variable has been replaced with `default_subnet_nodes_id`:
   ```hcl
   # Before
   subnet_nodes_id = "subnet-id"

   # After
   default_subnet_nodes_id = "subnet-id"
   ```

2. Added support for pod subnet separation with new variables:
   ```hcl
   default_subnet_pods_id = "pod-subnet-id"  # Optional, recommended for production
   segregated_node_and_pod_subnets_enabled = true  # Set to false to use single subnet for nodes and pods
   ```

3. Node pools can now specify their own subnet configurations:
   ```hcl
   node_pool_settings = {
     pool1 = {
       # ... existing settings ...
       subnet_nodes_id = "custom-node-subnet-id"  # Optional
       subnet_pods_id  = "custom-pod-subnet-id"   # Optional
     }
   }
   ```

#### Network Profile Changes

1. The `outbound_ip_address_ids` variable has been removed and replaced with a comprehensive `network_profile` variable:
   ```hcl
   # Before
   outbound_ip_address_ids = ["ip-id-1", "ip-id-2"]

   # After
   network_profile = {
     outbound_type           = "loadBalancer"
     outbound_ip_address_ids = ["ip-id-1", "ip-id-2"]
     network_plugin = "azure"
     network_policy = "azure"
     service_cidr   = "172.20.0.0/16"
     dns_service_ip = "172.20.0.10"
   }
   ```

2. The network profile now supports multiple outbound configurations:
   - `managed_outbound_ip_count`
   - `outbound_ip_address_ids`
   - `outbound_ip_prefix_ids`

   Note: These options are mutually exclusive, and one must be specified when using `outbound_type = "loadBalancer"`.

#### Migration Steps

1. Replace `subnet_nodes_id` with `default_subnet_nodes_id`

2. Pod subnet separation:

   **Option 1 - Pod subnet separation (recommended):**
   - Use separate subnets for pods and nodes
   - Add `default_subnet_pods_id`
   - Ensure `segregated_node_and_pod_subnets_enabled = true` (this is the default value)
   - Update node pool configurations to use the new subnet variables:
     ```hcl
     node_pool_settings = {
       pool1 = {
         # ... other settings ...
         subnet_nodes_id = "custom-node-subnet-id"  # Optional
         subnet_pods_id  = "custom-pod-subnet-id"   # Optional
       }
     }
     ```

   **Option 2 - No pod subnet separation:**
   - Have pods use the same subnet as nodes
   - Set `segregated_node_and_pod_subnets_enabled = false`

4. Replace `outbound_ip_address_ids` with the new `network_profile` configuration

### ~> `4.0.0`

Version 4.0.0 introduces several breaking changes to improve network configuration flexibility, monitoring capabilities, and simplify node pool management:

#### Network Profile Changes

1. **Network Policy Default Removed**: The `network_policy` property no longer defaults to "azure". You must explicitly set it if needed:

   ```hcl
   # Before (3.2.0)
   network_profile = {
     idle_timeout_in_minutes = 100
     outbound_ip_address_ids = ["ip-id-1", "ip-id-2"]
     # network_policy defaulted to "azure"
   }

   # After (4.0.0)
   network_profile = {
     idle_timeout_in_minutes = 100
     network_policy = "azure"  # Must be explicitly set
     outbound_ip_address_ids = ["ip-id-1", "ip-id-2"]
   }
   ```

   This change enables support for [Bring your own Container Network Interface (CNI) plugin with Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/use-byo-cni?tabs=azure-cli):

   ```hcl
   network_profile = {
     network_plugin = "none"  # BYO CNI
     outbound_ip_address_ids = ["ip-id-1", "ip-id-2"]
   }
   ```

2. **Network Data Plane Support**: Added support for `network_data_plane` configuration:

   ```hcl
   network_profile = {
     network_plugin     = "azure"
     network_data_plane = "cilium"  # New option
     network_policy     = "cilium"
   }
   ```

#### Log Analytics Workspace Changes

The `log_analytics_workspace_id` variable has been replaced with a more flexible `log_analytics_workspace` object:

```hcl
# Before (3.2.0)
log_analytics_workspace_id = "/subscriptions/.../resourceGroups/.../providers/Microsoft.OperationalInsights/workspaces/my-workspace"

# After (4.0.0)
log_analytics_workspace = {
  id                  = "/subscriptions/.../resourceGroups/.../providers/Microsoft.OperationalInsights/workspaces/my-workspace"
  location            = "westeurope"
  resource_group_name = "monitoring-rg"
}
```

Note: The new variable is optional/nullable, allowing for configurations without log analytics.

#### Node Pool Settings Changes

The unused `node_count` variable has been removed from `node_pool_settings`:

```hcl
# Before (3.2.0)
node_pool_settings = {
  stable = {
    node_count           = 1  # This was not used
    auto_scaling_enabled = true
    vm_size              = "Standard_D2s_v6"
    min_count            = 2
    max_count            = 5
    # ... other settings
  }
}

# After (4.0.0)
node_pool_settings = {
  stable = {
    auto_scaling_enabled = true
    vm_size              = "Standard_D2s_v6"
    min_count            = 2
    max_count            = 5
    # ... other settings
  }
}
```

#### Prometheus Alert Rules Changes

Prometheus alert rule variables now default to `null` instead of pre-configured rules:

```hcl
# Before (3.2.0) - extensive default alert rules were provided
# No configuration needed for basic alerts

# After (4.0.0) - must explicitly configure if needed
prometheus_node_alert_rules = [
  {
    alert      = "KubeNodeUnreachable"
    enabled    = true
    expression = "..."
    # ... configure your specific alert rules
  }
]

prometheus_cluster_alert_rules = [
  # ... configure your cluster-level alerts
]

prometheus_pod_alert_rules = [
  # ... configure your pod-level alerts
]
```

#### Azure Prometheus Grafana Monitor Changes

1. **Grafana Version**: Default major version changed from 10 to 11
2. **Identity Configuration**: Added identity configuration options

```hcl
# Before (3.2.0)
azure_prometheus_grafana_monitor = {
  enabled               = true
  grafana_major_version = 10  # Default was 10
  # ... other settings
}

# After (4.0.0)
azure_prometheus_grafana_monitor = {
  enabled               = true
  grafana_major_version = 11  # Default is now 11
  identity = {
    type = "SystemAssigned"  # New identity configuration
  }
  # ... other settings
}
```

#### Alert Configuration (New Feature)

Version 4.0.0 introduces optional alert configuration:

```hcl
alert_configuration = {
  email_receiver = {
    email_address = "alerts@example.com"
    name         = "aks-alerts-email"
  }
  action_group = {
    short_name = "aks-alerts"
    location   = "germanywestcentral"
  }
}
```

#### Migration Steps

1. **Update Network Profile**: Explicitly set `network_policy` if you were relying on the default "azure" value

2. **Replace Log Analytics Configuration**: Convert `log_analytics_workspace_id` to the new object format

3. **Remove node_count**: Remove the `node_count` field from your `node_pool_settings`

4. **Configure Prometheus Alerts**: If you were using the default alert rules, you'll need to explicitly configure them or set them to `null`

5. **Update Grafana Version**: If you need Grafana v10, explicitly set `grafana_major_version = 10`

6. **Review Resource Naming**: Monitor-related resources have updated naming patterns, which may affect existing deployments

#### Example Migration

```hcl
# Before (3.2.0)
module "aks" {
  source = "path/to/azure-kubernetes-service"
  
  log_analytics_workspace_id = "/subscriptions/.../workspaces/my-workspace"
  
  network_profile = {
    outbound_ip_address_ids = [azurerm_public_ip.example.id]
    # network_policy defaulted to "azure"
  }
  
  node_pool_settings = {
    stable = {
      node_count           = 1
      auto_scaling_enabled = true
      vm_size              = "Standard_D2s_v6"
      min_count            = 2
      max_count            = 5
    }
  }
  
  azure_prometheus_grafana_monitor = {
    enabled = true
    # grafana_major_version defaulted to 10
  }
}

# After (4.0.0)
module "aks" {
  source = "path/to/azure-kubernetes-service"
  
  log_analytics_workspace = {
    id                  = "/subscriptions/.../workspaces/my-workspace"
    location            = "westeurope"
    resource_group_name = "monitoring-rg"
  }
  
  network_profile = {
    network_policy          = "azure"  # Must be explicit
    outbound_ip_address_ids = [azurerm_public_ip.example.id]
  }
  
  node_pool_settings = {
    stable = {
      # node_count removed
      auto_scaling_enabled = true
      vm_size              = "Standard_D2s_v6"
      min_count            = 2
      max_count            = 5
    }
  }
  
  azure_prometheus_grafana_monitor = {
    enabled               = true
    grafana_major_version = 10  # Explicit if you need v10
    identity = {
      type = "SystemAssigned"
    }
  }
  
  # Configure alerts explicitly if needed
  prometheus_node_alert_rules    = null
  prometheus_cluster_alert_rules = null
  prometheus_pod_alert_rules     = null
}