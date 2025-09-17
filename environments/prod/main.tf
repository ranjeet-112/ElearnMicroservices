locals {
  common_tags = {
    "ManagedBy"   = "Terraform"
    "Owner"       = "ElearnTeam"
    "Environment" = "prod"
  }
}

module "rg" {
  source      = "../../modules/azurerm_resource_group"
  rg_name     = "rg-prod-Elearn"
  rg_location = "centralindia"
  rg_tags     = local.common_tags
}



module "acr" {
  depends_on = [module.rg]
  source     = "../../modules/azurerm_container_registry"
  acr_name   = "acrprodtodoapp"
  rg_name    = "rg-prod-Elearn"
  location   = "centralindia"
  tags       = local.common_tags
}

module "sql_server" {
  depends_on      = [module.rg]
  source          = "../../modules/azurerm_sql_server"
  sql_server_name = "sql-prod-todoapp"
  rg_name         = "rg-prod-Elearn"
  location        = "centralindia"
  admin_username  = "prodopsadmin"
  admin_password  = "P@ssw01rd@123"
  tags            = local.common_tags
}

module "sql_db" {
  depends_on  = [module.sql_server]
  source      = "../../modules/azurerm_sql_database"
  sql_db_name = "sqldb-prod-todoapp"
  server_id   = module.sql_server.server_id
  max_size_gb = "2"
  tags        = local.common_tags
}

module "aks" {
  depends_on = [module.rg]
  source     = "../../modules/azurerm_kubernetes_cluster"
  aks_name   = "aks-prod-todoapp"
  location   = "centralindia"
  rg_name    = "rg-prod-Elearn"
  dns_prefix = "aks-prod-todoapp"
  node_count = "1"
  vm_size    = "Standard_D2_v2"
  tags       = local.common_tags
}


module "pip" {
  source   = "../../modules/azurerm_public_ip"
  pip_name = "pip-prod-todoapp"
  rg_name  = "rg-prod-Elearn"
  location = "centralindia"
  sku      = "Basic"
  tags     = local.common_tags
}
