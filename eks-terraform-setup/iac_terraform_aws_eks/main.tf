provider "aws" {
  version = ">= 2.8.0"
  region = var.aws_region
}

locals {

  worker_groups = [
    {
      # This will launch an autoscaling group with only On-Demand instances
      instance_type        = "t3.micro"
      additional_userdata  = "echo foo bar"
      subnets              = "${module.vpc.private_subnets}"
      asg_desired_capacity = "2"
    }
  ]
  worker_groups_launch_template = [
    {
      # This will launch an autoscaling group with only Spot Fleet instances
      instance_type                            = "t3.micro"
      additional_userdata                      = "echo foo bar"
      subnets                                  = "${module.vpc.private_subnets}"
      additional_security_group_ids            = ""
      override_instance_type                   = "t3.small"
      asg_desired_capacity                     = "1"
      spot_instance_pools                      = 3
      on_demand_percentage_above_base_capacity = "0"
    }
  ]
  tags = {
    Environment = "${var.environment}"
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
  subnets                              = module.vpc.private_subnets
  tags                                 = local.tags
  vpc_id                               = module.vpc.eks_vpc_id
  worker_groups                        = local.worker_groups
  worker_groups_launch_template        = "${local.worker_groups_launch_template}"
  worker_group_count                   = "1"
  worker_group_launch_template_count   = "1"
  worker_additional_security_group_ids = [""]
  map_roles                            = var.map_roles
  map_roles_count                      = var.map_roles_count
  map_users                            = var.map_users
  map_users_count                      = var.map_users_count
  map_accounts                         = var.map_accounts
  map_accounts_count                   = var.map_accounts_count
}
