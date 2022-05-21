# depending of the workspace we are in resource name will be different for stage or prod
resource "azurerm_resource_group" "res_group" {
  name     = "aks-${terraform.workspace}"
  location = "${var.location}"
  tags {
    environment = "${terraform.workspace}"
  }
}