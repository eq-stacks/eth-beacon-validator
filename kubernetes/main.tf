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

resource "kubernetes_storage_class" "standard" {
  metadata {
    name = "standard"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "false"
    }
  }

  storage_provisioner = "kubernetes.io/gce-pd"
}

resource "kubernetes_storage_class" "premium-rwo" {
  metadata {
    name = "premium-rwo"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "kubernetes.io/gce-pd"
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
}
