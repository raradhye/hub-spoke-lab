# Create a resource group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# Hub VNet
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.1.0.0/16"]
}

# Hub Bastion Subnet
resource "azurerm_subnet" "hub_bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.1.1.0/26"]
}

# Hub Shared Subnet
resource "azurerm_subnet" "hub_shared" {
  name                 = "snet-shared"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.1.4.0/24"]
}
# Spoke Dev VNet
resource "azurerm_virtual_network" "spoke_dev" {
  name                = "vnet-spoke-dev"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.2.0.0/16"]
}
# Spoke App Subnet
resource "azurerm_subnet" "spoke_app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.spoke_dev.name
  address_prefixes     = ["10.2.1.0/24"]
}
# peer hub to spoke
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "peer-hub-to-spoke-dev"
  resource_group_name       = azurerm_resource_group.main.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke_dev.id
}
# peer spoke to hub
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "peer-spoke-dev-to-hub"
  resource_group_name       = azurerm_resource_group.main.name
  virtual_network_name      = azurerm_virtual_network.spoke_dev.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
}
# NSG for spoke subnet
resource "azurerm_network_security_group" "spoke_dev" {
  name                = "nsg-spoke-dev"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "Allow-from-hub"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "3389"]
    source_address_prefix      = "10.1.0.0/16"
    destination_address_prefix = "*"
  }
}
# Attach NSG to Spoke subnet
resource "azurerm_subnet_network_security_group_association" "spoke_app" {
  subnet_id                 = azurerm_subnet.spoke_app.id
  network_security_group_id = azurerm_network_security_group.spoke_dev.id
}
