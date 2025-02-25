output "deployment_name" {
  value = kubernetes_deployment.golang_api_deploy.metadata[0].name
}

output "service_name" {
  value = kubernetes_service.golang_api_service.metadata[0].name
}

output "service_ip" {
  value = kubernetes_service.golang_api_service.status[0].load_balancer[0].ingress[0].ip
}