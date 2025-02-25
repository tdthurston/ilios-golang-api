variable "k8s_replicas" {
  description = "The number of replicas to run in the Kubernetes deployment"
  type        = number
}

variable "k8s_cluster_name" {
  description = "The name of the EKS cluster to deploy to"
  type        = string
}

variable "kubeconfig_path" {
  description = "The path to the kubeconfig file to use for the Kubernetes deployment"
  type        = string
}