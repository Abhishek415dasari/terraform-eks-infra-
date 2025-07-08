module "networking" {
  source          = "./modules/networking"
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = var.azs
}
 
module "iam" {
  source       = "./modules/iam"
  cluster_name = var.cluster_name
  oidc_issuer  = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = module.iam.cluster_role_arn

  vpc_config {
    subnet_ids = module.networking.private_subnet_ids
  }

  depends_on = [
    module.iam
  ]
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = module.iam.node_role_arn
  subnet_ids      = module.networking.private_subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  instance_types = ["t3.medium"]
}

module "karpenter" {
  source       = "./modules/karpenter"
  cluster_name = var.cluster_name
  oidc_issuer  = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
