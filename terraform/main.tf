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

  k8s_replicas = var.k8s_replicas
  k8s_cluster_name = module.ilios_eks_cluster.cluster_name
  kubeconfig_path  = local_file.kubeconfig.filename

}

data "template_file" "kubeconfig" {
  template = file("${path.module}/kubeconfig_template.yaml")
  vars = {
    ca_certificate = base64encode(module.ilios_eks_cluster.cluster_ca_certificate)
    endpoint       = module.ilios_eks_cluster.cluster_endpoint
    cluster_name   = module.ilios_eks_cluster.cluster_name
    token          = data.aws_eks_cluster_auth.this.token
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.ilios_eks_cluster.cluster_name
}

resource "local_file" "kubeconfig" {
  content  = data.template_file.kubeconfig.rendered
  filename = "${path.module}/kubeconfig.yaml"
}