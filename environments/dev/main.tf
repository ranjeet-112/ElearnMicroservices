locals {
  common_tags = {
    "ManagedBy"   = "Terraform"
    "Owner"       = "ElearnTeam"
    "Environment" = "dev"
  }
}

module "rg" {
  source      = "../../modules/azurerm_resource_group"
  rg_name     = "rg-dev-Elearn"
  rg_location = "centralindia"
  rg_tags     = local.common_tags
}

module "acr" {
  depends_on = [module.rg]
  source     = "../../modules/azurerm_container_registry"
  acr_name   = "ElearnAcrDev01"
  rg_name    = "rg-dev-Elearn"
  location   = "centralindia"
  tags       = local.common_tags
}

module "sql_server" {
  depends_on      = [module.rg]
  source          = "../../modules/azurerm_sql_server"
  sql_server_name = "sql-dev-Elearn-01"
  rg_name         = "rg-dev-Elearn"
  location        = "centralindia"
  admin_username  = "devopsadmin"
  admin_password  = "P@ssw01rd@123"
  tags            = local.common_tags
}

module "sql_db" {
  depends_on  = [module.sql_server]
  source      = "../../modules/azurerm_sql_database"
  sql_db_name = "sqldb-dev-Elearn"
  server_id   = module.sql_server.server_id
  max_size_gb = "2"
  tags        = local.common_tags
}

module "aks" {
  depends_on = [module.rg]
  source     = "../../modules/azurerm_kubernetes_cluster"
  aks_name   = "aks-dev-Elearn"
  location   = "centralindia"
  rg_name    = "rg-dev-Elearn"
  dns_prefix = "aks-dev-Elearn"
  tags       = local.common_tags
}


module "pip" {
  source   = "../../modules/azurerm_public_ip"
  pip_name = "pip-dev-Elearn"
  rg_name  = "rg-dev-Elearn"
  location = "centralindia"
  sku      = "Basic"
  tags     = local.common_tags
}
