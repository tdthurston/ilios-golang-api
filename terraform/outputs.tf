# Cluster information

output "cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = data.aws_eks_cluster.existing.endpoint
}

# K8s deployment information

output "k8s_deployment_name" {
  description = "The name of the Kubernetes deployment"
  value       = module.ilios_k8s.deployment_name
}

output "k8s_service_name" {
  description = "The name of the Kubernetes service"
  value       = module.ilios_k8s.service_name
}

output "k8s_namespace" {
  description = "The Kubernetes namespace where resources are deployed"
  value       = module.ilios_k8s.namespace
}