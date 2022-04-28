output "k8s_endpoint" {
  value = google_container_cluster.testnet.endpoint
}

output "k8s_cluster_ca_certificate" {
  value = google_container_cluster.testnet.master_auth.0.cluster_ca_certificate
}
