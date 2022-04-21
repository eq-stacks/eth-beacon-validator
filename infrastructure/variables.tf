variable "billing_account" {
  description = "GCP Billing Account"
  type        = string
}

variable "cluster_name" {
  description = "Cluster Name"
  type        = string
}

variable "cluster_subnet" {
  description = "Cluster's subnet name (located in host VPC)"
  type        = string
}

variable "credentials_file" {
  description = "GCP Credentials File"
  type        = string
}

variable "location" {
  description = "GCP Zone location for kubernetes cluster"
  type        = string
}

variable "org_id" {
  description = "Google Organization ID"
  type        = string
}

variable "project_eth_validator" {
  description = "GCP Project name for Eth Validator project"
  type        = string
}

variable "project_host" {
  description = "GCP Project for Host VPC"
  type        = string
}

variable "project_host_vpc" {
  description = "VPC name of the project host VPC"
  type        = string
}

variable "project_owners" {
  description = "GCP Project owners principals"
  type        = list(string)
}

variable "region" {
  description = "GCP Region for tenant docks"
  type        = string
}

variable "service_account_project" {
  description = "GCP Project for Service Account"
  type        = string
}

variable "worker_node_type" {
  description = "Kubernetes cluster's worker node instance type"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes Version"
  default     = "1.23"
}

variable "workers_count" {
  description = "Number of workers to deploy"
  default     = "3"
}
