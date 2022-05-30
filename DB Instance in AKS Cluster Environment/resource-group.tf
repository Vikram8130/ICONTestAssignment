provider "azurerm"{
version = " > 2.0"
subscription_id = " "
tenant_id       = " "
features {}
}

#Terraform State Storage Account
  backend "azurerm" {}
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = "South Europe"
}
resource "azurerm_storage_account" "website_log_storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

resource "azurerm_storage_container" "website_logs_container" {
  name                  = "${var.website_name}-cont"
  storage_account_name  = azurerm_storage_account.website_log_storage.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "website_logs_blob" {
 name                   = "website-logs.zip"
 storage_account_name   = azurerm_storage_account.website_log_storage.name
 storage_container_name = azurerm_storage_container.website_logs_container.name
 type                   = "Block"
}

resource "azurerm_storage_account_customer_managed_key" "website_log_key" {
  depends_on = [azurerm_key_vault_access_policy.website_logs_storage_accesspolicy,
    azurerm_key_vault_key.website_logs_key
  ]
  storage_account_id = azurerm_storage_account.website_log_storage.id
  key_vault_id       = azurerm_key_vault.nscsecrets.id
  key_name           = azurerm_key_vault_key.website_logs_key.name

identity {
    type = "Service Principal"
  }
}

tags = {
    environment = "${terraform.workspace}"
  }

}

resource "local_file" "kubeconfig" {
  depends_on   = [azurerm_kubernetes_cluster.k8s]
  filename     = "kubeconfig"
  content      = azurerm_kubernetes_cluster.k8s.kube_config_raw
}