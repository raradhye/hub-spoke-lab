output "hub_vnet_id" {
  description = "Hub VNet ID"
  value       = azurerm_virtual_network.hub.id
}
output "spoke_vnet_id" {
  description = "Spoke VNet Id"
  value       = azurerm_virtual_network.spoke_vnet.id
}
output "hub_shared_subnet_id" {
  description = "Hub Shared Subnet ID"
  value       = azurerm_subnet.hub_shared.id
}
output "spoke_app_subnet_id" {
  description = "Spoke Shared Subnet ID"
  value       = azurerm_subnet.spoke_app.id
}
