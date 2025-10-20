# Archive Tier Lifecycle Example

This example demonstrates the Archive tier support in Azure Storage Account lifecycle management policies.

## What This Example Shows

This example creates three storage accounts to illustrate the Archive tier behavior:

1. **LRS Storage Account with Archive Tier** - Demonstrates a storage account using LRS replication with Archive tier enabled in the lifecycle policy
2. **GRS Storage Account with Archive Tier** - Demonstrates a storage account using GRS replication with Archive tier enabled
3. **ZRS Storage Account without Archive Tier** - Demonstrates a storage account using ZRS replication where Archive tier must be null (not supported)

## Archive Tier Support

The Archive access tier is **only supported** for the following replication types:
- **LRS** (Locally Redundant Storage)
- **GRS** (Geo-Redundant Storage)
- **RA-GRS** (Read-Access Geo-Redundant Storage)

The Archive tier is **NOT supported** for:
- **ZRS** (Zone-Redundant Storage)
- **GZRS** (Geo-Zone-Redundant Storage)
- **RA-GZRS** (Read-Access Geo-Zone-Redundant Storage)

## How the Module Handles This

The module automatically skips the `tier_to_archive_after_days_since_modification_greater_than` setting when using unsupported replication types. This means:

- If you use LRS, GRS, or RA-GRS and specify `blob_to_archive_after_last_modified_days`, the Archive tier will be applied
- If you use ZRS, GZRS, or RA-GZRS, the Archive tier setting will be automatically set to `null`, preventing Azure API errors

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Lifecycle Policies Demonstrated

### Aggressive Policy (LRS example)
- Cool tier: After 30 days
- Cold tier: After 90 days
- Archive tier: After 180 days
- Delete: After 365 days

### Very Aggressive Policy (GRS example)
- Cool tier: After 7 days
- Cold tier: After 30 days
- Archive tier: After 90 days
- Delete: After 180 days

### ZRS Policy (without Archive)
- Cool tier: After 30 days
- Cold tier: After 90 days
- Archive tier: Not supported (set to null)
- Delete: After 365 days

## Clean Up

```bash
terraform destroy
```





