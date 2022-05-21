# Terraform Resource to Create Azure Resource Group with Input Variables defined in variables.tf

/* We are going to create resource groups for each environment with terraform-aks-envname
Example Name:
terraform-aks-stage
terraform-aks-prod
*/
resource "azurerm_resource_group" "aks_rg" {
  name = "${var.resource_group_name}-${var.environment}"
  location = var.location
}


