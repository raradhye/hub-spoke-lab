# Get current configuration such as tenant_id, subscription_id & object_id
data "azurerm_client_config" "current" {}

# Create a resource group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# Networking Module
module "networking" {
  source              = "./modules/networking"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment_name    = var.environment_name
  spoke_vnet_address  = var.spoke_vnet_address
  spoke_vnet_subnet   = var.spoke_vnet_subnet
}

# Key Vault Module
module "keyvault" {
  source                    = "./modules/keyvault"
  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  key_vault_admin_object_id = var.key_vault_admin_object_id
  github_actions_object_id  = var.github_actions_object_id
}

# Monitoring Module
module "monitoring" {
  source              = "./modules/monitoring"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  environment_name    = var.environment_name
  hub_vm_id           = module.vm.hub_vm_id
  spoke_vm_id         = module.vm.spoke_vm_id
  alert_email         = var.alert_email
}

# VM Module
module "vm" {
  source              = "./modules/vm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment_name    = var.environment_name
  admin_username      = var.admin_username
  hub_subnet_id       = module.networking.hub_shared_subnet_id
  spoke_subnet_id     = module.networking.spoke_app_subnet_id
  key_vault_id        = module.keyvault.key_vault_id
}
