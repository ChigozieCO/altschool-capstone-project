# Create vpc using the terraform aws vpc module
module "vpc" {
  source                  = "terraform-aws-modules/vpc/aws"

  name                    = var.vpcname
  cidr                    = "10.0.0.0/16"

  azs                     = slice(data.aws_availability_zones.azs.names, 0, 3)
  private_subnets         = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  # private_subnet_names    = ["priv-sub-1", "priv-sub-2", "priv-sub-3"]
  public_subnets          = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  # public_subnet_names     = ["pub-sub-1", "pub-sub-2", "pub-sub-3"]

  enable_nat_gateway      = true
  single_nat_gateway      = true
  enable_dns_hostnames    = true

 public_subnet_tags = {
  "kubernetes.io/role/internal-elb"             = 1 # If you want to deploy load balancers to a subnet, the subnet must have 
 }

 private_subnet_tags = {
  "kubernetes.io/role/internal-elb"             = 1 # If you want to deploy load balancers to a subnet, the subnet must have 
 }
}