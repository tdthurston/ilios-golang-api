output "vpc_id" {
  value = module.ilios_vpc.vpc_id
}
output "public_subnet_ids" {
  value = module.ilios_vpc.public_subnet_ids
}
output "private_subnet_ids" {
  value = module.ilios_vpc.private_subnet_ids
}
output "internet_gateway_id" {
  value = module.ilios_vpc.internet_gateway_id
}
output "nat_gateway_id" {
  value = module.ilios_vpc.nat_gateway_id
}
output "vpc_cidr_block" {
  value = module.ilios_vpc.vpc_cidr_block
}

output "cluster_id" {
  description = "The ID of the EKS cluster"
  value       = module.ilios_eks_cluster.cluster_id
}

output "cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = module.ilios_eks_cluster.cluster_endpoint
}

output "instance_type" {
  description = "The instance type of the EKS cluster"
  value       = var.instance_type
}

output "lb_arn" {
  value = module.ilios_lb.lb_arn
}

output "target_group_arn" {
  value = module.ilios_lb.target_group_arn
}

output "listener_arn" {
  value = module.ilios_lb.listener_arn
}