output "workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.main.workspace_id
}

output "resource_id" {
  description = "Log Analytics Resource ID"
  value       = azurerm_log_analytics_workspace.main.id
}
