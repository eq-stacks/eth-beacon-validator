resource "kubernetes_namespace" "observability" {
  metadata {
    name = "observability"
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "observability"

  depends_on = [
    kubernetes_namespace.observability,
  ]
}

resource "helm_release" "beaconchain-prometheus-exporter" {
  name      = "beaconchain-prometheus-exporter"
  chart     = "${path.root}/charts/beaconchain-prometheus-exporter"
  namespace = "observability"

  depends_on = [
    helm_release.prometheus,
  ]
}

resource "kubernetes_ingress_v1" "prometheus-grafana" {
  metadata {
    name = "prometheus-grafana"
  }

  spec {
    rule {
      http {
        path {
          backend {
            service {
              name = "prometheus-grafana"
              port {
                number = 80
              }
            }
          }

          path      = "/"
          path_type = "Prefix"
        }
      }
    }
  }

  depends_on = [
    helm_release.prometheus,
  ]
}

resource "kubernetes_ingress_v1" "prometheus" {
  metadata {
    name = "prometheus"
  }

  spec {
    rule {
      http {
        path {
          backend {
            service {
              name = "prometheus-kube-prometheus-prometheus"
              port {
                number = 9090
              }
            }
          }

          path      = "/"
          path_type = "Prefix"
        }
      }
    }
  }

  depends_on = [
    helm_release.prometheus,
  ]
}
