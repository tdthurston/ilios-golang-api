provider "kubernetes" {
  host                   = var.eks_endpoint
  cluster_ca_certificate = base64decode(var.eks_cluster_ca_certificate)
  token                  = var.eks_token
}

resource "kubernetes_service_account" "ilios_service_account" {
  metadata {
    name      = "ilios-service-account"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = var.irsa_role_arn
    }
  }
}

resource "kubernetes_deployment" "golang_api_deploy" {
  metadata {
    name = "golang-api-deploy"
    labels = {
      app = "golang-api"
    }
  }

  spec {
    replicas = var.k8s_replicas

    selector {
      match_labels = {
        app = "golang-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "golang-api"
        }
      }

      spec {
        container {
          image = "tdthurston/ilios-golang-api:latest"
          name  = "ilios-golang-api"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 8080
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "golang_api_service" {
  metadata {
    name = "golang-api-service"
  }
  spec {
    selector = {
      app = "golang-api"
    }
    port {
      port        = 80
      target_port = 8080
    }
    type = "LoadBalancer"
  }
}