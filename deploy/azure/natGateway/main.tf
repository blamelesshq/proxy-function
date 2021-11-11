data "azurerm_client_config" "current" {}

resource "azurerm_virtual_network" "example" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "example" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = var.subnet_delegation_name

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}


resource "azurerm_public_ip" "example" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  availability_zone   = "No-Zone"#"Zone-Redundant"#contains(var.availability_zones_regions, var.location) ? "Zone-Redundant" : "No-Zone"
}

resource "azurerm_public_ip_prefix" "example" {
  name                = "nat-gateway-publicIPPrefix"
  location            = var.location
  resource_group_name = var.resource_group_name
  prefix_length       = 30
  availability_zone   = "No-Zone"#"Zone-Redundant"#contains(var.availability_zones_regions, var.location) ? "Zone-Redundant" : "No-Zone"
}

resource "azurerm_nat_gateway" "example" {
  name                    = var.natGateway_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  # zones                   = ["1"]
}

resource "azurerm_nat_gateway_public_ip_prefix_association" "example" {
  nat_gateway_id      = azurerm_nat_gateway.example.id
  public_ip_prefix_id = azurerm_public_ip_prefix.example.id
}

resource "azurerm_nat_gateway_public_ip_association" "example" {
  nat_gateway_id       = azurerm_nat_gateway.example.id
  public_ip_address_id = azurerm_public_ip.example.id
}

resource "azurerm_app_service_virtual_network_swift_connection" "example" {
  app_service_id = var.app_service_id
  subnet_id      = azurerm_subnet.example.id
}

resource "azurerm_subnet_nat_gateway_association" "example" {
  subnet_id      = azurerm_subnet.example.id
  nat_gateway_id = azurerm_nat_gateway.example.id
}