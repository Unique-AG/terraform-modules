# PostgreSQL Default Alerts Example

This example demonstrates the default alerting behavior of the Azure PostgreSQL module and shows various ways to customize or disable the default alerts.

## Default Alerts Enabled

By default, the module creates two essential alerts for every PostgreSQL server:

### 1. CPU Alert (Warning Level)
- **Threshold**: CPU usage > 80%
- **Duration**: 30 minutes
- **Frequency**: Check every 5 minutes
- **Window**: Evaluate over 30-minute window
- **Severity**: 2 (Warning)

### 2. Memory Alert (Error Level)
- **Threshold**: Memory usage > 90%
- **Duration**: 1 hour
- **Frequency**: Check every 15 minutes
- **Window**: Evaluate over 1-hour window
- **Severity**: 1 (Error)

## Usage Patterns

### Pattern 1: Accept All Defaults
```hcl
module "postgresql" {
  source              = "path/to/module"
  # ... basic configuration ...
  
  # Default alerts automatically enabled:
  # - CPU > 80% for 30min
  # - Memory > 90% for 1h
  # No notifications configured (portal-only alerts)
}
```

### Pattern 2: Disable All Alerts
```hcl
module "postgresql" {
  source              = "path/to/module"
  # ... basic configuration ...
  
  metric_alerts = {}  # Completely disable alerting
}
```

### Pattern 3: Keep Defaults + Add Notifications
```hcl
module "postgresql" {
  source              = "path/to/module"
  # ... basic configuration ...
  
  metric_alerts = {
    # Explicitly define defaults with action groups
    default_cpu_alert = {
      name        = "PostgreSQL High CPU Usage"
      description = "Alert when CPU usage is above 80% for more than 30 minutes"
      severity    = 2
      frequency   = "PT5M"
      window_size = "PT30M"
      criteria = {
        metric_name = "cpu_percent"
        aggregation = "Average"
        operator    = "GreaterThan"
        threshold   = 80
      }
      action_group_ids = [azurerm_monitor_action_group.alerts.id]
    }
    # ... repeat for memory alert ...
  }
}
```

### Pattern 4: Custom Thresholds
```hcl
module "postgresql" {
  source              = "path/to/module"
  # ... basic configuration ...
  
  metric_alerts = {
    # More aggressive CPU monitoring for development
    custom_cpu_alert = {
      name      = "Dev Environment CPU Alert"
      severity  = 3
      criteria = {
        metric_name = "cpu_percent"
        threshold   = 70  # Lower threshold
      }
    }
    # Keep default memory alert...
    # Add custom connection monitoring...
  }
}
```

## Examples in This Directory

1. **`postgresql_with_defaults`** - Shows minimal configuration with automatic default alerts
2. **`postgresql_no_alerts`** - Demonstrates how to disable all alerting
3. **`postgresql_defaults_with_notifications`** - Adds email notifications to default alerts
4. **`postgresql_custom_thresholds`** - Customizes thresholds and adds additional metrics

## Benefits of Default Alerts

### ✅ **Immediate Protection**
- Zero-configuration monitoring for critical metrics
- Production-ready thresholds based on best practices
- Covers the most common PostgreSQL performance issues

### ✅ **Flexibility**
- Easy to disable if not needed
- Simple to customize thresholds
- Can add notifications without losing defaults

### ✅ **Best Practices**
- **30-minute CPU window**: Avoids false positives from short spikes
- **1-hour memory window**: Detects sustained memory pressure
- **Appropriate severities**: Warning for CPU, Error for memory
- **Optimal frequencies**: Balance between responsiveness and noise

## Common Customizations

### Development Environments
- Lower CPU threshold (70% instead of 80%)
- Shorter evaluation windows (15min instead of 30min)
- Informational severity instead of Warning/Error

### Production Environments
- Add email/SMS notifications via action groups
- Add additional metrics (connections, storage, IO)
- Consider dynamic criteria for anomaly detection

### Cost-Sensitive Environments
- Longer evaluation windows to reduce alert frequency
- Disable alerts entirely for non-critical databases
- Use fewer action group notifications

## Migration from Manual Configuration

If you previously configured alerts manually:

### Before (Manual)
```hcl
module "postgresql" {
  source = "path/to/module"
  metric_alerts = {
    cpu_alert = {
      name = "CPU Alert"
      criteria = { threshold = 80 }
    }
    memory_alert = {
      name = "Memory Alert" 
      criteria = { threshold = 90 }
    }
  }
}
```

### After (Leveraging Defaults)
```hcl
module "postgresql" {
  source = "path/to/module"
  # Defaults automatically provide the same functionality!
  # Only override if you need different thresholds or notifications
}
```

## Deployment

```bash
terraform init
terraform plan
terraform apply
```

This will create four PostgreSQL servers demonstrating different alerting approaches:
- One with default alerts (no notifications)
- One with no alerts at all
- One with default alerts + email notifications
- One with custom thresholds and additional metrics

The default alerts provide immediate value while maintaining full flexibility for customization as your monitoring requirements evolve.