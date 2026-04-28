data "azurerm_client_config" "current" {}

# Key Vault with RBAC authorization enabled
resource "azurerm_key_vault" "main" {
  name                       = "kv-hub-spoke-lab"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  sku_name                   = "standard"
  enable_rbac_authorization  = true
}

# Key Vault Administrator your personal account
resource "azurerm_role_assignment" "kv_admin" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.key_vault_admin_object_id
}

# Key Vault Secrets user - Github Action Service Principal
resource "azurerm_role_assignment" "kv_pipeline" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.github_actions_object_id
}
