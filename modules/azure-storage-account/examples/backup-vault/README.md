# Backup Vault Example

This example demonstrates how to create multiple Azure Storage Accounts with Azure Data Protection Backup Vaults enabled in the same resource group. It showcases that the module automatically generates unique backup vault names by appending a random suffix, preventing naming conflicts.

## What This Example Demonstrates

1. **Multiple Storage Accounts with Backup Vaults**: Creates three storage accounts, each with its own backup vault
2. **Unique Naming**: All three backup vaults use the same base name (`storage-backup-vault`), but the module automatically appends a unique random suffix to each
3. **Different Redundancy Options**: 
   - Storage Account 1: ZoneRedundant backup vault
   - Storage Account 2: LocallyRedundant backup vault
   - Storage Account 3: GeoRedundant backup vault with cross-region restore enabled
4. **Custom Backup Policies**: Each storage account uses different backup policy retention settings
5. **Container-Specific Backups**: The third storage account demonstrates backing up specific containers

## Key Features

### Automatic Unique Naming
Each module instance creates a backup vault with a unique name:
- `storage-backup-vault-a3f9d2` (example)
- `storage-backup-vault-k7m2p1` (example)
- `storage-backup-vault-x8n4z5` (example)

This prevents the `409 Conflict` error that would occur if multiple backup vaults tried to use the same name.

### Backup Vault Redundancy Options

The example shows three redundancy options:

1. **ZoneRedundant** (Default): Data is replicated across availability zones
2. **LocallyRedundant**: Data is replicated within a single datacenter
3. **GeoRedundant**: Data is replicated to a secondary region, with optional cross-region restore

### Backup Policy Retention

Different retention policies are demonstrated:
- **2 weeks** operational retention (Storage Account 1)
- **4 weeks** operational retention (Storage Account 2)
- **8 weeks** operational retention (Storage Account 3)

## Prerequisites

- Azure subscription
- Appropriate permissions to create:
  - Resource Groups
  - Storage Accounts
  - Data Protection Backup Vaults
  - Backup Policies and Instances
  - Role Assignments (Storage Account Backup Contributor)

## Usage

1. Initialize Terraform:
```bash
terraform init
```

2. Review the plan:
```bash
terraform plan
```

3. Apply the configuration:
```bash
terraform apply
```

4. View the outputs to see the unique backup vault names:
```bash
terraform output unique_backup_vault_names
```

## Expected Outputs

After applying, you should see outputs showing:
- Three storage account IDs
- Three unique backup vault names (each with a different random suffix)
- Three backup vault IDs
- The resource group name

## Cleanup

To destroy all resources created by this example:

```bash
terraform destroy
```

## Important Notes

- **Role Assignments**: The module automatically creates role assignments to grant the backup vault's managed identity the "Storage Account Backup Contributor" role on each storage account
- **Backup Vault Deletion**: When destroying resources, backup vaults may have a soft-delete period. If you encounter errors during cleanup, you may need to wait for the soft-delete period to expire or manually purge the vaults
- **Cross-Region Restore**: Only available with GeoRedundant backup vaults
- **Cost Considerations**: Backup vaults and backup policies incur costs based on the amount of data backed up and retention duration

## Testing the Fix

This example specifically tests that the fix for the `409 Conflict` error works correctly when using the module multiple times. Before the fix, attempting to create multiple storage accounts with backup vaults in the same resource group would fail with:

```
Error: creating DataProtection BackupVault: unexpected status 409 (409 Conflict)
...message":"Request specified that resource '...storage-backup-vault' is new, but resource already exists."
```

After the fix, each backup vault gets a unique name automatically, and all three storage accounts can be created successfully in the same apply operation.

