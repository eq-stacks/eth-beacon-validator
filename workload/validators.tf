resource "kubernetes_namespace" "validators" {
  metadata {
    name = "validators"
  }
}
resource "helm_release" "geth" {
  name      = "geth"
  chart     = "${path.root}/charts/geth"
  namespace = "validators"

  depends_on = [
    kubernetes_namespace.validators,
  ]
}


resource "helm_release" "nimbus" {
  name      = "nimbus"
  chart     = "${path.root}/charts/nimbus"
  namespace = "validators"

  depends_on = [
    kubernetes_namespace.validators,
  ]
}
