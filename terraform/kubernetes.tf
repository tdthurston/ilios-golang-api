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

data "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
}

resource "kubernetes_config_map_v1_data" "aws_auth_update" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  force = true


  data = {
    mapRoles = yamlencode(
      distinct(concat(
        yamldecode(lookup(data.kubernetes_config_map.aws_auth.data, "mapRoles", "[]")),
        [{
          rolearn  = var.github_actions_role_arn
          username = "github-actions"
          groups   = ["system:masters"]
        }]
      ))
    )
  }

  depends_on = [
    data.kubernetes_config_map.aws_auth
  ]
}

data "aws_caller_identity" "current" {}

module "ilios_k8s" {

  source = "./modules/k8s"

  aws_region                 = var.aws_region
  k8s_replicas               = var.k8s_replicas
  k8s_cluster_name           = var.cluster_name
  eks_endpoint               = data.aws_eks_cluster.existing.endpoint
  eks_cluster_ca_certificate = data.aws_eks_cluster.existing.certificate_authority.0.data
  eks_token                  = data.aws_eks_cluster_auth.existing.token
  irsa_role_arn              = aws_iam_role.ilios_api_irsa_role.arn
  github_actions_role_arn = var.github_actions_role_arn != null ? var.github_actions_role_arn : data.aws_caller_identity.current.arn

}

# Get the service details for output
data "kubernetes_service" "golang_api_service" {
  metadata {
    name      = "golang-api-service"
    namespace = "default"
  }
  depends_on = [module.ilios_k8s]
}

resource "aws_iam_role" "ilios_api_irsa_role" {
  name = "ilios-api-irsa-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.existing.identity[0].oidc[0].issuer, "https://", "")}"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.existing.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:default:ilios-service-account"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ilios_api_permissions" {
  name        = "ilios-api-permissions"
  description = "Permissions for Ilios API to access AWS resources"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeInstances",
          "eks:ListClusters", 
          "eks:DescribeCluster"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ilios_api_role_attachment" {
  role       = aws_iam_role.ilios_api_irsa_role.name
  policy_arn = aws_iam_policy.ilios_api_permissions.arn
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