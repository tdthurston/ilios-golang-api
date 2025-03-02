output "deployment_name" {
  description = "K8s deployment name"
  value       = kubernetes_deployment.golang_api_deploy.metadata[0].name
}

output "service_name" {
  description = "K8s service name"
  value       = kubernetes_service.golang_api_service.metadata[0].name
}

output "service_ip" {
  description = "K8s service IP"
  value       = kubernetes_service.golang_api_service.status[0].load_balancer[0].ingress[0].ip
}

output "api_lb_dns" {
  description = "DNS name of the load balancer hosting the Golang API service"
  value       = kubernetes_service.golang_api_service.status[0].load_balancer[0].ingress[0].hostname
}