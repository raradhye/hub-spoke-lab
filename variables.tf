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
variable "admin_username" {
  description = "VM admin username"
  type        = string
  default     = "adminuser"
}
variable "environment_name" {
  description = "environment name (dev or prod)"
  type        = string
}
variable "spoke_vnet_address" {
  description = "Spoke VNet address space"
  type        = string
}
variable "spoke_vnet_subnet" {
  description = "Spoke app subnet address space"
  type        = string
}
variable "alert_email" {
  description = "Email address for alert notification"
  type        = string
}
variable "key_vault_admin_object_id" {
  description = "Object ID of admin user for Key Vault Administrator role"
  type        = string
}
variable "github_actions_object_id" {
  description = "Object ID of GitHub Actions Service Principal"
  type        = string
}
