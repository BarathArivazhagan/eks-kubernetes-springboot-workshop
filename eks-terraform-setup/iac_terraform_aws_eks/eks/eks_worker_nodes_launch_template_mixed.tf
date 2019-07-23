# Worker Groups using Launch Templates with mixed instances policy



resource "aws_launch_template" "workers_launch_template_mixed" {
  count       = var.worker_node_group_mixed_count
  name_prefix = "${aws_eks_cluster.eks_cluster.name}-${lookup(var.worker_groups_launch_template_mixed[count.index], "name", count.index)}"

  network_interfaces {
    associate_public_ip_address = "${lookup(var.worker_groups_launch_template_mixed[count.index], "public_ip", local.workers_group_defaults["public_ip"])}"
    delete_on_termination       = "${lookup(var.worker_groups_launch_template_mixed[count.index], "eni_delete", local.workers_group_defaults["eni_delete"])}"
    security_groups             = ["${local.worker_security_group_id}"]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.worker_nodes_instance_profile[count.index].name
  }

  image_id      = "${lookup(var.worker_groups_launch_template_mixed[count.index], "ami_id", local.workers_group_defaults["ami_id"])}"
  instance_type = "${lookup(var.worker_groups_launch_template_mixed[count.index], "instance_type", local.workers_group_defaults["instance_type"])}"
  key_name      = "${lookup(var.worker_groups_launch_template_mixed[count.index], "key_name", local.workers_group_defaults["key_name"])}"
  user_data     = "${base64encode(element(data.template_file.workers_launch_template_mixed.*.rendered, count.index))}"
  ebs_optimized = "${lookup(var.worker_groups_launch_template_mixed[count.index], "ebs_optimized", lookup(local.ebs_optimized, lookup(var.worker_groups_launch_template_mixed[count.index], "instance_type", local.workers_group_defaults["instance_type"]), false))}"

  monitoring {
    enabled = "${lookup(var.worker_groups_launch_template_mixed[count.index], "enable_monitoring", local.workers_group_defaults["enable_monitoring"])}"
  }

  placement {
    tenancy    = "${lookup(var.worker_groups_launch_template_mixed[count.index], "launch_template_placement_tenancy", local.workers_group_defaults["launch_template_placement_tenancy"])}"
    group_name = "${lookup(var.worker_groups_launch_template_mixed[count.index], "launch_template_placement_group", local.workers_group_defaults["launch_template_placement_group"])}"
  }

  block_device_mappings {
    device_name = "${lookup(var.worker_groups_launch_template_mixed[count.index], "root_block_device_name", local.workers_group_defaults["root_block_device_name"])}"

    ebs {
      volume_size           = "${lookup(var.worker_groups_launch_template_mixed[count.index], "root_volume_size", local.workers_group_defaults["root_volume_size"])}"
      volume_type           = "${lookup(var.worker_groups_launch_template_mixed[count.index], "root_volume_type", local.workers_group_defaults["root_volume_type"])}"
      iops                  = "${lookup(var.worker_groups_launch_template_mixed[count.index], "root_iops", local.workers_group_defaults["root_iops"])}"
      encrypted             = "${lookup(var.worker_groups_launch_template_mixed[count.index], "root_encrypted", local.workers_group_defaults["root_encrypted"])}"
      kms_key_id            = "${lookup(var.worker_groups_launch_template_mixed[count.index], "root_kms_key_id", local.workers_group_defaults["root_kms_key_id"])}"
      delete_on_termination = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
