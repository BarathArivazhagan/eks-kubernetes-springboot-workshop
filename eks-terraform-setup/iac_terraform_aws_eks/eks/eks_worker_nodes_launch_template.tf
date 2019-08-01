# Worker Groups using Launch Templates

resource "aws_launch_template" "workers_launch_template" {

  count = length(var.worker_nodes_on_demand_groups)
  name_prefix = join("-",[aws_eks_cluster.eks_cluster.name,count.index])

  network_interfaces {
    associate_public_ip_address = lookup(var.worker_nodes_on_demand_groups[count.index], "public_ip", local.worker_nodes_on_demand_groups_defaults["public_ip"])
    security_groups             = [local.worker_security_group_id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.worker_nodes_instance_profile[count.index].name
  }

  image_id      = lookup(var.worker_nodes_on_demand_groups[count.index], "ami_id", local.worker_nodes_on_demand_groups_defaults["ami_id"])
  instance_type = lookup(var.worker_nodes_on_demand_groups[count.index], "instance_type", local.worker_nodes_on_demand_groups_defaults["instance_type"])
  key_name      = lookup(var.worker_nodes_on_demand_groups[count.index], "key_name", local.worker_nodes_on_demand_groups_defaults["key_name"])
  user_data     = base64encode(element(data.template_file.launch_template_userdata.*.rendered, count.index))
  ebs_optimized = lookup(var.worker_nodes_on_demand_groups[count.index], "ebs_optimized", lookup(local.ebs_optimized, lookup(var.worker_nodes_on_demand_groups[count.index], "instance_type", local.worker_nodes_on_demand_groups_defaults["instance_type"]), false))

  monitoring {
    enabled = lookup(var.worker_nodes_on_demand_groups[count.index], "enable_monitoring", local.worker_nodes_on_demand_groups_defaults["enable_monitoring"])
  }

  placement {
    tenancy = lookup(var.worker_nodes_on_demand_groups[count.index], "placement_tenancy", local.worker_nodes_on_demand_groups_defaults["placement_tenancy"])
  }


  lifecycle {
    create_before_destroy = true
  }

  block_device_mappings {
    device_name = data.aws_ami.eks_worker.root_device_name

    ebs {
      volume_size           = lookup(var.worker_nodes_on_demand_groups[count.index], "root_volume_size", local.worker_nodes_on_demand_groups_defaults["root_volume_size"])
      volume_type           = lookup(var.worker_nodes_on_demand_groups[count.index], "root_volume_type", local.worker_nodes_on_demand_groups_defaults["root_volume_type"])
      iops                  = lookup(var.worker_nodes_on_demand_groups[count.index], "root_iops", local.worker_nodes_on_demand_groups_defaults["root_iops"])
      encrypted             = lookup(var.worker_nodes_on_demand_groups[count.index], "root_encrypted", local.worker_nodes_on_demand_groups_defaults["root_encrypted"])
      kms_key_id            = lookup(var.worker_nodes_on_demand_groups[count.index], "kms_key_id", local.worker_nodes_on_demand_groups_defaults["kms_key_id"])
      delete_on_termination = true
    }
  }
}

