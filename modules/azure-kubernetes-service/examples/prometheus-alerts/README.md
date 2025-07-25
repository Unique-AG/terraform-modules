# AKS with Prometheus Alerts Example

This example demonstrates how to configure Azure Kubernetes Service (AKS) with Prometheus monitoring and custom alert rules.

## Features

- **Prometheus Monitoring**: Enables Azure Monitor managed Prometheus for AKS
- **Custom Alert Rules**: Demonstrates how to configure node, cluster, and pod-level alert rules
- **Email Notifications**: Configures action groups to send alerts via email
- **Grafana Integration**: Sets up Grafana for visualization

## Prerequisites

- Azure CLI installed and authenticated
- Terraform installed (version >= 1.0)
- Azure subscription with appropriate permissions

## Configuration

### Alert Configuration

The example uses variables for alert configuration, which can be loaded from `prometheus-alerts.tfvars`:

```hcl
# In prometheus-alerts.tfvars
alert_configuration = {
  email_receiver = {
    email_address = "admin@example.com"
    name          = "aks-admin-alerts"
  }
  action_group = {
    short_name = "aks-alerts"
    location   = "germanywestcentral"
  }
}

# Node level alert rules
prometheus_node_alert_rules = [
  # ... alert rules ...
]

# Cluster level alert rules  
prometheus_cluster_alert_rules = [
  # ... alert rules ...
]

# Pod level alert rules
prometheus_pod_alert_rules = [
  # ... alert rules ...
]
```

This approach allows for:
- **Easy reuse**: Copy the tfvars file to other projects
- **Simple modification**: Edit alert rules without touching the main configuration
- **Environment-specific**: Create different tfvars files for different environments
- **Version control**: Track alert rule changes separately from infrastructure code
- **Flexible configuration**: Use variables for alert configuration instead of hardcoded values

### Prometheus Alert Rules

The example provides custom alert rules for different levels:

#### Node Level Alerts
- **KubeNodeUnreachable**: Detects when nodes become unreachable
- **KubeNodeReadinessFlapping**: Detects when node readiness is unstable

#### Cluster Level Alerts
- **KubeCPUQuotaOvercommit**: Detects CPU overcommitment
- **KubeMemoryQuotaOvercommit**: Detects memory overcommitment
- **KubeContainerOOMKilledCount**: Detects containers killed due to OOM
- **KubeClientErrors**: Detects Kubernetes API client errors

#### Pod Level Alerts
- **KubePVUsageHigh**: Detects high persistent volume usage
- **KubePodCrashLooping**: Detects pods in crash loop state

## Usage

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Review the plan** (with alert rules):
   ```bash
   terraform plan -var-file="prometheus-alerts.tfvars"
   ```

3. **Apply the configuration** (with alert rules):
   ```bash
   terraform apply -var-file="prometheus-alerts.tfvars"
   ```

4. **Apply without alerts** (basic AKS only):
   ```bash
   terraform apply
   ```

5. **Access Grafana**:
   - Navigate to the Azure Portal
   - Go to the created Azure Monitor workspace
   - Access Grafana from the workspace

## Customization

### Adding More Alert Rules

You can add more alert rules by editing the `prometheus-alerts.tfvars` file:

```hcl
# In prometheus-alerts.tfvars
prometheus_node_alert_rules = [
  # ... existing rules ...
  {
    alert      = "CustomNodeAlert"
    enabled    = true
    expression = "your_promql_expression_here"
    for        = "PT5M"
    severity   = 3
    alert_resolution = {
      auto_resolved   = true
      time_to_resolve = "PT10M"
    }
    annotations = {
      description = "Your custom alert description"
    }
    labels = {
      team = "your-team"
    }
  }
]
```

### Modifying Alert Configuration

You can customize the alert configuration by editing the `prometheus-alerts.tfvars` file:

```hcl
# In prometheus-alerts.tfvars
alert_configuration = {
  email_receiver = {
    email_address = "your-email@domain.com"
    name          = "your-alert-name"
  }
  action_group = {
    short_name = "your-short-name"
    location   = "your-preferred-location"
  }
}
```

### Creating Environment-Specific Configurations

You can create multiple tfvars files for different environments:

```bash
# Development environment
cp prometheus-alerts.tfvars prometheus-alerts-dev.tfvars
# Edit prometheus-alerts-dev.tfvars with dev-specific values
terraform apply -var-file="prometheus-alerts-dev.tfvars"

# Production environment  
cp prometheus-alerts.tfvars prometheus-alerts-prod.tfvars
# Edit prometheus-alerts-prod.tfvars with prod-specific values
terraform apply -var-file="prometheus-alerts-prod.tfvars"

# Staging environment
cp prometheus-alerts.tfvars prometheus-alerts-staging.tfvars
# Edit prometheus-alerts-staging.tfvars with staging-specific values
terraform apply -var-file="prometheus-alerts-staging.tfvars"
```

### Using Alert Configuration via Command Line

You can also provide alert configuration directly via command line:

```bash
# With email alerts
terraform apply \
  -var='alert_configuration={"email_receiver":{"email_address":"admin@example.com","name":"aks-alerts"},"action_group":{"short_name":"aks-alerts","location":"germanywestcentral"}}'

# Custom email address
terraform apply \
  -var='alert_configuration={"email_receiver":{"email_address":"your-email@domain.com"}}'
```

## File Structure

```
prometheus-alerts/
├── main.tf                           # Main Terraform configuration
├── providers.tf                      # Provider configuration
├── prometheus-alerts.tfvars          # Alert rules and configuration
├── prometheus-alerts.tfvars.example  # Example tfvars file
├── subscription.auto.tfvars          # Subscription-specific variables
└── README.md                         # This documentation
```

## Variables

The example declares the following variables:

- `alert_configuration`: Configuration for AKS alerts and monitoring
- `prometheus_node_alert_rules`: Node level Prometheus alert rules
- `prometheus_cluster_alert_rules`: Cluster level Prometheus alert rules
- `prometheus_pod_alert_rules`: Pod level Prometheus alert rules
- `subscription_id`: Azure subscription ID

## Cleanup

To destroy the resources:

```bash
terraform destroy -var-file="prometheus-alerts.tfvars"
```

## Notes

- The action group location is set to `germanywestcentral` as some regions may not support action groups
- Alert rules are only created when `azure_prometheus_grafana_monitor.enabled` is `true`
- Email notifications are only sent when `alert_configuration.email_receiver` is provided
- All alert rules include auto-resolution settings for better alert management
- The monitor resource group is automatically created in the same location as the AKS cluster
- Variables are properly declared in `main.tf` to avoid Terraform warnings 