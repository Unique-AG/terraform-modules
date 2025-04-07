# Azure Kubernetes Service

## Pre-requisites
- To deploy this module, you have at least the following permissions:
    + Reader of the subscription
    + Contributor of the resource group

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
| [azurerm_monitor_alert_prometheus_rule_group.cluster_level_alerts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_alert_prometheus_rule_group) | resource |
| [azurerm_monitor_alert_prometheus_rule_group.node_level_alerts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_alert_prometheus_rule_group) | resource |
| [azurerm_monitor_alert_prometheus_rule_group.pod_level_alerts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_alert_prometheus_rule_group) | resource |
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
| <a name="input_api_server_authorized_ip_ranges"></a> [api\_server\_authorized\_ip\_ranges](#input\_api\_server\_authorized\_ip\_ranges) | The IP ranges that are allowed to access the Kubernetes API server. | `list(string)` | `null` | no |
| <a name="input_application_gateway_id"></a> [application\_gateway\_id](#input\_application\_gateway\_id) | The ID of the Application Gateway. | `string` | `null` | no |
| <a name="input_automatic_upgrade_channel"></a> [automatic\_upgrade\_channel](#input\_automatic\_upgrade\_channel) | The automatic upgrade channel for the Kubernetes Cluster. | `string` | `"stable"` | no |
| <a name="input_azure_policy_enabled"></a> [azure\_policy\_enabled](#input\_azure\_policy\_enabled) | Specifies whether Azure Policy is enabled for the Kubernetes Cluster. | `bool` | `true` | no |
| <a name="input_azure_prometheus_grafana_monitor"></a> [azure\_prometheus\_grafana\_monitor](#input\_azure\_prometheus\_grafana\_monitor) | Specifies a Prometheus-Grafana add-on profile for the Kubernetes Cluster. | <pre>object({<br/>    enabled                = bool<br/>    azure_monitor_location = string<br/>    azure_monitor_rg_name  = string<br/>    grafana_major_version  = optional(number, 10)<br/>  })</pre> | <pre>{<br/>  "azure_monitor_location": "westeurope",<br/>  "azure_monitor_rg_name": "monitor-rg",<br/>  "enabled": false,<br/>  "grafana_major_version": 10<br/>}</pre> | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the Kubernetes cluster. | `string` | n/a | yes |
| <a name="input_cost_analysis_enabled"></a> [cost\_analysis\_enabled](#input\_cost\_analysis\_enabled) | Specifies whether cost analysis is enabled for the Kubernetes Cluster. | `bool` | `true` | no |
| <a name="input_default_subnet_nodes_id"></a> [default\_subnet\_nodes\_id](#input\_default\_subnet\_nodes\_id) | The ID of the subnet for nodes. Primarily used for the default node pool, supply subnet settings for additional node pools for more granular control. | `string` | n/a | yes |
| <a name="input_default_subnet_pods_id"></a> [default\_subnet\_pods\_id](#input\_default\_subnet\_pods\_id) | if not given, uses node subnet for podsThe ID of the subnet for pods. For backwards compatibility with earlier releases this can be nullified. It is though recommended to segregate pods and nodes. Primarily used for the default node pool, supply subnet settings for additional node pools for more granular control. | `string` | `null` | no |
| <a name="input_dns_service_ip"></a> [dns\_service\_ip](#input\_dns\_service\_ip) | The DNS service IP for the Kubernetes Cluster. | `string` | `"172.20.0.10"` | no |
| <a name="input_kubernetes_default_node_count_max"></a> [kubernetes\_default\_node\_count\_max](#input\_kubernetes\_default\_node\_count\_max) | The maximum number of nodes in the default node pool. | `number` | `5` | no |
| <a name="input_kubernetes_default_node_count_min"></a> [kubernetes\_default\_node\_count\_min](#input\_kubernetes\_default\_node\_count\_min) | The minimum number of nodes in the default node pool. | `number` | `2` | no |
| <a name="input_kubernetes_default_node_os_disk_size"></a> [kubernetes\_default\_node\_os\_disk\_size](#input\_kubernetes\_default\_node\_os\_disk\_size) | The OS disk size in GB for default node pool VMs. | `number` | `100` | no |
| <a name="input_kubernetes_default_node_size"></a> [kubernetes\_default\_node\_size](#input\_kubernetes\_default\_node\_size) | The size of the default node pool VMs. | `string` | `"Standard_D2s_v5"` | no |
| <a name="input_kubernetes_default_node_zones"></a> [kubernetes\_default\_node\_zones](#input\_kubernetes\_default\_node\_zones) | The availability zones for the default node pool. | `list(string)` | <pre>[<br/>  "1",<br/>  "2",<br/>  "3"<br/>]</pre> | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The Kubernetes version to use for the AKS cluster. | `string` | `"1.30.0"` | no |
| <a name="input_local_account_disabled"></a> [local\_account\_disabled](#input\_local\_account\_disabled) | Specifies whether the local account is disabled for the Kubernetes Cluster. | `bool` | `true` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | The ID of the Log Analytics Workspace. | `string` | `null` | no |
| <a name="input_log_table_plan"></a> [log\_table\_plan](#input\_log\_table\_plan) | The pricing tier for the Log Analytics Workspace Table. | `string` | `"Basic"` | no |
| <a name="input_maintenance_window_day"></a> [maintenance\_window\_day](#input\_maintenance\_window\_day) | The day of the maintenance window. | `string` | `"Sunday"` | no |
| <a name="input_maintenance_window_end"></a> [maintenance\_window\_end](#input\_maintenance\_window\_end) | The end hour of the maintenance window. | `number` | `23` | no |
| <a name="input_maintenance_window_start"></a> [maintenance\_window\_start](#input\_maintenance\_window\_start) | The start hour of the maintenance window. | `number` | `16` | no |
| <a name="input_max_surge"></a> [max\_surge](#input\_max\_surge) | The maximum number of nodes to surge during upgrades. | `number` | `1` | no |
| <a name="input_monitoring_account_name"></a> [monitoring\_account\_name](#input\_monitoring\_account\_name) | The name of the monitoring account | `string` | `"MonitoringAccount1"` | no |
| <a name="input_network_profile"></a> [network\_profile](#input\_network\_profile) | Network profile configuration for the AKS cluster. Note: managed\_outbound\_ip\_count, outbound\_ip\_address\_ids, and outbound\_ip\_prefix\_ids are mutually exclusive. | <pre>object({<br/>    network_plugin            = optional(string, "azure")<br/>    network_policy            = optional(string, "azure")<br/>    service_cidr              = optional(string, "172.20.0.0/16")<br/>    dns_service_ip            = optional(string, "172.20.0.10")<br/>    outbound_type             = optional(string, "loadBalancer")<br/>    managed_outbound_ip_count = optional(number, null)<br/>    outbound_ip_address_ids   = optional(list(string), null)<br/>    outbound_ip_prefix_ids    = optional(list(string), null)<br/>  })</pre> | `null` | no |
| <a name="input_node_pool_settings"></a> [node\_pool\_settings](#input\_node\_pool\_settings) | The settings for the node pools. Note that if you specify a subnet\_pods\_id for one of the node pools, you must specify it for all node pools. | <pre>map(object({<br/>    vm_size                     = string<br/>    node_count                  = optional(number)<br/>    min_count                   = number<br/>    max_count                   = number<br/>    max_pods                    = optional(number)<br/>    os_disk_size_gb             = number<br/>    os_sku                      = optional(string, "Ubuntu")<br/>    os_type                     = optional(string, "Linux")<br/>    node_labels                 = map(string)<br/>    node_taints                 = list(string)<br/>    auto_scaling_enabled        = bool<br/>    mode                        = string<br/>    zones                       = list(string)<br/>    subnet_nodes_id             = optional(string, null)<br/>    subnet_pods_id              = optional(string, null)<br/>    temporary_name_for_rotation = optional(string, null)<br/>    upgrade_settings = object({<br/>      max_surge = string<br/>    })<br/>  }))</pre> | <pre>{<br/>  "burst": {<br/>    "auto_scaling_enabled": true,<br/>    "max_count": 10,<br/>    "min_count": 0,<br/>    "mode": "User",<br/>    "node_count": 0,<br/>    "node_labels": {<br/>      "pool": "burst"<br/>    },<br/>    "node_taints": [<br/>      "burst=true:NoSchedule"<br/>    ],<br/>    "os_disk_size_gb": 100,<br/>    "temporary_name_for_rotation": "burstrepl",<br/>    "upgrade_settings": {<br/>      "max_surge": "10%"<br/>    },<br/>    "vm_size": "Standard_D8s_v5",<br/>    "zones": [<br/>      "1",<br/>      "2",<br/>      "3"<br/>    ]<br/>  },<br/>  "stable": {<br/>    "auto_scaling_enabled": true,<br/>    "max_count": 10,<br/>    "min_count": 2,<br/>    "mode": "User",<br/>    "node_count": 1,<br/>    "node_labels": {<br/>      "pool": "stable"<br/>    },<br/>    "node_taints": [],<br/>    "os_disk_size_gb": 100,<br/>    "os_sku": "AzureLinux",<br/>    "temporary_name_for_rotation": "stablerepl",<br/>    "upgrade_settings": {<br/>      "max_surge": "10%"<br/>    },<br/>    "vm_size": "Standard_D8s_v5",<br/>    "zones": [<br/>      "1",<br/>      "2",<br/>      "3"<br/>    ]<br/>  }<br/>}</pre> | no |
| <a name="input_node_rg_name"></a> [node\_rg\_name](#input\_node\_rg\_name) | The name of the node resource group for the AKS cluster. | `string` | n/a | yes |
| <a name="input_oidc_issuer_enabled"></a> [oidc\_issuer\_enabled](#input\_oidc\_issuer\_enabled) | The OIDC issuer URL for the Kubernetes Cluster. | `bool` | `true` | no |
| <a name="input_private_cluster_enabled"></a> [private\_cluster\_enabled](#input\_private\_cluster\_enabled) | Specifies whether the Kubernetes Cluster is private. | `bool` | `true` | no |
| <a name="input_private_cluster_public_fqdn_enabled"></a> [private\_cluster\_public\_fqdn\_enabled](#input\_private\_cluster\_public\_fqdn\_enabled) | Specifies whether the private cluster has a public FQDN. | `bool` | `true` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | The ID of the private DNS zone. | `string` | `"None"` | no |
| <a name="input_prometheus_cluster_alert_rules"></a> [prometheus\_cluster\_alert\_rules](#input\_prometheus\_cluster\_alert\_rules) | n/a | <pre>list(object({<br/>    action = optional(object({<br/>      action_group_id = string<br/>    }))<br/>    alert       = optional(string)<br/>    annotations = optional(map(string))<br/>    enabled     = optional(bool)<br/>    expression  = string<br/>    for         = optional(string)<br/>    labels      = optional(map(string))<br/>    record      = optional(string)<br/>    alert_resolution = optional(object({<br/>      auto_resolved   = bool<br/>      time_to_resolve = string<br/>    }))<br/>    severity = optional(number)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "alert": "KubeCPUQuotaOvercommit",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT10M"<br/>    },<br/>    "annotations": {<br/>      "description": "Cluster {{ $labels.cluster }} has overcommitted CPU resource requests for Namespaces. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/cluster-level-recommended-alerts)."<br/>    },<br/>    "enabled": true,<br/>    "expression": "sum(min without(resource) (kube_resourcequota{job=\"kube-state-metrics\", type=\"hard\", resource=~\"(cpu|requests.cpu)\"})) / sum(kube_node_status_allocatable{resource=\"cpu\", job=\"kube-state-metrics\"}) > 1.5",<br/>    "for": "PT5M",<br/>    "labels": {<br/>      "severity": "warning"<br/>    },<br/>    "severity": 3<br/>  },<br/>  {<br/>    "alert": "KubeMemoryQuotaOvercommit",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT10M"<br/>    },<br/>    "annotations": {<br/>      "description": "Cluster {{ $labels.cluster }} has overcommitted memory resource requests for Namespaces. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/cluster-level-recommended-alerts)."<br/>    },<br/>    "enabled": true,<br/>    "expression": "sum(min without(resource) (kube_resourcequota{job=\"kube-state-metrics\", type=\"hard\", resource=~\"(memory|requests.memory)\"})) / sum(kube_node_status_allocatable{resource=\"memory\", job=\"kube-state-metrics\"}) > 1.5",<br/>    "for": "PT5M",<br/>    "labels": {},<br/>    "severity": 3<br/>  },<br/>  {<br/>    "alert": "KubeContainerOOMKilledCount",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT10M"<br/>    },<br/>    "annotations": {<br/>      "description": "Number of OOM killed containers is greater than 0. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/cluster-level-recommended-alerts)."<br/>    },<br/>    "enabled": true,<br/>    "expression": "sum by (cluster,container,controller,namespace) (kube_pod_container_status_last_terminated_reason{reason=\"OOMKilled\"} * on(cluster,namespace,pod) group_left(controller) label_replace(kube_pod_owner, \"controller\", \"$1\", \"owner_name\", \".*\")) > 0",<br/>    "for": "PT5M",<br/>    "labels": {},<br/>    "severity": 4<br/>  },<br/>  {<br/>    "alert": "KubeClientErrors",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT10M"<br/>    },<br/>    "annotations": {<br/>      "description": "Kubernetes API server client '{{ $labels.job }}/{{ $labels.instance }}' is experiencing {{ $value | humanizePercentage }} errors. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/cluster-level-recommended-alerts)."<br/>    },<br/>    "enabled": true,<br/>    "expression": "(sum(rate(rest_client_requests_total{code=~\"5..\"}[5m])) by (cluster, instance, job, namespace) / sum(rate(rest_client_requests_total[5m])) by (cluster, instance, job, namespace)) > 0.01",<br/>    "for": "PT15M",<br/>    "labels": {},<br/>    "severity": 3<br/>  },<br/>  {<br/>    "alert": "KubePersistentVolumeFillingUp",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT15M"<br/>    },<br/>    "annotations": {<br/>      "description": "Based on recent sampling, the PersistentVolume claimed by {{ $labels.persistentvolumeclaim }} in Namespace {{ $labels.namespace }} is expected to fill up within four days. Currently {{ $value | humanizePercentage }} is available. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/cluster-level-recommended-alerts)."<br/>    },<br/>    "enabled": true,<br/>    "expression": "kubelet_volume_stats_available_bytes{job=\"kubelet\"}/kubelet_volume_stats_capacity_bytes{job=\"kubelet\"} < 0.15 and kubelet_volume_stats_used_bytes{job=\"kubelet\"} > 0 and predict_linear(kubelet_volume_stats_available_bytes{job=\"kubelet\"}[6h], 4 * 24 * 3600) < 0 unless on(namespace, persistentvolumeclaim) kube_persistentvolumeclaim_access_mode{access_mode=\"ReadOnlyMany\"} == 1 unless on(namespace, persistentvolumeclaim) kube_persistentvolumeclaim_labels{label_excluded_from_alerts=\"true\"} == 1",<br/>    "for": "PT15M",<br/>    "labels": {},<br/>    "severity": 4<br/>  },<br/>  {<br/>    "alert": "KubePersistentVolumeInodesFillingUp",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT10M"<br/>    },<br/>    "annotations": {<br/>      "description": "The PersistentVolume claimed by {{ $labels.persistentvolumeclaim }} in Namespace {{ $labels.namespace }} only has {{ $value | humanizePercentage }} free inodes. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/cluster-level-recommended-alerts)."<br/>    },<br/>    "enabled": true,<br/>    "expression": "kubelet_volume_stats_inodes_free{job=\"kubelet\"} / kubelet_volume_stats_inodes{job=\"kubelet\"} < 0.03",<br/>    "for": "PT15M",<br/>    "labels": {},<br/>    "severity": 4<br/>  },<br/>  {<br/>    "alert": "KubePersistentVolumeErrors",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT10M"<br/>    },<br/>    "annotations": {<br/>      "description": "The persistent volume {{ $labels.persistentvolume }} has status {{ $labels.phase }}. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/cluster-level-recommended-alerts)."<br/>    },<br/>    "enabled": true,<br/>    "expression": "kube_persistentvolume_status_phase{phase=~\"Failed|Pending\",job=\"kube-state-metrics\"} > 0",<br/>    "for": "PT15M",<br/>    "labels": {},<br/>    "severity": 4<br/>  },<br/>  {<br/>    "alert": "KubeDaemonSetNotScheduled",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT10M"<br/>    },<br/>    "annotations": {<br/>      "description": "{{ $value }} Pods of DaemonSet {{ $labels.namespace }}/{{ $labels.daemonset }} are not scheduled. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/cluster-level-recommended-alerts)."<br/>    },<br/>    "enabled": true,<br/>    "expression": "kube_daemonset_status_desired_number_scheduled{job=\"kube-state-metrics\"} - kube_daemonset_status_current_number_scheduled{job=\"kube-state-metrics\"} > 0",<br/>    "for": "PT15M",<br/>    "labels": {},<br/>    "severity": 3<br/>  },<br/>  {<br/>    "alert": "KubeDaemonSetMisScheduled",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT10M"<br/>    },<br/>    "annotations": {<br/>      "description": "{{ $value }} Pods of DaemonSet {{ $labels.namespace }}/{{ $labels.daemonset }} are running where they are not supposed to run. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/cluster-level-recommended-alerts)."<br/>    },<br/>    "enabled": true,<br/>    "expression": "kube_daemonset_status_number_misscheduled{job=\"kube-state-metrics\"} > 0",<br/>    "for": "PT15M",<br/>    "labels": {},<br/>    "severity": 3<br/>  },<br/>  {<br/>    "alert": "KubeQuotaAlmostFull",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT10M"<br/>    },<br/>    "annotations": {<br/>      "description": "{{ $value | humanizePercentage }} usage of {{ $labels.resource }} in namespace {{ $labels.namespace }} in {{ $labels.cluster }}. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/cluster-level-recommended-alerts)."<br/>    },<br/>    "enabled": true,<br/>    "expression": "kube_resourcequota{job=\"kube-state-metrics\", type=\"used\"} / ignoring(instance, job, type)(kube_resourcequota{job=\"kube-state-metrics\", type=\"hard\"} > 0) > 0.9 < 1",<br/>    "for": "PT15M",<br/>    "labels": {},<br/>    "severity": 3<br/>  }<br/>]</pre> | no |
| <a name="input_prometheus_node_alert_rules"></a> [prometheus\_node\_alert\_rules](#input\_prometheus\_node\_alert\_rules) | n/a | <pre>list(object({<br/>    action = optional(object({<br/>      action_group_id = string<br/>    }))<br/>    alert       = optional(string)<br/>    annotations = optional(map(string))<br/>    enabled     = optional(bool)<br/>    expression  = string<br/>    for         = optional(string)<br/>    labels      = optional(map(string))<br/>    record      = optional(string)<br/>    alert_resolution = optional(object({<br/>      auto_resolved   = bool<br/>      time_to_resolve = string<br/>    }))<br/>    severity = optional(number)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "alert": "KubeNodeUnreachable",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT10M"<br/>    },<br/>    "annotations": {<br/>      "description": "{{ $labels.node }} in {{ $labels.cluster }} is unreachable."<br/>    },<br/>    "enabled": true,<br/>    "expression": "(kube_node_spec_taint{job=\"kube-state-metrics\",key=\"node.kubernetes.io/unreachable\",effect=\"NoSchedule\"} unless ignoring(key,value) kube_node_spec_taint{job=\"kube-state-metrics\",key=~\"ToBeDeletedByClusterAutoscaler|cloud.google.com/imminent-node-termination|aws-node-termination-handler/spot-itn\"} == 1)\n",<br/>    "for": "PT15M",<br/>    "labels": {<br/>      "alert_name": "KubeNodeUnreachable",<br/>      "team": "prod"<br/>    },<br/>    "severity": 3<br/>  },<br/>  {<br/>    "alert": "KubeNodeReadinessFlapping",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT10M"<br/>    },<br/>    "annotations": {<br/>      "description": "Node readiness is flapping."<br/>    },<br/>    "enabled": true,<br/>    "expression": "sum(changes(kube_node_status_condition{status=\"true\",condition=\"Ready\"}[15m])) by (cluster, node) > 2",<br/>    "for": "PT15M",<br/>    "labels": {<br/>      "alert_name": "KubeNodeReadinessFlapping",<br/>      "team": "prod"<br/>    },<br/>    "severity": 3<br/>  }<br/>]</pre> | no |
| <a name="input_prometheus_pod_alert_rules"></a> [prometheus\_pod\_alert\_rules](#input\_prometheus\_pod\_alert\_rules) | n/a | <pre>list(object({<br/>    action = optional(object({<br/>      action_group_id = string<br/>    }))<br/>    alert       = optional(string)<br/>    annotations = optional(map(string))<br/>    enabled     = optional(bool)<br/>    expression  = string<br/>    for         = optional(string)<br/>    labels      = optional(map(string))<br/>    record      = optional(string)<br/>    alert_resolution = optional(object({<br/>      auto_resolved   = bool<br/>      time_to_resolve = string<br/>    }))<br/>    severity = optional(number)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "alert": "KubePVUsageHigh",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT10M"<br/>    },<br/>    "annotations": {<br/>      "description": "Average PV usage on pod {{ $labels.pod }} in container {{ $labels.container }} is greater than 80%. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."<br/>    },<br/>    "enabled": true,<br/>    "expression": "avg by (namespace, controller, container, cluster) (\n  (kubelet_volume_stats_used_bytes{job=\"kubelet\"} / on(namespace, cluster, pod, container) group_left\n  kubelet_volume_stats_capacity_bytes{job=\"kubelet\"}) * on(namespace, pod, cluster) group_left(controller)\n  label_replace(kube_pod_owner, \"controller\", \"$1\", \"owner_name\", \"(.*)\")\n) > 0.8\n",<br/>    "for": "PT15M",<br/>    "labels": {<br/>      "alert_name": "KubePVUsageHigh"<br/>    },<br/>    "severity": 3<br/>  },<br/>  {<br/>    "alert": "KubeDeploymentReplicasMismatch",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT15M"<br/>    },<br/>    "annotations": {<br/>      "description": "Deployment {{ $labels.namespace }}/{{ $labels.deployment }} in {{ $labels.cluster}} replica mismatch. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."<br/>    },<br/>    "enabled": true,<br/>    "expression": "(\n  kube_deployment_spec_replicas{job=\"kube-state-metrics\"} > kube_deployment_status_replicas_available{job=\"kube-state-metrics\"}\n  and (changes(kube_deployment_status_replicas_updated{job=\"kube-state-metrics\"}[10m]) == 0)\n)\n",<br/>    "for": "PT15M",<br/>    "labels": {<br/>      "alert_name": "KubeDeploymentReplicasMismatch"<br/>    },<br/>    "severity": 4<br/>  },<br/>  {<br/>    "alert": "KubeStatefulSetReplicasMismatch",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT10M"<br/>    },<br/>    "annotations": {<br/>      "description": "StatefulSet {{ $labels.namespace }}/{{ $labels.statefulset }} in {{ $labels.cluster}} replica mismatch. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."<br/>    },<br/>    "enabled": true,<br/>    "expression": "(\n  kube_statefulset_status_replicas_ready{job=\"kube-state-metrics\"} != kube_statefulset_status_replicas{job=\"kube-state-metrics\"}\n  and (changes(kube_statefulset_status_replicas_updated{job=\"kube-state-metrics\"}[10m]) == 0)\n)\n",<br/>    "for": "PT15M",<br/>    "labels": {<br/>      "alert_name": "KubeStatefulSetReplicasMismatch"<br/>    },<br/>    "severity": 4<br/>  },<br/>  {<br/>    "alert": "KubeHpaReplicasMismatch",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT15M"<br/>    },<br/>    "annotations": {<br/>      "description": "Horizontal Pod Autoscaler in {{ $labels.cluster}} has not matched the desired number of replicas for longer than 15 minutes. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."<br/>    },<br/>    "enabled": true,<br/>    "expression": "(\n  kube_horizontalpodautoscaler_status_desired_replicas{job=\"kube-state-metrics\"} != kube_horizontalpodautoscaler_status_current_replicas{job=\"kube-state-metrics\"}\n  and (kube_horizontalpodautoscaler_status_current_replicas{job=\"kube-state-metrics\"} > kube_horizontalpodautoscaler_spec_min_replicas{job=\"kube-state-metrics\"})\n  and (kube_horizontalpodautoscaler_status_current_replicas{job=\"kube-state-metrics\"} < kube_horizontalpodautoscaler_spec_max_replicas{job=\"kube-state-metrics\"})\n  and (changes(kube_horizontalpodautoscaler_status_current_replicas{job=\"kube-state-metrics\"}[15m]) == 0)\n)\n",<br/>    "for": "PT15M",<br/>    "labels": {<br/>      "alert_name": "KubeHpaReplicasMismatch"<br/>    },<br/>    "severity": 4<br/>  },<br/>  {<br/>    "alert": "KubeHpaMaxedOut",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT15M"<br/>    },<br/>    "annotations": {<br/>      "description": "Horizontal Pod Autoscaler in {{ $labels.cluster}} has been running at max replicas for longer than 15 minutes. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."<br/>    },<br/>    "enabled": true,<br/>    "expression": "kube_horizontalpodautoscaler_status_current_replicas{job=\"kube-state-metrics\"} == kube_horizontalpodautoscaler_spec_max_replicas{job=\"kube-state-metrics\"}\n",<br/>    "for": "PT15M",<br/>    "labels": {<br/>      "alert_name": "KubeHpaMaxedOut"<br/>    },<br/>    "severity": 4<br/>  },<br/>  {<br/>    "alert": "KubePodCrashLooping",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT10M"<br/>    },<br/>    "annotations": {<br/>      "description": "{{ $labels.namespace }}/{{ $labels.pod }} ({{ $labels.container }}) in {{ $labels.cluster}} is restarting {{ printf \"%.2f\" $value }} / second. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."<br/>    },<br/>    "enabled": true,<br/>    "expression": "max_over_time(kube_pod_container_status_waiting_reason{reason=\"CrashLoopBackOff\", job=\"kube-state-metrics\"}[5m]) >= 1\n",<br/>    "for": "PT15M",<br/>    "labels": {<br/>      "alert_name": "KubePodCrashLooping"<br/>    },<br/>    "severity": 4<br/>  },<br/>  {<br/>    "alert": "KubePodContainerRestart",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT10M"<br/>    },<br/>    "annotations": {<br/>      "description": "Pod container restarted in last 1 hour. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."<br/>    },<br/>    "enabled": true,<br/>    "expression": "sum by (namespace, controller, container, cluster)\n(increase(kube_pod_container_status_restarts_total{job=\"kube-state-metrics\"}[1h])\n* on(namespace, pod, cluster) group_left(controller)\nlabel_replace(kube_pod_owner, \"controller\", \"$1\", \"owner_name\", \"(.*)\")) > 0\n",<br/>    "for": "PT15M",<br/>    "labels": {<br/>      "alert_name": "KubePodContainerRestart"<br/>    },<br/>    "severity": 4<br/>  },<br/>  {<br/>    "alert": "KubePodReadyStateLow",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT15M"<br/>    },<br/>    "annotations": {<br/>      "description": "Ready state of pods is less than 80%. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."<br/>    },<br/>    "enabled": true,<br/>    "expression": "sum by (cluster,namespace,deployment)\n(kube_deployment_status_replicas_ready) / sum by\n(cluster,namespace,deployment)(kube_deployment_spec_replicas) < .8 or sum\nby (cluster,namespace,deployment)(kube_daemonset_status_number_ready) /\nsum by (cluster,namespace,deployment)(kube_daemonset_status_desired_number_scheduled) < .8\n",<br/>    "for": "PT5M",<br/>    "labels": {<br/>      "alert_name": "KubePodReadyStateLow"<br/>    },<br/>    "severity": 4<br/>  },<br/>  {<br/>    "alert": "KubePodFailedState",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT15M"<br/>    },<br/>    "annotations": {<br/>      "description": "Number of pods in failed state are greater than 0. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."<br/>    },<br/>    "enabled": true,<br/>    "expression": "    sum by (cluster, namespace, controller)\n    (kube_pod_status_phase{phase=\"failed\"} * on(namespace, pod, cluster)\n    group_left(controller) label_replace(kube_pod_owner, \"controller\", \"$1\", \"owner_name\", \"(.*)\")) > 0\n",<br/>    "for": "PT5M",<br/>    "labels": {<br/>      "alert_name": "KubePodFailedState"<br/>    },<br/>    "severity": 4<br/>  },<br/>  {<br/>    "alert": "KubePodNotReadyByController",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT10M"<br/>    },<br/>    "annotations": {<br/>      "description": "{{ $labels.namespace }}/{{ $labels.pod }} in {{ $labels.cluster }} by controller is not ready. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."<br/>    },<br/>    "enabled": true,<br/>    "expression": "    sum by (namespace, controller, cluster) (max by(namespace, pod, cluster)\n    (kube_pod_status_phase{job=\"kube-state-metrics\", phase=~\"Pending|Unknown\"})\n    * on(namespace, pod, cluster) group_left(controller)\n    label_replace(kube_pod_owner, \"controller\", \"$1\", \"owner_name\", \"(.*)\")) > 0\n",<br/>    "for": "PT15M",<br/>    "labels": {<br/>      "alert_name": "KubePodNotReadyByController"<br/>    },<br/>    "severity": 3<br/>  },<br/>  {<br/>    "alert": "KubeStatefulSetGenerationMismatch",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT10M"<br/>    },<br/>    "annotations": {<br/>      "description": "StatefulSet generation for {{ $labels.namespace }}/{{ $labels.statefulset }} does not match, this indicates that the StatefulSet has failed but has not been rolled back. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."<br/>    },<br/>    "enabled": true,<br/>    "expression": "    kube_statefulset_status_observed_generation{job=\"kube-state-metrics\"} !=\n    kube_statefulset_metadata_generation{job=\"kube-state-metrics\"}\n",<br/>    "for": "PT15M",<br/>    "labels": {<br/>      "alert_name": "KubeStatefulSetGenerationMismatch"<br/>    },<br/>    "severity": 3<br/>  },<br/>  {<br/>    "alert": "KubeJobFailed",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT10M"<br/>    },<br/>    "annotations": {<br/>      "description": "Job {{ $labels.namespace }}/{{ $labels.job_name }} in {{ $labels.cluster}} failed to complete. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."<br/>    },<br/>    "enabled": true,<br/>    "expression": "    kube_job_failed{job=\"kube-state-metrics\"} > 0\n",<br/>    "for": "PT15M",<br/>    "labels": {<br/>      "alert_name": "KubeJobFailed"<br/>    },<br/>    "severity": 3<br/>  },<br/>  {<br/>    "alert": "KubeContainerAverageCPUHigh",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT15M"<br/>    },<br/>    "annotations": {<br/>      "description": "Average CPU usage per container is greater than 95%. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."<br/>    },<br/>    "enabled": true,<br/>    "expression": "sum (rate(container_cpu_usage_seconds_total{image!=\"\", container!=\"POD\"}[5m])) by (pod,cluster,container,namespace)\n/ sum(container_spec_cpu_quota{image!=\"\", container!=\"POD\"}/container_spec_cpu_period{image!=\"\", container!=\"POD\"})\nby (pod,cluster,container,namespace) > .95\n",<br/>    "for": "PT5M",<br/>    "labels": {<br/>      "alert_name": "KubeContainerAverageCPUHigh"<br/>    },<br/>    "severity": 4<br/>  },<br/>  {<br/>    "alert": "KubeContainerAverageMemoryHigh",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT10M"<br/>    },<br/>    "annotations": {<br/>      "description": "Average Memory usage per container is greater than 95%. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."<br/>    },<br/>    "enabled": true,<br/>    "expression": "avg by (namespace, controller, container, cluster)(((container_memory_working_set_bytes{container!=\"\", image!=\"\", container!=\"POD\"}\n/ on(namespace,cluster,pod,container) group_left kube_pod_container_resource_limits{resource=\"memory\", node!=\"\"})\n*on(namespace, pod, cluster) group_left(controller) label_replace(kube_pod_owner, \"controller\", \"$1\", \"owner_name\", \"(.*)\")) > .95)\n",<br/>    "for": "PT10M",<br/>    "labels": {<br/>      "alert_name": "KubeContainerAverageMemoryHigh"<br/>    },<br/>    "severity": 4<br/>  },<br/>  {<br/>    "alert": "KubeletPodStartUpLatencyHigh",<br/>    "alert_resolution": {<br/>      "auto_resolved": true,<br/>      "time_to_resolve": "PT10M"<br/>    },<br/>    "annotations": {<br/>      "description": "Kubelet Pod startup latency is too high. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."<br/>    },<br/>    "enabled": true,<br/>    "expression": "    histogram_quantile(0.99,\n    sum(rate(kubelet_pod_worker_duration_seconds_bucket{job=\"kubelet\"}[5m]))\n    by (cluster, instance, le)) * on(cluster, instance) group_left(node)\n    kubelet_node_name{job=\"kubelet\"} > 60\n",<br/>    "for": "PT10M",<br/>    "labels": {<br/>      "alert_name": "KubeletPodStartUpLatencyHigh"<br/>    },<br/>    "severity": 4<br/>  }<br/>]</pre> | no |
| <a name="input_resource_group_location"></a> [resource\_group\_location](#input\_resource\_group\_location) | The location of the resource group. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group. | `string` | n/a | yes |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | The retention period in days for the Log Analytics Workspace. | `number` | `30` | no |
| <a name="input_service_cidr"></a> [service\_cidr](#input\_service\_cidr) | The service CIDR for the Kubernetes Cluster. | `string` | `"172.20.0.0/16"` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | The SKU tier for the Kubernetes Cluster. | `string` | `"Standard"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources. | `map(string)` | `{}` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | The tenant ID for the Azure subscription. | `string` | n/a | yes |
| <a name="input_workload_identity_enabled"></a> [workload\_identity\_enabled](#input\_workload\_identity\_enabled) | Specifies whether workload identity is enabled for the Kubernetes Cluster. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_csi_user_assigned_identity_name"></a> [csi\_user\_assigned\_identity\_name](#output\_csi\_user\_assigned\_identity\_name) | The name of the user-assigned identity for the CSI driver. |
| <a name="output_kubernetes_cluster_id"></a> [kubernetes\_cluster\_id](#output\_kubernetes\_cluster\_id) | The ID of the Kubernetes cluster. |
| <a name="output_kubernetes_node_rg_name"></a> [kubernetes\_node\_rg\_name](#output\_kubernetes\_node\_rg\_name) | The name of the node resource group. This name is important as the CSI driver identity is created there. |
| <a name="output_kublet_identity_client_id"></a> [kublet\_identity\_client\_id](#output\_kublet\_identity\_client\_id) | The client ID of the identity used by the kubelet. |
| <a name="output_kublet_identity_object_id"></a> [kublet\_identity\_object\_id](#output\_kublet\_identity\_object\_id) | The object ID of the identity used by the kubelet. |
<!-- END_TF_DOCS -->

## Upgrading

### ~> `3.0.0`
Sandro describe variable change
