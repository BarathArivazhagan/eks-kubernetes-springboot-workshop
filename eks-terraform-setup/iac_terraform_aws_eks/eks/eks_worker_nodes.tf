resource "aws_autoscaling_group" "worker_nodes_asg" {
  count             = var.worker_node_group_count
  name_prefix       = "${aws_eks_cluster.eks_cluster.name}-${lookup(var.worker_groups_launch_template[count.index], "name", count.index)}"
  desired_capacity  = lookup(var.worker_groups_launch_template[count.index], "asg_desired_capacity", local.workers_group_launch_template_defaults["asg_desired_capacity"])
  max_size          = lookup(var.worker_groups_launch_template[count.index], "asg_max_size", local.workers_group_launch_template_defaults["asg_max_size"])
  min_size          = lookup(var.worker_groups_launch_template[count.index], "asg_min_size", local.workers_group_launch_template_defaults["asg_min_size"])
  force_delete      = lookup(var.worker_groups_launch_template[count.index], "asg_force_delete", local.workers_group_launch_template_defaults["asg_force_delete"])
  //target_group_arns = ["${compact(split(",", coalesce(lookup(var.worker_groups_launch_template[count.index], "target_group_arns", ""), local.workers_group_launch_template_defaults["target_group_arns"])))}"]
  //target_group_arns = []
  mixed_instances_policy {
    instances_distribution {
      on_demand_allocation_strategy            = "${lookup(var.worker_groups_launch_template[count.index], "on_demand_allocation_strategy", local.workers_group_launch_template_defaults["on_demand_allocation_strategy"])}"
      on_demand_base_capacity                  = "${lookup(var.worker_groups_launch_template[count.index], "on_demand_base_capacity", local.workers_group_launch_template_defaults["on_demand_base_capacity"])}"
      on_demand_percentage_above_base_capacity = "${lookup(var.worker_groups_launch_template[count.index], "on_demand_percentage_above_base_capacity", local.workers_group_launch_template_defaults["on_demand_percentage_above_base_capacity"])}"
      spot_allocation_strategy                 = "${lookup(var.worker_groups_launch_template[count.index], "spot_allocation_strategy", local.workers_group_launch_template_defaults["spot_allocation_strategy"])}"
      spot_instance_pools                      = "${lookup(var.worker_groups_launch_template[count.index], "spot_instance_pools", local.workers_group_launch_template_defaults["spot_instance_pools"])}"
      spot_max_price                           = "${lookup(var.worker_groups_launch_template[count.index], "spot_max_price", local.workers_group_launch_template_defaults["spot_max_price"])}"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = "${element(aws_launch_template.workers_launch_template.*.id, count.index)}"
        version            = "$Latest"
      }

      override {
        instance_type = "${lookup(var.worker_groups_launch_template[count.index], "instance_type", local.workers_group_launch_template_defaults["instance_type"])}"
      }

      override {
        instance_type = "${lookup(var.worker_groups_launch_template[count.index], "override_instance_type", local.workers_group_launch_template_defaults["override_instance_type"])}"
      }
    }
  }

  vpc_zone_identifier   =  var.private_subnets
  protect_from_scale_in = lookup(var.worker_groups_launch_template[count.index], "protect_from_scale_in", local.workers_group_launch_template_defaults["protect_from_scale_in"])
  //suspended_processes   = ["${compact(split(",", coalesce(lookup(var.worker_groups_launch_template[count.index], "suspended_processes", ""), local.workers_group_launch_template_defaults["suspended_processes"])))}"]
  //enabled_metrics       = ["${compact(split(",", coalesce(lookup(var.worker_groups_launch_template[count.index], "enabled_metrics", ""), local.workers_group_launch_template_defaults["enabled_metrics"])))}"]


  lifecycle {
    create_before_destroy = true

    ignore_changes = ["desired_capacity"]
  }
}

resource "aws_autoscaling_group" "worker_nodes_asg_mixed" {
  count                   =  var.worker_node_group_mixed_count
  name_prefix             = "${aws_eks_cluster.eks_cluster.name}-${lookup(var.worker_groups_launch_template_mixed[count.index], "name", count.index)}"
  desired_capacity        = "${lookup(var.worker_groups_launch_template_mixed[count.index], "asg_desired_capacity", local.workers_group_defaults["asg_desired_capacity"])}"
  max_size                = "${lookup(var.worker_groups_launch_template_mixed[count.index], "asg_max_size", local.workers_group_defaults["asg_max_size"])}"
  min_size                = "${lookup(var.worker_groups_launch_template_mixed[count.index], "asg_min_size", local.workers_group_defaults["asg_min_size"])}"
  force_delete            =  lookup(var.worker_groups_launch_template_mixed[count.index], "asg_force_delete", local.workers_group_defaults["asg_force_delete"])
  target_group_arns       =  compact(split(",", coalesce(lookup(var.worker_groups_launch_template_mixed[count.index], "target_group_arns", ""), local.workers_group_defaults["target_group_arns"])))
  service_linked_role_arn =  lookup(var.worker_groups_launch_template_mixed[count.index], "service_linked_role_arn", local.workers_group_defaults["service_linked_role_arn"])
  vpc_zone_identifier     =  split(",", coalesce(lookup(var.worker_groups_launch_template_mixed[count.index], "subnets", ""), local.workers_group_defaults["subnets"]))
  protect_from_scale_in   =  lookup(var.worker_groups_launch_template_mixed[count.index], "protect_from_scale_in", local.workers_group_defaults["protect_from_scale_in"])
  suspended_processes     =  compact(split(",", coalesce(lookup(var.worker_groups_launch_template_mixed[count.index], "suspended_processes", ""), local.workers_group_defaults["suspended_processes"])))
  enabled_metrics         =  compact(split(",", coalesce(lookup(var.worker_groups_launch_template_mixed[count.index], "enabled_metrics", ""), local.workers_group_defaults["enabled_metrics"])))
  placement_group         =  lookup(var.worker_groups_launch_template_mixed[count.index], "placement_group", local.workers_group_defaults["placement_group"])

  mixed_instances_policy {
    instances_distribution {
      on_demand_allocation_strategy             = "${lookup(var.worker_groups_launch_template_mixed[count.index], "on_demand_allocation_strategy", local.workers_group_defaults["on_demand_allocation_strategy"])}"
      on_demand_base_capacity                  = "${lookup(var.worker_groups_launch_template_mixed[count.index], "on_demand_base_capacity", local.workers_group_defaults["on_demand_base_capacity"])}"
      on_demand_percentage_above_base_capacity = "${lookup(var.worker_groups_launch_template_mixed[count.index], "on_demand_percentage_above_base_capacity", local.workers_group_defaults["on_demand_percentage_above_base_capacity"])}"
      spot_allocation_strategy                 = "${lookup(var.worker_groups_launch_template_mixed[count.index], "spot_allocation_strategy", local.workers_group_defaults["spot_allocation_strategy"])}"
      spot_instance_pools                      = "${lookup(var.worker_groups_launch_template_mixed[count.index], "spot_instance_pools", local.workers_group_defaults["spot_instance_pools"])}"
      spot_max_price                           = "${lookup(var.worker_groups_launch_template_mixed[count.index], "spot_max_price", local.workers_group_defaults["spot_max_price"])}"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = "${element(aws_launch_template.workers_launch_template_mixed.*.id, count.index)}"
        version            = "${lookup(var.worker_groups_launch_template_mixed[count.index], "launch_template_version", local.workers_group_defaults["launch_template_version"])}"
      }

      override {
        instance_type = "${lookup(var.worker_groups_launch_template_mixed[count.index], "override_instance_type_1", local.workers_group_defaults["override_instance_type_1"])}"
      }

      override {
        instance_type = "${lookup(var.worker_groups_launch_template_mixed[count.index], "override_instance_type_2", local.workers_group_defaults["override_instance_type_2"])}"
      }

      override {
        instance_type = "${lookup(var.worker_groups_launch_template_mixed[count.index], "override_instance_type_3", local.workers_group_defaults["override_instance_type_3"])}"
      }

      override {
        instance_type = "${lookup(var.worker_groups_launch_template_mixed[count.index], "override_instance_type_4", local.workers_group_defaults["override_instance_type_4"])}"
      }
    }
  }

  tags = ["${concat(
    list(
      map("key", "Name", "value", "${aws_eks_cluster.eks_cluster.name}-${lookup(var.worker_groups_launch_template_mixed[count.index], "name", count.index)}-eks_asg", "propagate_at_launch", true),
      map("key", "kubernetes.io/cluster/${aws_eks_cluster.eks_cluster.name}", "value", "owned", "propagate_at_launch", true),
      map("key", "k8s.io/cluster-autoscaler/${lookup(var.worker_groups_launch_template_mixed[count.index], "autoscaling_enabled", local.workers_group_defaults["autoscaling_enabled"]) == 1 ? "enabled" : "disabled"  }", "value", "true", "propagate_at_launch", false),
      map("key", "k8s.io/cluster-autoscaler/${aws_eks_cluster.eks_cluster.name}", "value", "", "propagate_at_launch", false),
      map("key", "k8s.io/cluster-autoscaler/node-template/resources/ephemeral-storage", "value", "${lookup(var.worker_groups_launch_template_mixed[count.index], "root_volume_size", local.workers_group_defaults["root_volume_size"])}Gi", "propagate_at_launch", false)
    ),
    local.asg_tags,
    var.worker_group_tags[contains(keys(var.worker_group_tags), "${lookup(var.worker_groups_launch_template_mixed[count.index], "name", count.index)}") ? "${lookup(var.worker_groups_launch_template_mixed[count.index], "name", count.index)}" : "default"])
  }"]

  lifecycle {
    create_before_destroy = true
    ignore_changes        = ["desired_capacity"]
  }
}