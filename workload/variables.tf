variable "bootstrap_geth_data_from_snapshot" {
  description = "Bootstrap geth data disk from volume snapshot"
  type        = bool
  default     = false
}

variable "cluster_name" {
  description = "Cluster Name"
  type        = string
}
