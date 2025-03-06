terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.87.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Get information about the existing EKS cluster
data "aws_eks_cluster" "existing" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "existing" {
  name = var.cluster_name
}

# Configure the Kubernetes provider using the existing cluster
provider "kubernetes" {
  host                   = data.aws_eks_cluster.existing.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.existing.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.existing.token

    exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}


module "ilios_k8s" {
  source = "./modules/k8s"

  k8s_replicas               = var.k8s_replicas
  k8s_cluster_name           = var.cluster_name
  eks_endpoint               = data.aws_eks_cluster.existing.endpoint
  eks_cluster_ca_certificate = data.aws_eks_cluster.existing.certificate_authority.0.data
  eks_token                  = data.aws_eks_cluster_auth.existing.token
  irsa_role_arn              = var.irsa_role_arn
}

# Get the service details for output
data "kubernetes_service" "golang_api_service" {
  metadata {
    name      = "golang-api-service"
    namespace = "default"
  }
  depends_on = [module.ilios_k8s]
}

# Outputs
output "load_balancer_dns" {
  description = "DNS name of the load balancer hosting the Golang API service"
  value       = try(data.kubernetes_service.golang_api_service.status.0.load_balancer.0.ingress.0.hostname, "DNS name not available yet")
}

output "cluster_name" {
  value = var.cluster_name
}

output "aws_region" {
  value = var.aws_region
}