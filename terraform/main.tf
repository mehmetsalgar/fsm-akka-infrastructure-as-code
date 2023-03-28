# If you are creating new Resource Group
#resource "azurerm_resource_group" "rg" {
#  location                = var.resource_group_location
#  name                    = var.resource_group_name
#}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Comment out if you are working with Free Tier Azure, analytics are now available at 'Free Tier'
resource "random_id" "log_analytics_workspace_name_suffix" {
  byte_length             = 8
}

# Comment out if you are working with Free Tier Azure, analytics are now available at 'Free Tier'
resource "azurerm_log_analytics_workspace" "fsmakka-workspace" {
  location                = var.log_analytics_workspace_location
  name                    = "${var.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
  resource_group_name     = data.azurerm_resource_group.rg.name
  sku                     = var.log_analytics_workspace_sku_name
}


# Comment out if you are working with Free Tier Azure, analytics are now available at 'Free Tier'
resource "azurerm_log_analytics_solution" "fsmakka-workspace" {
  location                = azurerm_log_analytics_workspace.fsmakka-workspace.location
  resource_group_name     = data.azurerm_resource_group.rg.name
  solution_name           = "ContainerInsights"
  workspace_name          = azurerm_log_analytics_workspace.fsmakka-workspace.name
  workspace_resource_id   = azurerm_log_analytics_workspace.fsmakka-workspace.id

  plan {
    product               = "OMSGallery/ContainerInsights"
    publisher             = "Microsoft"
  }
}

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = data.azurerm_resource_group.rg.location
  name                = var.cluster_name
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix
  sku_tier = "Free"
  tags                = {
    Environment = var.environment
  }
  default_node_pool {
    name    = "agentpool"
    vm_size = "Standard_D2lds_v5"
    node_count = 2
  }

  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = data.azurerm_key_vault_secret.library-key-vault-secret.value
    }
  }
  network_profile {
    network_plugin = "kubenet"
    load_balancer_sku = "basic"
  }
  service_principal {
    client_id     = var.aks_service_principal_app_id
    client_secret = var.aks_service_principal_client_secret
  }
}

data "azurerm_key_vault" "library-key-vault" {
  name                = "library-key-vault"
  resource_group_name = "library-resource-group"
}

data "azurerm_key_vault_secret" "library-key-vault-secret" {
  name         = "library-rest-aks-secret"
  key_vault_id = data.azurerm_key_vault.library-key-vault.id
}