provider "aws" {
  version = "~> 2.8.0"
  region = var.aws_region
}



locals {

  # the commented out worker group list below shows an example of how to define
  # multiple worker groups of differing configurations
  # worker_groups = [
  #   {
  #     asg_desired_capacity = 2
  #     asg_max_size = 10
  #     asg_min_size = 2
  #     instance_type = "m4.xlarge"
  #     name = "worker_group_a"
  #     additional_userdata = "echo foo bar"
  #     subnets = "${join(",", module.vpc.private_subnets)}"
  #   },
  #   {
  #     asg_desired_capacity = 1
  #     asg_max_size = 5
  #     asg_min_size = 1
  #     instance_type = "m4.2xlarge"
  #     name = "worker_group_b"
  #     additional_userdata = "echo foo bar"
  #     subnets = "${join(",", module.vpc.private_subnets)}"
  #   },
  # ]


  # the commented out worker group tags below shows an example of how to define
  # custom tags for the worker groups ASG
  # worker_group_tags = {
  #   worker_group_a = [
  #     {
  #       key                 = "k8s.io/cluster-autoscaler/node-template/taint/nvidia.com/gpu"
  #       value               = "gpu:NoSchedule"
  #       propagate_at_launch = true
  #     },
  #   ],
  #   worker_group_b = [
  #     {
  #       key                 = "k8s.io/cluster-autoscaler/node-template/taint/nvidia.com/gpu"
  #       value               = "gpu:NoSchedule"
  #       propagate_at_launch = true
  #     },
  #   ],
  # }

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
      additional_security_group_ids            = "${aws_security_group.worker_group_mgmt_one.id},${aws_security_group.worker_group_mgmt_two.id}"
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


resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  description = "SG to be applied to all *nix machines"
  vpc_id      = module.vpc.eks_vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  vpc_id      = module.vpc.eks_vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.eks_vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
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
  cluster_name                         =  join("-",[var.stack_name,"eks"])
  subnets                              =  module.vpc.private_subnets
  tags                                 = "${local.tags}"
  vpc_id                               =  module.vpc.eks_vpc_id
  worker_groups                        = "${local.worker_groups}"
  worker_groups_launch_template        = "${local.worker_groups_launch_template}"
  worker_group_count                   = "1"
  worker_group_launch_template_count   = "1"
  worker_additional_security_group_ids = ["${aws_security_group.all_worker_mgmt.id}"]
  map_roles                            = "${var.map_roles}"
  map_roles_count                      = "${var.map_roles_count}"
  map_users                            = "${var.map_users}"
  map_users_count                      = "${var.map_users_count}"
  map_accounts                         = "${var.map_accounts}"
  map_accounts_count                   = "${var.map_accounts_count}"
}
