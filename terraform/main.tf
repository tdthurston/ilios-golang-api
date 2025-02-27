module "ilios_vpc" {

  source             = "git::https://github.com/tdthurston/ilios-base-tf-infra.git//modules//vpc"
  vpc_cidr_block     = var.vpc_cidr_block
  vpc_name           = var.vpc_name
  subnet_cidr_blocks = var.subnet_cidr_blocks
  azs                = var.azs

}

module "ilios_eks_cluster" {

  source = "git::https://github.com/tdthurston/ilios-base-tf-infra.git//modules//eks"

  cluster_name                 = var.cluster_name
  node_group_name              = var.node_group_name
  cluster_security_group_id    = module.ilios_eks_cluster.cluster_security_group_id
  node_group_security_group_id = module.ilios_eks_cluster.node_group_security_group_id
  instance_type                = var.instance_type
  desired_capacity             = var.desired_capacity
  min_size                     = var.min_size
  max_size                     = var.max_size
  max_unavailable              = var.max_unavailable
  vpc_id                       = module.ilios_vpc.vpc_id
  private_subnet_ids           = module.ilios_vpc.private_subnet_ids

}

module "ilios_lb" {

  source = "git::https://github.com/tdthurston/ilios-base-tf-infra.git//modules/load_balancer"

  lb_name           = var.lb_name
  target_group_name = var.target_group_name
  vpc_id            = module.ilios_vpc.vpc_id
  vpc_cidr_block    = module.ilios_vpc.vpc_cidr_block
  instance_type     = module.ilios_eks_cluster.instance_type
  public_subnet_ids = module.ilios_vpc.public_subnet_ids


}

module "ilios_k8s" {

  source = "./modules/k8s"

  k8s_replicas               = var.k8s_replicas
  k8s_cluster_name           = module.ilios_eks_cluster.cluster_name
  eks_endpoint               = data.aws_eks_cluster.eks.endpoint
  eks_cluster_ca_certificate = data.aws_eks_cluster.eks.certificate_authority.0.data
  eks_token                  = data.aws_eks_cluster_auth.eks.token
  irsa_role_arn              = module.oidc.oidc_role_arn

}

data "aws_eks_cluster" "eks" {
  name = module.ilios_eks_cluster.cluster_name
  depends_on = [ module.ilios_eks_cluster ]
}

data "aws_eks_cluster_auth" "eks" {
  name = module.ilios_eks_cluster.cluster_name
  depends_on = [ module.ilios_eks_cluster ]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks.token
  
}

data "kubernetes_service" "golang_api_service" {
  metadata {
    name      = "golang-api-service"
    namespace = "default"
  }
  depends_on = [ module.ilios_eks_cluster ]
}

output "eks_endpoint" {
  value = data.aws_eks_cluster.eks.endpoint
}

output "eks_cluster_ca_certificate" {
  value     = data.aws_eks_cluster.eks.certificate_authority[0].data
  sensitive = true
}

output "eks_token" {
  value = data.aws_eks_cluster_auth.eks.token
  sensitive = true
}

output "load_balancer_dns" {
  description = "The DNS name of the load balancer hosting the Golang API service"
  value       = data.kubernetes_service.golang_api_service.status.0.load_balancer.0.ingress.0.hostname
}