resource "helm_release" "example" {
  name       = "bitnami"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "jenkins"
  version    = "8.0.22"

  set {
    name  = "jenkinsUser"
    value = "ujjwalsingh"
  }

  set_sensitive {
    name  = "jenkinsPassword"
    value = "SuperStr0ng"
    type  = "string"
  }


  values = [
    yamlencode({
      service = {
        type = "ClusterIP"
      },
      ingress = {
        enabled  = true
        tls      = false
        path     = "/"
        hostname = "jenkins.k8s.singhjee.in"
        annotations = {
          "kubernetes.io/ingress.class" = "nginx"
        }
      }
    })
  ]
}

