# Configure AWS provider
provider "aws" {
  region = var.region
}

# Create VPC
module "vpc" {
  source                       = "../vpc"
  region                       = var.region  
  project_name                 = var.project_name  
  vpc_cidr                     = var.vpc_cidr  
  public_subnet_az1_cidr       = var.public_subnet_az1_cidr 
  public_subnet_az2_cidr       = var.public_subnet_az2_cidr 
  private_app_subnet_az1_cidr  = var.private_app_subnet_az1_cidr
  private_app_subnet_az2_cidr  = var.private_app_subnet_az2_cidr 
  private_data_subnet_az1_cidr = var.private_data_subnet_az1_cidr
  private_data_subnet_az2_cidr = var.private_data_subnet_az2_cidr
}

# Output the VPC ID and other necessary information
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_app_subnet_ids" {
  value = module.vpc.private_app_subnet_ids
}

# Create EKS cluster
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.24"

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_app_subnet_ids

  eks_managed_node_groups = {
    nodes = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_type = ["t2.small"]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
