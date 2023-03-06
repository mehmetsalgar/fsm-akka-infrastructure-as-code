resource "random_pet" "rg_name" {
  prefix                  = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location                = var.resource_group_location
  name                    = random_pet.rg_name.id
}

resource "random_id" "log_analytics_workspace_name_suffix" {
  byte_length             = 8
}

resource "azurerm_log_analytics_workspace" "fsmakka-workspace" {
  location                = var.log_analytics_workspace_location
  name                    = "${var.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
  resource_group_name     = azurerm_resource_group.rg.name
  sku                     = var.log_analytics_workspace_sku_name
}

resource "azurerm_log_analytics_solution" "fsmakka-workspace" {
  location                = azurerm_log_analytics_workspace.fsmakka-workspace.location
  resource_group_name     = azurerm_resource_group.rg.name
  solution_name           = "ContainerInsights"
  workspace_name          = azurerm_log_analytics_workspace.fsmakka-workspace.name
  workspace_resource_id   = azurerm_log_analytics_workspace.fsmakka-workspace.id

  plan {
    product               = "OMSGallery/ContainerInsights"
    publisher             = "Microsoft"
  }
}

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = azurerm_resource_group.rg.location
  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix
  tags                = {
    Environment = "Test"
  }
  default_node_pool {
    name    = "agentpool"
    vm_size = "Standard_D2lds_v5"
    node_count = 2
  }

  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = file(var.ssh_public_key)
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