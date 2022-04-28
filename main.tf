terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.9"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
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

data "google_service_account" "terraform" {
  account_id = "terraform"
  project    = var.service_account_project
}

provider "kubernetes" {
  host  = "https://${module.infrastructure.k8s_endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    module.infrastructure.k8s_cluster_ca_certificate
  )
}

provider "kubectl" {
  host  = "https://${module.infrastructure.k8s_endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    module.infrastructure.k8s_cluster_ca_certificate
  )
  load_config_file = false
}

provider "helm" {
  kubernetes {
    host  = "https://${module.infrastructure.k8s_endpoint}"
    token = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(
      module.infrastructure.k8s_cluster_ca_certificate
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

