variable "k8s_replicas" {
  description = "The number of replicas to run in the Kubernetes deployment"
  type        = number
}

variable "k8s_cluster_name" {
  description = "The name of the EKS cluster to deploy to"
  type        = string
}

variable "eks_endpoint" {
  description = "The endpoint of the EKS cluster"
  type        = string
}

variable "eks_cluster_ca_certificate" {
  description = "The certificate authority of the EKS cluster"
  type        = string
}

variable "eks_token" {
  description = "The token for the EKS cluster"
  type        = string
}

variable "irsa_role_arn" {
  description = "The ARN of the IAM role to associate with the service account"
  type        = string
}

variable "github_actions_role_arn" {
  description = "The ARN of the GitHub Actions role to add to the EKS auth configuration"
  type        = string
  default     = null
}