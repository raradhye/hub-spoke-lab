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
# Network interface for Hub VM
resource "azurerm_network_interface" "hub_vm" {
  name                = "nic-vm-hub-test"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hub_shared.id
    private_ip_address_allocation = "Dynamic"
  }
}
# Hub VM
resource "azurerm_linux_virtual_machine" "hub_vm" {
  name                            = "vm-hub-test"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_B1s"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  vtpm_enabled                    = true
  secure_boot_enabled             = true

  identity { # <- add it here
    type = "SystemAssigned"
  }
  network_interface_ids = [
    azurerm_network_interface.hub_vm.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
  boot_diagnostics {}
}
# Network interface for Spoke VM
resource "azurerm_network_interface" "spoke_vm" {
  name                = "nic-vm-spoke-test"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.spoke_app.id
    private_ip_address_allocation = "Dynamic"
  }
}
# Hub VM
resource "azurerm_linux_virtual_machine" "spoke_vm" {
  name                            = "vm-spoke-test"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_B1s"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  vtpm_enabled                    = true
  secure_boot_enabled             = true

  identity { # <- add it here
    type = "SystemAssigned"
  }
  network_interface_ids = [
    azurerm_network_interface.spoke_vm.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
  boot_diagnostics {}
}
