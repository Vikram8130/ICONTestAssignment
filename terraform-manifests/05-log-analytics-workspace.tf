# Create Log Analytics Workspace
/* 
Log Analytics workspace will be created per environment.
Example:
stage-logs-some-random-petname
prod-logs-some-random-petname
*/
resource "azurerm_log_analytics_workspace" "insights" {
  name                = "${var.environment}-logs-${random_pet.aksrandom.id}"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  retention_in_days   = 30
}