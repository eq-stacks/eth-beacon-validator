terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.9"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 4.15"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.service_account_project
}

# Configure kubernetes provider with Oauth2 access token.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config
# This fetches a new token, which will expire in 1 hour.
data "google_client_config" "default" {
  depends_on = [module.infrastructure]
}

# Defer reading the cluster data until the GKE cluster exists.
data "google_container_cluster" "default" {
  name       = var.cluster_name
  depends_on = [module.infrastructure]
}

data "google_service_account" "terraform" {
  account_id = "terraform"
  project    = var.service_account_project
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.default.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.default.master_auth[0].cluster_ca_certificate,
  )
}

provider "helm" {
  kubernetes {
    host  = "https://${data.google_container_cluster.default.endpoint}"
    token = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(
      data.google_container_cluster.default.master_auth[0].cluster_ca_certificate,
    )
  }
}

module "infrastructure" {
  source = "./infrastructure"

  billing_account         = var.billing_account
  cluster_name            = var.cluster_name
  cluster_subnet          = var.cluster_subnet
  credentials_file        = var.credentials_file
  location                = var.location
  org_id                  = var.org_id
  project_eth_validator   = var.project_eth_validator
  project_host            = var.project_host
  project_host_vpc        = var.project_host_vpc
  project_owners          = var.project_owners
  region                  = var.region
  service_account_project = var.service_account_project
  worker_node_type        = var.worker_node_type
}

module "kubernetes" {
  depends_on   = [module.infrastructure]
  source       = "./kubernetes"
  cluster_name = var.cluster_name
}

module "workload" {
  depends_on = [
    module.infrastructure,
    module.kubernetes,
  ]
  source       = "./workload"
  cluster_name = var.cluster_name
}

