resource "aws_autoscaling_group" "worker_nodes_asg" {
  count             = length(var.worker_nodes_on_demand_groups)
  name_prefix       = join("-",[aws_eks_cluster.eks_cluster.name,count.index])
  max_size          = lookup(var.worker_nodes_on_demand_groups[count.index], "asg_max_size", local.worker_nodes_on_demand_groups_defaults["asg_max_size"])
  min_size          = lookup(var.worker_nodes_on_demand_groups[count.index], "asg_min_size", local.worker_nodes_on_demand_groups_defaults["asg_min_size"])
  desired_capacity  = lookup(var.worker_nodes_on_demand_groups[count.index], "asg_desired_capacity",local.worker_nodes_on_demand_groups_defaults["asg_desired_capacity"])

  force_delete      = lookup(var.worker_nodes_on_demand_groups[count.index], "asg_force_delete", local.worker_nodes_on_demand_groups_defaults["asg_force_delete"])
  //target_group_arns = ["${compact(split(",", coalesce(lookup(var.worker_groups_launch_template[count.index], "target_group_arns", ""), local.workers_group_launch_template_defaults["target_group_arns"])))}"]
  //target_group_arns = []


    launch_template {

        id = element(aws_launch_template.workers_launch_template.*.id, count.index)
        version            = "$Latest"
    }


  vpc_zone_identifier   =  var.private_subnets
  protect_from_scale_in = lookup(var.worker_nodes_on_demand_groups[count.index], "protect_from_scale_in", local.worker_nodes_on_demand_groups_defaults["protect_from_scale_in"])
  suspended_processes   = compact(split(",", coalesce(lookup(var.worker_nodes_on_demand_groups[count.index], "suspended_processes", ""), local.worker_nodes_on_demand_groups_defaults["suspended_processes"])))
  enabled_metrics       = compact(split(",", coalesce(lookup(var.worker_nodes_on_demand_groups[count.index], "enabled_metrics", ""), local.worker_nodes_on_demand_groups_defaults["enabled_metrics"])))


  lifecycle {
    create_before_destroy = true

    ignore_changes = ["desired_capacity"]
  }
}

resource "aws_autoscaling_group" "worker_nodes_asg_mixed" {
  count                   =  length(var.worker_nodes_mixed_groups)
  name_prefix             = join("-",[aws_eks_cluster.eks_cluster.name,count.index])
  desired_capacity        =  lookup(var.worker_nodes_mixed_groups[count.index], "asg_desired_capacity", local.worker_nodes_mixed_groups_defaults["asg_desired_capacity"])
  max_size                =  lookup(var.worker_nodes_mixed_groups[count.index], "asg_max_size", local.worker_nodes_mixed_groups_defaults["asg_max_size"])
  min_size                =  lookup(var.worker_nodes_mixed_groups[count.index], "asg_min_size", local.worker_nodes_mixed_groups_defaults["asg_min_size"])
  force_delete            =  lookup(var.worker_nodes_mixed_groups[count.index], "asg_force_delete", local.worker_nodes_mixed_groups_defaults["asg_force_delete"])
  target_group_arns       =  compact(split(",", coalesce(lookup(var.worker_nodes_mixed_groups[count.index], "target_group_arns", ""), local.worker_nodes_mixed_groups_defaults["target_group_arns"])))
  service_linked_role_arn =  lookup(var.worker_nodes_mixed_groups[count.index], "service_linked_role_arn", local.worker_nodes_mixed_groups_defaults["service_linked_role_arn"])
  vpc_zone_identifier     =  split(",", coalesce(lookup(var.worker_nodes_mixed_groups[count.index], "subnets", ""), local.worker_nodes_mixed_groups_defaults["subnets"]))
  protect_from_scale_in   =  lookup(var.worker_nodes_mixed_groups[count.index], "protect_from_scale_in", local.worker_nodes_mixed_groups_defaults["protect_from_scale_in"])
  suspended_processes     =  compact(split(",", coalesce(lookup(var.worker_nodes_mixed_groups[count.index], "suspended_processes", ""), local.worker_nodes_mixed_groups_defaults["suspended_processes"])))
  enabled_metrics         =  compact(split(",", coalesce(lookup(var.worker_nodes_mixed_groups[count.index], "enabled_metrics", ""), local.worker_nodes_mixed_groups_defaults["enabled_metrics"])))
  placement_group         =  lookup(var.worker_nodes_mixed_groups[count.index], "placement_group", local.worker_nodes_mixed_groups_defaults["placement_group"])

  mixed_instances_policy {
    instances_distribution {
      on_demand_allocation_strategy            = lookup(var.worker_nodes_mixed_groups[count.index], "on_demand_allocation_strategy", local.worker_nodes_mixed_groups_defaults["on_demand_allocation_strategy"])
      on_demand_base_capacity                  = lookup(var.worker_nodes_mixed_groups[count.index], "on_demand_base_capacity", local.worker_nodes_mixed_groups_defaults["on_demand_base_capacity"])
      on_demand_percentage_above_base_capacity = lookup(var.worker_nodes_mixed_groups[count.index], "on_demand_percentage_above_base_capacity", local.worker_nodes_mixed_groups_defaults["on_demand_percentage_above_base_capacity"])
      spot_allocation_strategy                 = lookup(var.worker_nodes_mixed_groups[count.index], "spot_allocation_strategy", local.worker_nodes_mixed_groups_defaults["spot_allocation_strategy"])
      spot_instance_pools                      = lookup(var.worker_nodes_mixed_groups[count.index], "spot_instance_pools", local.worker_nodes_mixed_groups_defaults["spot_instance_pools"])
      spot_max_price                           = lookup(var.worker_nodes_mixed_groups[count.index], "spot_max_price", local.worker_nodes_mixed_groups_defaults["spot_max_price"])
    }

    launch_template {
      launch_template_specification {
        launch_template_id = element(aws_launch_template.workers_launch_template_mixed.*.id, count.index)
        version            = lookup(var.worker_nodes_mixed_groups[count.index], "launch_template_version", local.worker_nodes_mixed_groups_defaults["launch_template_version"])
      }

      override {
        instance_type = lookup(var.worker_nodes_mixed_groups[count.index], "override_instance_type_1", local.worker_nodes_mixed_groups_defaults["override_instance_type_1"])
      }

      override {
        instance_type = lookup(var.worker_nodes_mixed_groups[count.index], "override_instance_type_2", local.worker_nodes_mixed_groups_defaults["override_instance_type_2"])
      }

      override {
        instance_type = lookup(var.worker_nodes_mixed_groups[count.index], "override_instance_type_3", local.worker_nodes_mixed_groups_defaults["override_instance_type_3"])
      }

      override {
        instance_type = lookup(var.worker_nodes_mixed_groups[count.index], "override_instance_type_4", local.worker_nodes_mixed_groups_defaults["override_instance_type_4"])
      }
    }
  }

  tags = ["${concat(
    list(
      map("key", "Name", "value", "${aws_eks_cluster.eks_cluster.name}-${lookup(var.worker_nodes_mixed_groups[count.index], "name", count.index)}-eks_asg", "propagate_at_launch", true),
      map("key", "kubernetes.io/cluster/${aws_eks_cluster.eks_cluster.name}", "value", "owned", "propagate_at_launch", true),
      map("key", "k8s.io/cluster-autoscaler/${lookup(var.worker_nodes_mixed_groups[count.index], "autoscaling_enabled", local.worker_nodes_group_defaults["autoscaling_enabled"]) == 1 ? "enabled" : "disabled"  }", "value", "true", "propagate_at_launch", false),
      map("key", "k8s.io/cluster-autoscaler/${aws_eks_cluster.eks_cluster.name}", "value", "", "propagate_at_launch", false),
      map("key", "k8s.io/cluster-autoscaler/node-template/resources/ephemeral-storage", "value", "${lookup(var.worker_nodes_on_demand_groups[count.index], "root_volume_size", local.worker_nodes_group_defaults["root_volume_size"])}Gi", "propagate_at_launch", false)
    ),
    local.asg_tags,
    var.worker_group_tags[contains(keys(var.worker_group_tags), "${lookup(var.worker_nodes_mixed_groups[count.index], "name", count.index)}") ? "${lookup(var.worker_nodes_mixed_groups[count.index], "name", count.index)}" : "default"])
  }"]

  lifecycle {
    create_before_destroy = true
    ignore_changes        = ["desired_capacity"]
  }
}