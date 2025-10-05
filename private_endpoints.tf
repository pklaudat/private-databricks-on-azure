


resource "azurerm_private_endpoint" "this" {
  for_each            = toset(["databricks_ui_api"])
  name                = "${var.resource_prefix}-${each.value}-pe"
  location            = var.location
  resource_group_name = azurerm_resource_group.this[local.network_resource_group_name].name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "${var.resource_prefix}-psc"
    private_connection_resource_id = azurerm_databricks_workspace.this.id
    is_manual_connection           = false
    subresource_names              = ["databricks_ui_api"]
  }

  private_dns_zone_group {
    name                 = "${var.resource_prefix}-pdzg"
    private_dns_zone_ids = [azurerm_private_dns_zone.this.id]
  }

  depends_on = [azurerm_databricks_workspace.this]

}

resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = azurerm_resource_group.this[local.network_resource_group_name].name
}