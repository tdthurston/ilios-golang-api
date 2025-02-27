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