terraform {
  required_providers {
    # Kubectl plugin is only needed for raw manifests which don't work with kubernetes provider.
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.9"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 4.15"
    }
  }
}

resource "kubectl_manifest" "standard-storageclass" {
  yaml_body = <<YAML
allowVolumeExpansion: true
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    storageclass.kubernetes.io/is-default-class: "false"
  labels:
    addonmanager.kubernetes.io/mode: EnsureExists
  name: standard
parameters:
  type: pd-standard
provisioner: kubernetes.io/gce-pd
reclaimPolicy: Delete
volumeBindingMode: Immediate
YAML

  apply_only = true
}

resource "kubectl_manifest" "premium-rwo-storageclass" {
  yaml_body = <<YAML
allowVolumeExpansion: true
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    components.gke.io/component-name: pdcsi
    components.gke.io/component-version: 0.10.8
    components.gke.io/layer: addon
    storageclass.kubernetes.io/is-default-class: "true"
  labels:
    addonmanager.kubernetes.io/mode: EnsureExists
    k8s-app: gcp-compute-persistent-disk-csi-driver
  name: premium-rwo
parameters:
  type: pd-ssd
provisioner: pd.csi.storage.gke.io
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
YAML

  apply_only = true
}

resource "kubectl_manifest" "gke-snapshotclass" {
  yaml_body = <<YAML
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass
metadata:
  name: gke-snapshotclass
driver: pd.csi.storage.gke.io
deletionPolicy: Delete
YAML

  depends_on = [
    kubectl_manifest.standard-storageclass,
    kubectl_manifest.premium-rwo-storageclass,
  ]
}
