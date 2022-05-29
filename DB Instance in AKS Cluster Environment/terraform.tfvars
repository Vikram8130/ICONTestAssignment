# terraform.tfvars will be used to provision azure infrastructure

subscription_id = "$AZ_SUBSCRIPTION_ID"
client_id       = "$AZ_CLIENT_NAME_ID"
client_secret   = "$AZ_CLIENT_SECRET"
tenant_id       = "$AZ_TENANT_ID"
pgsql_password   = "$YOUR_DB_PASSWORD"

# Note: Here we can get the credentials from Azure Key Vault which is the best practice.