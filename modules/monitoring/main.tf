# Create Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-hub-spoke-${var.environment_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
# Create Data Collection Rule
resource "azurerm_monitor_data_collection_rule" "main" {
  name                = "dcr-hub-spoke-${var.environment_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = "Linux"

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.main.id
      name                  = "law-destination"
    }
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics", "Microsoft-Syslog"]
    destinations = ["law-destination"]
  }

  data_sources {
    syslog {
      facility_names = ["daemon", "kern", "syslog", "user"]
      log_levels     = ["Error", "Critical", "Alert", "Emergency"]
      name           = "syslog-source"
      streams        = ["Microsoft-Syslog"]
    }

    performance_counter {
      streams                       = ["Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "Processor(*)\\% Idle Time",
        "Processor(*)\\% User Time",
        "Memory(*)\\Available MBytes Memory",
        "Memory(*)\\% Available Memory",
        "Logical Disk(*)\\% Free Space",
        "Logical Disk(*)\\Disk Read Bytes/sec",
        "Logical Disk(*)\\Disk Write Bytes/sec",
        "Network(*)\\Total Bytes Transmitted",
      "Network(*)\\Total Bytes Received"]
      name = "perf-counters"
    }
  }
}

# associate hub VM to a Data Collection Rule
resource "azurerm_monitor_data_collection_rule_association" "hub_vm" {
  name                    = "dcr-association-hub-vm"
  target_resource_id      = var.hub_vm_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.main.id
}

# associate spoke VM to a Data Collection Rule
resource "azurerm_monitor_data_collection_rule_association" "spoke_vm" {
  name                    = "dcr-association-spoke-vm"
  target_resource_id      = var.spoke_vm_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.main.id
}

# Create Action group - who gets notified
resource "azurerm_monitor_action_group" "main" {
  name                = "ag-hub-spoke-${var.environment_name}"
  resource_group_name = var.resource_group_name
  short_name          = "hubspoke"

  email_receiver {
    name          = "admin-email"
    email_address = var.alert_email
  }
}

# Alert rule - High CPU
resource "azurerm_monitor_metric_alert" "high_cpu" {
  name                     = "alert-high-cpu-${var.environment_name}"
  resource_group_name      = var.resource_group_name
  scopes                   = [var.hub_vm_id, var.spoke_vm_id]
  description              = "Action when CPU exceeds 80%"
  severity                 = 2
  frequency                = "PT5M"
  window_size              = "PT15M"
  target_resource_type     = "Microsoft.Compute/virtualMachines"
  target_resource_location = var.location

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

# Alert rule - Low Memory
resource "azurerm_monitor_metric_alert" "low_memory" {
  name                     = "alert-low-memory-${var.environment_name}"
  resource_group_name      = var.resource_group_name
  scopes                   = [var.hub_vm_id, var.spoke_vm_id]
  description              = "Action when available memory drops below 500mb"
  severity                 = 2
  frequency                = "PT5M"
  window_size              = "PT15M"
  target_resource_type     = "Microsoft.Compute/virtualMachines"
  target_resource_location = var.location

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 524288000
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

# Alert Rule — VM Heartbeat (VM down)
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "heartbeat" {
  name                 = "alert-heartbeat-${var.environment_name}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  description          = "Alert when VM stops sending heartbeat"
  severity             = 0
  enabled              = true
  scopes               = [azurerm_log_analytics_workspace.main.id]
  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"

  criteria {
    query                   = <<-QUERY
      Heartbeat
      | summarize LastHeartbeat = max(TimeGenerated) by Computer
      | where LastHeartbeat < ago(5m)
    QUERY
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"
  }

  action {
    action_groups = [azurerm_monitor_action_group.main.id]
  }
}
resource "random_uuid" "workbook" {}

resource "azurerm_application_insights_workbook" "vm_health" {
  name                = random_uuid.workbook.result
  resource_group_name = var.resource_group_name
  location            = var.location
  display_name        = "VM Health Dashboard — ${var.environment_name}"
  data_json           = file("${path.root}/dashboards/workbook-vm-health.json")
}
