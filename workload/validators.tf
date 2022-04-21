resource "kubernetes_namespace" "validators" {
  metadata {
    name = "validators"
  }
}
resource "helm_release" "geth" {
  name      = "geth"
  chart     = "../charts/geth"
  namespace = "validators"

  depends_on = [
    kubernetes_namespace.validators,
  ]
}


resource "helm_release" "nimbus" {
  name      = "nimbus"
  chart     = "../charts/nimbus"
  namespace = "validators"

  depends_on = [
    kubernetes_namespace.validators,
  ]
}
