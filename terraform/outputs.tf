output "vpc_id" {
  description = "The ID of the VPC"
  value = module.ilios_vpc.vpc_id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value = module.ilios_vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value = module.ilios_vpc.private_subnet_ids
}

output "internet_gateway_id" {
  description = "The ID of the internet gateway"
  value = module.ilios_vpc.internet_gateway_id
}

output "nat_gateway_id" {
  description = "The ID of the NAT gateway"
  value = module.ilios_vpc.nat_gateway_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
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
  description = "The ARN of the load balancer"
  value = module.ilios_lb.lb_arn
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value = module.ilios_lb.target_group_arn
}

output "listener_arn" {
  description = "The ARN of the listener"
  value = module.ilios_lb.listener_arn
}