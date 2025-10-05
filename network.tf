locals {
  subnet_names = [
    "${var.resource_prefix}-pe-snet",
    "${var.resource_prefix}-public-snet",
    "${var.resource_prefix}-private-snet",
  ]
  subnet_ids = {
    "${var.resource_prefix}-pe-snet"     = azurerm_subnet.private_endpoints.id,
    "${var.resource_prefix}-public-snet" = azurerm_subnet.public.id,
    "${var.resource_prefix}-private-snet" = azurerm_subnet.private.id,
  }
}


resource "azurerm_virtual_network" "this" {
  name                = "${var.resource_prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.this[local.network_resource_group_name].name
}


resource "azurerm_subnet" "public" {
  name                              = local.subnet_names[1]
  resource_group_name               = azurerm_resource_group.this[local.network_resource_group_name].name
  virtual_network_name              = azurerm_virtual_network.this.name
  address_prefixes                  = ["10.0.1.0/24"]
  private_endpoint_network_policies = "Enabled"
  delegation {
    name = "databricks_delegation"
    service_delegation {
      name    = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",

      ]
    }
  }
}

resource "azurerm_subnet" "private" {
  name                              = local.subnet_names[2]
  resource_group_name               = azurerm_resource_group.this[local.network_resource_group_name].name
  virtual_network_name              = azurerm_virtual_network.this.name
  address_prefixes                  = ["10.0.2.0/24"]
  private_endpoint_network_policies = "Enabled"
  delegation {
    name = "databricks_delegation"
    service_delegation {
      name    = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
    }
  }
}

resource "azurerm_subnet" "private_endpoints" {
  name                              = local.subnet_names[0]
  resource_group_name               = azurerm_resource_group.this[local.network_resource_group_name].name
  virtual_network_name              = azurerm_virtual_network.this.name
  private_endpoint_network_policies = "Enabled"
  address_prefixes                  = ["10.0.3.0/24"]
}

resource "azurerm_network_security_group" "this" {
  for_each            = toset(local.subnet_names)
  name                = "${each.key}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.this[local.network_resource_group_name].name
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each                  = local.subnet_ids
  subnet_id                 = each.value
  network_security_group_id = azurerm_network_security_group.this[each.key].id

  depends_on = [
    azurerm_network_security_group.this
  ]
}