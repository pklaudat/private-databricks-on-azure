locals {
  network_resource_group_name              = "rg-${var.resource_prefix}-network"
  databricks_workspace_name                = "ws-${var.resource_prefix}"
  databricks_managed_resource_group_name   = "rg-${var.resource_prefix}-managed"
  databricks_workspace_resource_group_name = "rg-${var.resource_prefix}-workspace"
}


# --------------------------------------------------------------- #
#                       Resource Groups                           #
# --------------------------------------------------------------- #

resource "azurerm_resource_group" "this" {
  for_each = toset([local.network_resource_group_name, local.databricks_workspace_resource_group_name])
  name     = each.value
  location = var.location
}

# --------------------------------------------------------------- #
#   Databricks Workspace with Private Link enabled                 #
# --------------------------------------------------------------- #

resource "azurerm_databricks_workspace" "this" {
  name                              = local.databricks_workspace_name
  resource_group_name               = azurerm_resource_group.this[local.databricks_workspace_resource_group_name].name
  location                          = var.location
  sku                               = "premium"
  managed_resource_group_name       = local.databricks_managed_resource_group_name
  access_connector_id               = azurerm_databricks_access_connector.this.id
  default_storage_firewall_enabled  = true
  public_network_access_enabled     = true
  infrastructure_encryption_enabled = true
  custom_parameters {
    no_public_ip        = true
    private_subnet_name = azurerm_subnet.private.name
    public_subnet_name  = azurerm_subnet.public.name
    virtual_network_id = azurerm_virtual_network.this.id
    public_subnet_network_security_group_association_id = azurerm_network_security_group.this[azurerm_subnet.public.name].id
    private_subnet_network_security_group_association_id = azurerm_network_security_group.this[azurerm_subnet.private.name].id
  }

  depends_on = [azurerm_virtual_network.this, azurerm_subnet_network_security_group_association.this]
}

# --------------------------------------------------------------- #
#   Databricks Access Connector for Private Link                    #
# --------------------------------------------------------------- #

resource "azurerm_databricks_access_connector" "this" {
  name                = "${var.resource_prefix}-access-connector"
  resource_group_name = azurerm_resource_group.this[local.databricks_workspace_resource_group_name].name
  location            = var.location
  identity {
    type = "SystemAssigned"
  }
}
