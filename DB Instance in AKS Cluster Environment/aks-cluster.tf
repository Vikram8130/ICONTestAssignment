resource "azurerm_virtual_network" "vpc" {
  name          = "vpc-${terraform.workspace}"
  address_space = ["${lookup(var.address_space, terraform.workspace)}"]
  location            = "${var.location}"
  resource_group_name = "${var.res_group_name}"
  tags {
    environment = "${terraform.workspace}"
  }
}
# VPC name and CIDR is dependent on workspace

resource "azurerm_subnet" "subnet" {
  name                      = "akc-${terraform.workspace}-subnet"
  resource_group_name       = "${var.res_group_name}"
  network_security_group_id = "${var.net_sec_group_id}"
  virtual_network_name      = "${var.vnet_name}"
  address_prefix            = "${var.subnet_prefixes[terraform.workspace]}"
}

# subnet name and CIDR dependant on workspace used

resource azurerm_network_security_group "net_sec_group" {
  name                = "akc-${terraform.workspace}-nsg"
  location            = "${var.location}"
  resource_group_name = "${var.res_group_name}"
  tags {
    environment = "${terraform.workspace}"
  }
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "k8s-${terraform.workspace}"
  location            = "${var.location}"
  resource_group_name = "${var.res_group_name}"
  dns_prefix          = "k8s-${terraform.workspace}"
  windows_profile {
  admin_username = var.windows_admin_username
  admin_password = var.windows_admin_password
}
  agent_pool_profile {
    name            = "agentpool"
    count           = "${var.agent_count[terraform.workspace]}"
    node_count      = "2"
    vm_size         = "Standard_DS2_v4"
    os_type         = "Windows"
    os_disk_size_gb = 30
    vnet_subnet_id  = "${var.subnet_id}"
  }
  #For high availability , we can put these nodes with db instances in different availabilty azones or datacentres. 
  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }
  /* Service principals are separate identities that can be associated with an account. 
  Service principals are useful for working with applications and tasks that can be automated.

export AZ_SUBSCRIPTION_ID=$(az account show --query id --out tsv)
az ad sp create-for-rbac --name terraform --role="Contributor" --scopes="/subscriptions/$AZ_SUBSCRIPTION_ID"
*/

  network_profile {
    network_plugin = "azure"
  }
  
  addon_profile {
    http_application_routing {
      enabled = true
    }
  }
  tags {
    Environment = "${terraform.workspace}"
  }
}