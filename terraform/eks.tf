module "eks" {
  source                                   = "terraform-aws-modules/eks/aws"
  version                                  = "~> 20.0"

  cluster_name                             = var.cluster_name
  cluster_version                          = "1.30"

  cluster_endpoint_public_access           = true

  vpc_id                                   = module.vpc.vpc_id
  subnet_ids                               = module.vpc.private_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
    ami_type                               = "AL2023_x86_64_STANDARD"
  }

  eks_managed_node_groups = {
    one = {
      name                                 = "node-group-1"
      instance_types                       = ["t2.medium"]

      min_size                             = 1
      max_size                             = 3
      desired_size                         = 2
    }

    two = {
      name                                 = "node-group-2"
      instance_types                       = ["t2.medium"]

      min_size                             = 1
      max_size                             = 2
      desired_size                         = 1
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

}