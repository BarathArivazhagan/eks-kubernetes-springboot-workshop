# Worker Groups using Launch Configurations

resource "aws_autoscaling_group" "workers" {
  name_prefix           = "${aws_eks_cluster.eks_cluster.name}-${lookup(var.worker_groups[count.index], "name", count.index)}"
  desired_capacity      = "${lookup(var.worker_groups[count.index], "asg_desired_capacity", local.workers_group_defaults["asg_desired_capacity"])}"
  max_size              = "${lookup(var.worker_groups[count.index], "asg_max_size", local.workers_group_defaults["asg_max_size"])}"
  min_size              = "${lookup(var.worker_groups[count.index], "asg_min_size", local.workers_group_defaults["asg_min_size"])}"
  force_delete          = "${lookup(var.worker_groups[count.index], "asg_force_delete", local.workers_group_defaults["asg_force_delete"])}"
 // target_group_arns     = ["${compact(split(",", local.workers_group_defaults["target_group_arns"]))}"]
  launch_configuration  = "${element(aws_launch_configuration.workers.*.id, count.index)}"
  vpc_zone_identifier   =  var.private_subnets
  protect_from_scale_in = "${lookup(var.worker_groups[count.index], "protect_from_scale_in", local.workers_group_defaults["protect_from_scale_in"])}"
  //enabled_metrics       = ["${compact(split(",", coalesce(lookup(var.worker_groups[count.index], ""), local.workers_group_defaults["enabled_metrics"])))}"]suspended_processes   = ["${compact(split(",", coalesce(lookup(var.worker_groups[count.index], "suspended_processes", ""), local.workers_group_defaults["suspended_processes"])))}"]

  count                 = "${var.worker_group_count}"
  placement_group       = "${lookup(var.worker_groups[count.index], "placement_group", local.workers_group_defaults["placement_group"])}"


  lifecycle {
    create_before_destroy = true

    ignore_changes = ["desired_capacity"]
  }
}

resource "aws_launch_configuration" "workers" {
  name_prefix                 = "${aws_eks_cluster.eks_cluster.name}-${lookup(var.worker_groups[count.index], "name", count.index)}"
  associate_public_ip_address = lookup(var.worker_groups[count.index], "public_ip", local.workers_group_defaults["public_ip"])
  security_groups             = [local.worker_security_group_id]
  iam_instance_profile        = element(aws_iam_instance_profile.workers.*.id, count.index)
  image_id                    = lookup(var.worker_groups[count.index], "ami_id", local.workers_group_defaults["ami_id"])
  instance_type               = lookup(var.worker_groups[count.index], "instance_type", local.workers_group_defaults["instance_type"])
  key_name                    = lookup(var.worker_groups[count.index], "key_name", local.workers_group_defaults["key_name"])
  user_data_base64            = base64encode(element(data.template_file.userdata.*.rendered, count.index))
  ebs_optimized               = lookup(var.worker_groups[count.index], "ebs_optimized", lookup(local.ebs_optimized, lookup(var.worker_groups[count.index], "instance_type", local.workers_group_defaults["instance_type"]), false))
  enable_monitoring           = lookup(var.worker_groups[count.index], "enable_monitoring", local.workers_group_defaults["enable_monitoring"])
  spot_price                  = lookup(var.worker_groups[count.index], "spot_price", local.workers_group_defaults["spot_price"])
  placement_tenancy           = lookup(var.worker_groups[count.index], "placement_tenancy", local.workers_group_defaults["placement_tenancy"])
  count                       = var.worker_group_count

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_size           = lookup(var.worker_groups[count.index], "root_volume_size", local.workers_group_defaults["root_volume_size"])
    volume_type           = lookup(var.worker_groups[count.index], "root_volume_type", local.workers_group_defaults["root_volume_type"])
    iops                  = lookup(var.worker_groups[count.index], "root_iops", local.workers_group_defaults["root_iops"])
    delete_on_termination = true
  }
}



