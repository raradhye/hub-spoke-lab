# Read password directly from key vault
data "azurerm_key_vault_secret" "admin_password" {
  name         = "vm-admin-password"
  key_vault_id = var.key_vault_id
}

# Network interface for Hub VM
resource "azurerm_network_interface" "hub_vm" {
  name                = "nic-vm-hub-test"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.hub_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Hub VM
resource "azurerm_linux_virtual_machine" "hub_vm" {
  name                            = "vm-hub-test"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = "Standard_B1s"
  admin_username                  = var.admin_username
  admin_password                  = data.azurerm_key_vault_secret.admin_password.value
  disable_password_authentication = false
  vtpm_enabled                    = true
  secure_boot_enabled             = true

  identity {
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
  name                = "nic-vm-spoke-${var.environment_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.spoke_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}
# Spoke VM
resource "azurerm_linux_virtual_machine" "spoke_vm" {
  name                            = "vm-spoke-${var.environment_name}"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = "Standard_B1s"
  admin_username                  = var.admin_username
  admin_password                  = data.azurerm_key_vault_secret.admin_password.value
  disable_password_authentication = false
  vtpm_enabled                    = true
  secure_boot_enabled             = true

  identity {
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

# Azure Monitor Agent - Hub VM

resource "azurerm_virtual_machine_extension" "hub_vm_ama" {
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.hub_vm.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}

# Azure Monotor Agent - Spoke VM

resource "azurerm_virtual_machine_extension" "spoke_vm_ama" {
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.spoke_vm.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}
