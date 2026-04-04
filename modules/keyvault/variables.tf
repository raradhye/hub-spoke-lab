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
