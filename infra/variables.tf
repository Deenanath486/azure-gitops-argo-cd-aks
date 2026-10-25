variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-gitops-aks-prod"
}

variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Environment identifier (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "aks-gitops-enterprise-01"
}

variable "kubernetes_version" {
  description = "Kubernetes release version"
  type        = string
  default     = "1.29"
}

variable "vnet_address_space" {
  description = "Virtual Network CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aks_subnet_prefix" {
  description = "Subnet CIDR block for AKS node pools"
  type        = string
  default     = "10.0.1.0/24"
}

variable "appgw_subnet_prefix" {
  description = "Subnet CIDR block for Azure Application Gateway"
  type        = string
  default     = "10.0.2.0/24"
}

variable "system_node_count" {
  description = "Number of system nodes"
  type        = number
  default     = 2
}

variable "system_node_size" {
  description = "VM SKU for system nodes"
  type        = string
  default     = "Standard_D2s_v5"
}

variable "workload_node_size" {
  description = "VM SKU for user workload nodes"
  type        = string
  default     = "Standard_D4s_v5"
}

variable "tags" {
  description = "Resource tagging map"
  type        = map(string)
  default = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Project     = "GitOps-ArgoCD"
    Owner       = "Deenanath Yadav"
  }
}
