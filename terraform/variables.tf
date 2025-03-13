# Specify AWS region you would like to create resources in

variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
}

# Define Kubernetes variables

variable "k8s_replicas" {
  description = "Number of replicas in k8s deployment"
  type        = number
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "irsa_role_arn" {
  description = "IAM role ARN for service account"
  type        = string
}

variable "github_actions_role_arn" {
  description = "ARN of the GitHub Actions role to add to the EKS auth configuration"
  type        = string
  default     = null
}
