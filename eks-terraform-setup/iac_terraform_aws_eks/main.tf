provider "aws" {
  version = ">= 2.8.0"
  region = var.aws_region
}

locals {

  # This will launch an autoscaling group with only On-Demand instances
  worker_nodes_on_demand_groups = [
    {

      instance_type        = "t3.micro"
      additional_userdata  = ""
      subnets              =  module.vpc.private_subnets
      asg_desired_capacity = "1"                             # Desired worker capacity in the autoscaling group.
      asg_max_size         = "3"                             # Maximum worker capacity in the autoscaling group.
      asg_min_size         = "1"
      key_name             = var.worker_node_key_name
    }
  ]
  # This will launch an autoscaling group with only Spot Fleet instances
  worker_nodes_mixed_groups = [
    {

      instance_type                            = "t3.micro"
      additional_userdata                      = ""
      subnets                                  = module.vpc.private_subnets
      additional_security_group_ids            = ""
      override_instance_type                   = "t3.small"
      asg_desired_capacity                     = "1"
      spot_instance_pools                      = 3
      on_demand_percentage_above_base_capacity = "0"
      key_name                                 = var.worker_node_key_name
    }
  ]
  tags = {
    Environment = var.environment
  }
}



module "vpc" {
  source             = "./vpc"
  stack_name         = var.stack_name
  subnets            = var.subnets
  vpc_cidr_block     = var.vpc_cidr_block

}

module "eks" {
  source                               = "./eks"
  aws_region                           = var.aws_region
  cluster_name                         = join("-",[var.stack_name,"eks"])
  cluster_version                      = var.cluster_version
  private_subnets                      = module.vpc.private_subnets
  public_subnets                       = module.vpc.public_subnets
  tags                                 = local.tags
  vpc_id                               = module.vpc.eks_vpc_id
  worker_nodes_on_demand_groups        = local.worker_nodes_on_demand_groups
  worker_nodes_mixed_groups            = local.worker_nodes_mixed_groups
  worker_additional_security_group_ids = [""]
  bastion                              = true
  bastion_instance_role                = var. bastion_instance_role
  bastion_ami_id                       = var.bastion_ami_id
  map_roles                            = var.map_roles
  map_roles_count                      = var.map_roles_count
  map_users                            = var.map_users
  map_users_count                      = var.map_users_count
  map_accounts                         = var.map_accounts
  map_accounts_count                   = var.map_accounts_count

}
