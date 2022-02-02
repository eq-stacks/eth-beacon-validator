variable "billing_account" {}
variable "credentials_file" {}
variable "org_id" {}
variable "project_eth_validator" {}
variable "project_host_vpc" {}
variable "project_principals" {}
variable "service_account_project" {}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google-beta"
      version = "4.8.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project = var.service_account_project
}

resource "google_project" "eth2_validator_project" {
  name       = "Eth2 Consensus Validator"
  project_id = var.project_eth_validator
  org_id     = var.org_id
  auto_create_network = false

  billing_account = var.billing_account
}

resource "google_project_iam_binding" "eth_validator_project" {
  project     = var.project_eth_validator
  role = "roles/owner"
  members = var.project_principals
  depends_on = [
    google_project.eth2_validator_project
  ]
}

resource "google_compute_shared_vpc_service_project" "eth2_validator_service_project" {
  host_project    = var.project_host_vpc
  service_project = google_project.eth2_validator_project.project_id
}