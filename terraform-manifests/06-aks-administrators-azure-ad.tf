# Create Azure AD Group in Active Directory for AKS Admins
# We are going to create Azure AD Group per environment for AKS Admins
/*To create this group we need to ensure Azure AD Directory Write permission is there for our 
Service Principal (Service Connection) created in Azure DevOps*/

resource "azuread_group" "aks_administrators" {
  #name        = "${azurerm_resource_group.aks_rg.name}-${var.environment}-administrators"
  display_name        = "${azurerm_resource_group.aks_rg.name}-${var.environment}-administrators"
  description = "Azure AKS Kubernetes administrators for the ${azurerm_resource_group.aks_rg.name}-${var.environment} cluster."
  security_enabled = true
}
