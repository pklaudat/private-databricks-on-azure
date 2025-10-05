# private-databricks-on-azure
Terraform module which deploys a private Azure Databricks workspace with VNet injection and secure cluster connectivity.
The module creates the following resources:
- Resource group for the virtual network
- Virtual network with required subnets and service endpoints
- Private DNS zone for Azure Databricks
- Azure Databricks workspace with VNet injection and secure cluster connectivity
- Azure Databricks access connector for secure cluster connectivity
- Network security groups for the subnets

## Usage
```hcl
module "databricks" {
  source = "github.com/pklaudat/private-databricks-on-azure"

  resource_prefix = "myproject"
  location        = "East US"
}
```
## Variables
- `resource_prefix`: Prefix for resource names (e.g., "myproject")
- `location`: Azure region for resource deployment (e.g., "East US")

## Requirements
- Terraform 1.0 or later
- AzureRM provider 4.0 or later

## Providers
- azurerm

## Authors
- [Paulo Klaudat](https://github.com/pklaudat)