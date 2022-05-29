# After providing azure credentials we will create resource group where our K8s cluster will reside.

resource "azurerm_resource_group" "res_group" {
  name     = "aks-${terraform.workspace}"
  location = "${var.location}"
  tags {
    environment = "${terraform.workspace}"
  }
}

# depending on the workspace we are in, resource name will be different for stage or prod

# terraform workspace new stage

# terraform workspace list

