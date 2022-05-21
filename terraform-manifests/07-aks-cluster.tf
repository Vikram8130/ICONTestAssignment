resource "azurerm_kubernetes_cluster" "aks_cluster" {
  dns_prefix          = "${azurerm_resource_group.aks_rg.name}"
  location            = azurerm_resource_group.aks_rg.location
  name                = "${azurerm_resource_group.aks_rg.name}-cluster"
  resource_group_name = azurerm_resource_group.aks_rg.name
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  node_resource_group = "${azurerm_resource_group.aks_rg.name}-nrg"


  default_node_pool {
    name       = "systempool"
    vm_size    = "Standard_DS2_v2"
    orchestrator_version = data.azurerm_kubernetes_service_versions.current.latest_version
    availability_zones   = [1, 2, 3]
    enable_auto_scaling  = true
    max_count            = 3
    min_count            = 1
    os_disk_size_gb      = 30
    type           = "VirtualMachineScaleSets"
    node_labels = {
      "nodepool-type" = "system"
      "environment"   = var.environment
      "nodepoolos"    = "windows"
      "app"           = "system-apps"
    }
    tags = {
      "nodepool-type" = "system"
      "environment"   = var.environment
      "nodepoolos"    = "windows"
      "app"           = "system-apps"
    }    
  }

# Identity (System Assigned or Service Principal)
  identity { type = "SystemAssigned" }

# Add On Profiles
  addon_profile {
    azure_policy { enabled = true }
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.insights.id
    }
  }

# RBAC and Azure AD Integration Block
role_based_access_control {
  enabled = true
  azure_active_directory {
    managed                = true
    admin_group_object_ids = [azuread_group.aks_administrators.id]
  }
}  

# Windows Admin Profile
windows_profile {
  admin_username = var.windows_admin_username
  admin_password = var.windows_admin_password
}

# Linux Profile
linux_profile {
  admin_username = "ubuntu"
  ssh_key {
      key_data = file(var.ssh_public_key)
  }
}

# Network Profile
network_profile {
  load_balancer_sku = "Standard"
  network_plugin = "azure"
}

# AKS Cluster Tags 
tags = {
  Environment = var.environment
}


}

/*Below configuration can also be used foe above functionality

terraform {
  backend "azurerm" {
    resource_group_name  = "tamopsterraform-rg"
    storage_account_name = "tamopsterraform"
    container_name       = "tfstate"
    key                  = "aks-terraform.tfstate"
  }
}

provider "azurerm" {
  version = "~> 2.0"
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = "${var.name}-rg"
  location = var.location
}
 
resource "azurerm_virtual_network" "virtual_network" {
  name =  "${var.name}-vnet"
  location = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  address_space = [var.network_address_space]
}
 
resource "azurerm_subnet" "aks_subnet" {
  name = var.aks_subnet_address_name
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes = [var.aks_subnet_address_prefix]
}
 
resource "azurerm_subnet" "app_gwsubnet" {
  name = var.subnet_address_name
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes = [var.subnet_address_prefix]
}

data "azurerm_resource_group" "resource_group" {
  name = "${var.name}-rg"
}
 
data "azurerm_subnet" "akssubnet" {
  name                 = "aks"
  virtual_network_name = "${var.name}-vnet"
  resource_group_name  = data.azurerm_resource_group.resource_group.name
}
 
data "azurerm_subnet" "appgwsubnet" {
  name                 = "appgw"
  virtual_network_name = "${var.name}-vnet"
  resource_group_name  = data.azurerm_resource_group.resource_group.name
}
 
data "azurerm_log_analytics_workspace" "workspace" {
  name                = "${var.name}-la"
  resource_group_name = data.azurerm_resource_group.resource_group.name
}
 
resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${var.name}aks"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  dns_prefix          = "${var.name}dns"
  kubernetes_version  = var.kubernetes_version
 
  node_resource_group = "${var.name}-node-rg"
 
  linux_profile {
    admin_username = "ubuntu"
 
    ssh_key {
      key_data = var.ssh_public_key
    }
  }

windows_profile {
    admin_username = var.windows_admin_username
    admin_password = var.windows_admin_password
}
 
  default_node_pool {
    name                 = "agentpool"
    node_count           = var.agent_count
    vm_size              = var.vm_size
    vnet_subnet_id       = data.azurerm_subnet.akssubnet.id
    type                 = "VirtualMachineScaleSets"
    orchestrator_version = var.kubernetes_version
  }
 
  identity {
    type = "SystemAssigned"
  }
 
  addon_profile {
    oms_agent {
      enabled                    = var.addons.oms_agent
      log_analytics_workspace_id = data.azurerm_log_analytics_workspace.workspace.id
    }
 
    ingress_application_gateway {
      enabled   = var.addons.ingress_application_gateway
      subnet_id = data.azurerm_subnet.appgwsubnet.id
    }
 
  }
 
  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "azure"
  }
 
  role_based_access_control {
    enabled = var.kubernetes_cluster_rbac_enabled
 
    azure_active_directory {
      managed                = true
      admin_group_object_ids = [var.aks_admins_group_object_id]
    }
  }
 
}
 
data "azurerm_resource_group" "node_resource_group" {
  name = azurerm_kubernetes_cluster.k8s.node_resource_group
  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
}
 
resource "azurerm_role_assignment" "node_infrastructure_update_scale_set" {
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
  scope                = data.azurerm_resource_group.node_resource_group.id
  role_definition_name = "Virtual Machine Contributor"
  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
}

default_node_pool {
  name                 = "agentpool"
  node_count           = var.agent_count
  vm_size              = var.vm_size
  vnet_subnet_id       = data.azurerm_subnet.akssubnet.id
  type                 = "VirtualMachineScaleSets"
  orchestrator_version = var.kubernetes_version
  }

identity {
  type = "SystemAssigned"
  }

addon_profile {
  oms_agent {
      enabled                    = var.addons.oms_agent
      log_analytics_workspace_id = data.azurerm_log_analytics_workspace.workspace.id
    }

    ingress_application_gateway {
      enabled   = var.addons.ingress_application_gateway
      subnet_id = data.azurerm_subnet.appgwsubnet.id
    }

  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "azure"
  }

  role_based_access_control {
    enabled = var.kubernetes_cluster_rbac_enabled

    azure_active_directory {
      managed                = true
      admin_group_object_ids = [var.aks_admins_group_object_id]
    }
  }

}

data "azurerm_resource_group" "node_resource_group" {
  name = azurerm_kubernetes_cluster.k8s.node_resource_group
  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
}

resource "azurerm_role_assignment" "node_infrastructure_update_scale_set" {
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
  scope                = data.azurerm_resource_group.node_resource_group.id
  role_definition_name = "Virtual Machine Contributor"
  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
}
 
resource "azurerm_log_analytics_workspace" "Log_Analytics_WorkSpace" {
    # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
    name                = "${var.name}-la"
    location            = var.location
    resource_group_name = data.azurerm_resource_group.resource_group.name
    sku                 = "PerGB2018"
}
 
resource "azurerm_log_analytics_solution" "Log_Analytics_Solution_ContainerInsights" {
    solution_name         = "ContainerInsights"
    location              = azurerm_log_analytics_workspace.Log_Analytics_WorkSpace.location
    resource_group_name   = data.azurerm_resource_group.resource_group.name
    workspace_resource_id = azurerm_log_analytics_workspace.Log_Analytics_WorkSpace.id
    workspace_name        = azurerm_log_analytics_workspace.Log_Analytics_WorkSpace.name
 
    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}

>>> variables.tf

variable "name" {
  type        = string
  default     = "tamops"
  description = "Name for resources"
}
 
variable "location" {
  type        = string
  default     = "uksouth"
  description = "Azure Location of resources"
}
 
variable "network_address_space" {
  type        = string
  description = "Azure VNET Address Space"
}
 
variable "aks_subnet_address_name" {
  type        = string
  description = "AKS Subnet Address Name"
}
 
variable "aks_subnet_address_prefix" {
  type        = string
  description = "AKS Subnet Address Space"
}
 
variable "subnet_address_name" {
  type        = string
  description = "Subnet Address Name"
}
 
variable "subnet_address_prefix" {
  type        = string
  description = "Subnet Address Space"
}

>>> terraform.tfvars
name     = "devopsthehardway"
location = "uksouth"
network_address_space = "192.168.0.0/16"
aks_subnet_address_name = "aks"
aks_subnet_address_prefix = "192.168.0.0/24"
subnet_address_name = "appgw"
subnet_address_prefix = "192.168.1.0/24"

*/

/* 
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_role_assignment" "role_acrpull" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
  skip_service_principal_aad_check = true
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false
}

resource "azurerm_application_gateway" "network" {
  name                = "ansuman-appgw"
  resource_group_name = azurerm_resource_group.noderg.name
  location            = azurerm_resource_group.noderg.location
}
  
addon_profile {
  ingress_application_gateway {
    enabled    = true
    gateway_id = azurerm_application_gateway.network.id
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.cluster_name
  node_resource_group = azurerm_application_gateway.network.resource_group_name ##uses the appgw rg as Node rsource group

  default_node_pool {
    name                = "system"
    node_count          = var.system_node_count
    vm_size             = "Standard_DS2_v2"
    type                = "VirtualMachineScaleSets"
    availability_zones  = [1, 2, 3]
    enable_auto_scaling = false
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin    = "kubenet" # CNI
  }
}
*/
