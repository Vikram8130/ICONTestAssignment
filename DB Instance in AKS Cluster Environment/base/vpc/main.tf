resource "azurerm_virtual_network" "vpc" {
  name          = "vpc-${terraform.workspace}"
  address_space = ["${lookup(var.address_space, terraform.workspace)}"]
  location            = "${var.location}"
  resource_group_name = "${var.res_group_name}"
  tags {
    environment = "${terraform.workspace}"
  }
}

## NOTE: VPC name and CIDR is dependent on workspace

