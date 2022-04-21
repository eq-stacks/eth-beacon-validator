resource "google_project" "eth2_validator_project" {
  name                = var.project_eth_validator
  project_id          = var.project_eth_validator
  org_id              = var.org_id
  auto_create_network = false

  billing_account = var.billing_account
}

resource "google_project_iam_binding" "eth_validator_project" {
  project = var.project_eth_validator
  role    = "roles/owner"
  members = var.project_owners

  depends_on = [
    google_project.eth2_validator_project
  ]
}

resource "google_compute_shared_vpc_service_project" "eth2_validator_service_project" {
  host_project    = var.project_host
  service_project = google_project.eth2_validator_project.project_id
}

resource "google_project_service" "container" {
  project = google_project.eth2_validator_project.project_id
  service = "container.googleapis.com"

  disable_dependent_services = true
  depends_on = [
    google_project.eth2_validator_project
  ]
}

resource "google_project_iam_binding" "host_project" {
  project = var.project_host
  role    = "roles/container.hostServiceAgentUser"
  members = [
    "serviceAccount:service-${google_project.eth2_validator_project.number}@container-engine-robot.iam.gserviceaccount.com"
  ]
}

resource "google_compute_subnetwork_iam_binding" "subnetwork" {
  project    = var.project_host
  region     = var.region
  subnetwork = var.cluster_subnet
  role       = "roles/compute.networkUser"
  members = [
    "serviceAccount:service-${google_project.eth2_validator_project.number}@container-engine-robot.iam.gserviceaccount.com",
    "serviceAccount:${google_project.eth2_validator_project.number}@cloudservices.gserviceaccount.com"
  ]
}

data "google_compute_network" "host_vpc" {
  name    = var.project_host_vpc
  project = var.project_host
}

data "google_compute_subnetwork" "cluster_subnet" {
  name    = var.cluster_subnet
  region  = var.region
  project = var.project_host
}

resource "google_container_cluster" "testnet" {
  name     = "testnet-cluster"
  location = var.location
  project  = google_project.eth2_validator_project.project_id

  # Create the smallest possible default node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = data.google_compute_network.host_vpc.self_link
  subnetwork = data.google_compute_subnetwork.cluster_subnet.self_link

  ip_allocation_policy {
    cluster_secondary_range_name  = "${var.cluster_subnet}-pods"
    services_secondary_range_name = "${var.cluster_subnet}-services"
  }

  depends_on = [
    google_project_service.container,
    google_project_iam_binding.host_project,
    google_compute_subnetwork_iam_binding.subnetwork
  ]
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "primary"
  cluster    = google_container_cluster.testnet.id
  node_count = 3

  node_config {
    preemptible  = true
    machine_type = var.worker_node_type

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    # service_account = google_service_account.default.email
    # oauth_scopes = [
    #   "https://www.googleapis.com/auth/cloud-platform"
    # ]
  }
}