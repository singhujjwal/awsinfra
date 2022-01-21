locals {
  nginx_ingress_controller_namespace = "ingress-nginx"
}

resource "helm_release" "nginx" {
  name             = "nginx"
  chart            = "ingress-nginx"
  cleanup_on_fail  = false
  create_namespace = true
  force_update     = false
  namespace        = local.nginx_ingress_controller_namespace
  repository       = "https://kubernetes.github.io/ingress-nginx"
  version          = "4.0.15"

  values = [
    yamlencode({
      controller = {
        service = {
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-backend-protocol"        = "http"
            "service.beta.kubernetes.io/aws-load-balancer-ssl-ports"               = "https"
            "service.beta.kubernetes.io/aws-load-balancer-ssl-cert"                = "arn:aws:acm:ap-south-1:458516813260:certificate/1651b8b2-da47-4c7c-8c0b-790bef5b5629"
            "service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout" = "60"
            "service.beta.kubernetes.io/aws-load-balancer-internal"                = "false"
          }
        }
      }

    })
  ]
}