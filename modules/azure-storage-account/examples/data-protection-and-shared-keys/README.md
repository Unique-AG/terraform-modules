# Data Protection and Shared Access Keys Example

This example demonstrates how to configure Azure Storage Accounts with various data protection settings, shared access key configurations, and public network access scenarios.

## Features Demonstrated

### Shared Access Keys
- **`shared_access_key_enabled = true`**: Most examples enable shared access keys for demonstration purposes
- **Note**: In production, consider using Azure AD authentication instead of shared access keys for enhanced security

### Public Network Access
The example demonstrates both public and private network access configurations across the three examples:

#### Public Network Access Examples
- **`storage_account_with_data_protection`**: Public access enabled with mixed container access types
- **`storage_account_minimal_protection`**: Public access enabled for basic scenarios
- **Use Cases**: Public assets, CDN integration, web applications

#### Private Network Access Examples
- **`storage_account_aggressive_protection`**: Public access disabled for maximum security
- **Use Cases**: Sensitive data, internal applications, compliance requirements

### Data Protection Settings
The example shows three different data protection configurations with network access variations:

#### 1. Comprehensive Data Protection (`storage_account_with_data_protection`)
- **Public Network Access**: Enabled
- **Versioning**: Enabled to track all versions of blobs
- **Change Feed**: Enabled to track all changes to blobs
- **Soft Delete**: 30-day retention for both blobs and containers
- **Point-in-Time Restore**: 7-day restore capability
- **Shared Access Keys**: Enabled for demonstration
- **Container Access Types**: All private (default behavior)

#### 2. Minimal Data Protection (`storage_account_minimal_protection`)
- **Public Network Access**: Enabled for basic scenarios
- **Versioning**: Enabled
- **Change Feed**: Disabled
- **Soft Delete**: 7-day retention for both blobs and containers
- **Point-in-Time Restore**: Disabled
- **Shared Access Keys**: Enabled for demonstration
- **Container Access Types**: All private (default behavior)

#### 3. Aggressive Data Protection (`storage_account_aggressive_protection`)
- **Public Network Access**: Disabled for maximum security
- **Infrastructure Encryption**: Enabled for enhanced security
- **Private Endpoint**: Enabled for secure private network access
- **Versioning**: Enabled
- **Change Feed**: Enabled
- **Soft Delete**: 365-day retention for both blobs and containers
- **Point-in-Time Restore**: 30-day restore capability
- **Shared Access Keys**: Disabled for enhanced security
- **Container Access Types**: All private (enforced by public access setting)
- **Networking**: Virtual Network, Subnet, Private DNS Zone, and Private Endpoint

## Unique Naming

This example uses the `random` provider to ensure unique resource names:
- A random 6-character string is generated and appended to resource names
- This prevents naming conflicts when deploying multiple instances
- The same random string is used across all resources for consistency
- Storage account names are kept under the 24-character Azure limit
- A unique resource group is created for this example deployment

## Data Protection Features Explained

### Versioning
- Tracks all versions of blobs
- Allows recovery of previous versions
- Useful for compliance and audit requirements

### Change Feed
- Tracks all changes to blobs (create, update, delete)
- Enables event-driven applications
- Required for point-in-time restore

### Soft Delete
- **Blob Soft Delete**: Prevents permanent deletion of blobs for specified retention period
- **Container Soft Delete**: Prevents permanent deletion of containers for specified retention period
- Allows recovery of accidentally deleted data

### Point-in-Time Restore
- Enables restoration of storage account to a specific point in time
- Requires versioning, change feed, and blob soft delete to be enabled
- Retention period must be less than blob soft delete retention
- Can be the same value as change feed retention (if less than blob soft delete retention)

## Network Access Features Explained

### Public Network Access
- **Enabled**: Allows internet access to storage account endpoints
- **Container Access Types**: Can be configured as blob, container, or private
- **Security**: Requires careful consideration of access controls and data sensitivity

### Private Network Access
- **Disabled**: Restricts access to private networks only
- **Enhanced Security**: All containers are effectively private
- **Use Cases**: Sensitive data, compliance requirements, internal applications

## Security Considerations

### Authentication
- **Azure AD Authentication**: This example uses Azure AD authentication for storage operations
- **No Key-based Auth**: Azure AD authentication avoids the need for shared access keys during deployment
- **Azure CLI**: Ensure you're logged in with `az login` before running the example
- **Subscription**: Uses a specific subscription ID for controlled deployment

### Shared Access Keys
- **Enabled for demonstration** in this example
- In production, consider using Azure AD authentication instead
- If enabled, ensure proper key rotation and access controls
- The module has `allow_nested_items_to_be_public = false` for enhanced security

### Infrastructure Encryption
- **Enabled**: Provides additional encryption layer at the infrastructure level
- **Use Cases**: Enhanced security for critical data
- **Compliance**: Meets strict regulatory requirements

### Public Network Access
- **Public Access**: Use only for non-sensitive data that needs internet access
- **Container Access Types**: Choose appropriate access levels (blob vs container vs private)
- **Network Rules**: Consider implementing IP restrictions for public access
- **Monitoring**: Enable logging and monitoring for public access scenarios

### Data Protection Validation
The module includes validation rules to ensure:
- Retention periods are within valid ranges
- Point-in-time restore requirements are met
- Logical relationships between settings are maintained
- Change feed and point-in-time restore can be the same value (if less than blob soft delete retention)

## Usage

This example uses Azure AD authentication for storage operations to avoid key-based authentication issues.

### Prerequisites

1. **Azure CLI**: Make sure you're logged in with `az login`
2. **Azure AD Authentication**: The provider is configured with `storage_use_azuread = true`
3. **Permissions**: Ensure your account has the necessary permissions to create storage accounts
4. **Subscription**: The example uses a specific subscription ID for deployment

### Deployment

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

## Outputs

Each storage account will have:
- Storage account ID
- Primary and secondary connection strings (shared access keys enabled)
- Container names and access types
- Data protection settings applied
- Public network access status

## Cleanup

```bash
# Destroy the resources
terraform destroy
```

## Notes

- This example creates its own resource group with a unique name
- Storage account names are made unique using random strings
- Public access examples include private containers (default behavior)
- Private access examples enforce private containers regardless of access type setting
- Consider using different resource groups and locations for production use
- Data protection settings cannot be modified after storage account creation
- Point-in-time restore requires specific prerequisites to be enabled
- Public network access should be carefully considered based on data sensitivity
- Infrastructure encryption provides additional security layer for critical data

## Networking Resources

This example includes networking resources for private endpoint testing:

### Virtual Network
- **Name**: `vnet-storage-{random}`
- **Address Space**: `10.0.0.0/16`
- **Purpose**: Host private endpoints for secure storage access

### Subnet
- **Name**: `subnet-private-endpoint`
- **Address Space**: `10.0.1.0/24`
- **Private Endpoint Policies**: Enabled
- **Purpose**: Dedicated subnet for private endpoints

### Private DNS Zone
- **Name**: `privatelink.blob.core.windows.net`
- **Purpose**: DNS resolution for private blob storage endpoints
- **Linked to**: Virtual Network for automatic DNS resolution

### Private Endpoint
- **Service**: Blob storage
- **Subnet**: Dedicated private endpoint subnet
- **DNS**: Integrated with private DNS zone
- **Security**: Maximum isolation from public internet