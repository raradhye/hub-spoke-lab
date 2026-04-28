variable "location" {
  description = "Azure region for all the resources"
  type        = string
  default     = "westus"
}
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-hub-spoke-lab"
}
variable "key_vault_admin_object_id" {
  description = "Object ID of admin user for Key Vault Administrator role"
  type        = string
}
variable "github_actions_object_id" {
  description = "Object ID of GitHub Actions Service Principal for Key Vault Secrets User role"
  type        = string
}
