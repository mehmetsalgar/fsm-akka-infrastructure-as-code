variable "resource_group_name" {
  default = "fsm-akka"
  description = "Resource Group Name"
}

variable "resource_group_name_prefix" {
  default = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name stays unique"
}

variable "resource_group_location" {
  default = "germanywestcentral"
  description = "Location of our AKS Cluster"
}

variable "log_analytics_workspace_location" {
  default = "germanywestcentral"
}

variable "log_analytics_workspace_name" {
  default = "fsmakkaLogAnalyticsWorkspaceName"
}

variable "log_analytics_workspace_sku_name" {
  default = "Free"
}

variable "log_analytics_workspace_sku_tier" {
  default = "Free"
}

variable "cluster_name" {
  default = "fsmakkaAKS-test"
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "aks_service_principal_app_id" {
  default = ""
  sensitive = true
}

variable "aks_service_principal_client_secret" {
  default = ""
  sensitive = true
}

variable "dns_prefix" {
  default = "fsmakkaAKS-test-dns"
}

variable "environment" {
  default = "dev"
}