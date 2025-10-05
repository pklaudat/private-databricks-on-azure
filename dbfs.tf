
# --------------------------------------------------------------- #
#   IAM Assignments for Databricks to access Storage Account      #
# --------------------------------------------------------------- #
resource "azurerm_role_assignment" "this" {
  principal_id         = azurerm_databricks_access_connector.this.identity[0].principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_resource_group.this[local.databricks_workspace_resource_group_name].id
}


# TODO: IMPLEMENT CUSTOMER MANAGED KEY