data "aws_region" "current" {}

data "aws_iam_policy_document" "workers_assume_role_policy" {
  statement {
    sid = "EKSWorkerAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_ami" "eks_worker" {
  filter {
    name   = "name"
    values = [join("-",["amazon-eks-node",var.cluster_version,var.worker_ami_name_filter])]
  }

  most_recent = true

  # Owner ID of AWS EKS team
  owners = ["602401143452"]
}

data "aws_iam_policy_document" "cluster_assume_role_policy" {
  statement {
    sid = "EKSClusterAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "template_file" "aws_authenticator_env_variables" {
  count = length(var.kubeconfig_aws_authenticator_env_variables)

  template = <<EOF
        - name: $${key}
          value: $${value}
EOF

  vars = {
    value = element(values(var.kubeconfig_aws_authenticator_env_variables), count.index)
    key   = element(keys(var.kubeconfig_aws_authenticator_env_variables), count.index)
  }
}

data "template_file" "kubeconfig" {
  template = file("${path.module}/templates/kubeconfig.tpl")

  vars = {
    kubeconfig_name                   =  local.kubeconfig_name
    endpoint                          =  aws_eks_cluster.eks_cluster.endpoint
    region                            =  var.aws_region
    cluster_auth_base64               =  aws_eks_cluster.eks_cluster.certificate_authority.0.data
    aws_authenticator_command         =  var.kubeconfig_aws_authenticator_command
    aws_authenticator_command_args    =  length(var.kubeconfig_aws_authenticator_command_args) > 0 ? "        - ${join("\n        - ", var.kubeconfig_aws_authenticator_command_args)}" : "        - ${join("\n        - ", formatlist("\"%s\"", list("token", "-i", aws_eks_cluster.eks_cluster.name)))}"
    aws_authenticator_additional_args = length(var.kubeconfig_aws_authenticator_additional_args) > 0 ? "        - ${join("\n        - ", var.kubeconfig_aws_authenticator_additional_args)}" : ""
    aws_authenticator_env_variables   = length(var.kubeconfig_aws_authenticator_env_variables) > 0 ? "      env:\n${join("\n", data.template_file.aws_authenticator_env_variables.*.rendered)}" : ""
  }
}



data "template_file" "launch_template_userdata" {
  count    =  length(var.worker_nodes_on_demand_groups)
  template = file("${path.module}/templates/userdata.sh.tpl")

  vars = {
    cluster_name         = aws_eks_cluster.eks_cluster.name
    endpoint             = aws_eks_cluster.eks_cluster.endpoint
    cluster_auth_base64  = aws_eks_cluster.eks_cluster.certificate_authority.0.data
    pre_userdata         = lookup(var.worker_nodes_on_demand_groups[count.index], "pre_userdata", local.worker_nodes_on_demand_groups_defaults["pre_userdata"])
    additional_userdata  = lookup(var.worker_nodes_on_demand_groups[count.index], "additional_userdata", local.worker_nodes_on_demand_groups_defaults["additional_userdata"])
    bootstrap_extra_args = lookup(var.worker_nodes_on_demand_groups[count.index], "bootstrap_extra_args", local.worker_nodes_on_demand_groups_defaults["bootstrap_extra_args"])
    kubelet_extra_args   = lookup(var.worker_nodes_on_demand_groups[count.index], "kubelet_extra_args", local.worker_nodes_on_demand_groups_defaults["kubelet_extra_args"])
    enable_docker_bridge = lookup(var.worker_nodes_on_demand_groups[count.index], "enable_docker_bridge", local.worker_nodes_on_demand_groups_defaults["enable_docker_bridge"])
  }
}

data "template_file" "launch_template_userdata_mixed" {
  count    = length(var.worker_nodes_mixed_groups)
  template = file("${path.module}/templates/userdata.sh.tpl")

  vars = {
    cluster_name         = aws_eks_cluster.eks_cluster.name
    endpoint             = aws_eks_cluster.eks_cluster.endpoint
    cluster_auth_base64  = aws_eks_cluster.eks_cluster.certificate_authority.0.data
    pre_userdata         = lookup(var.worker_nodes_mixed_groups[count.index], "pre_userdata", local.worker_nodes_mixed_groups_defaults["pre_userdata"])
    additional_userdata  = lookup(var.worker_nodes_mixed_groups[count.index], "additional_userdata", local.worker_nodes_mixed_groups_defaults["additional_userdata"])
    bootstrap_extra_args = lookup(var.worker_nodes_mixed_groups[count.index], "bootstrap_extra_args", local.worker_nodes_mixed_groups_defaults["bootstrap_extra_args"])
    kubelet_extra_args   = lookup(var.worker_nodes_mixed_groups[count.index], "kubelet_extra_args", local.worker_nodes_mixed_groups_defaults["kubelet_extra_args"])
    enable_docker_bridge = lookup(var.worker_nodes_mixed_groups[count.index], "enable_docker_bridge", local.worker_nodes_mixed_groups_defaults["enable_docker_bridge"])
  }
}

data "template_file" "workers_launch_template_mixed" {
  count    = length(var.worker_nodes_mixed_groups)
  template = file("${path.module}/templates/userdata.sh.tpl")

  vars = {
    cluster_name         = aws_eks_cluster.eks_cluster.name
    endpoint             = aws_eks_cluster.eks_cluster.endpoint
    cluster_auth_base64  = aws_eks_cluster.eks_cluster.certificate_authority.0.data
    pre_userdata         = lookup(var.worker_nodes_mixed_groups[count.index], "pre_userdata", local.worker_nodes_mixed_groups_defaults["pre_userdata"])
    additional_userdata  = lookup(var.worker_nodes_mixed_groups[count.index], "additional_userdata", local.worker_nodes_mixed_groups_defaults["additional_userdata"])
    bootstrap_extra_args = lookup(var.worker_nodes_mixed_groups[count.index], "bootstrap_extra_args", local.worker_nodes_mixed_groups_defaults["bootstrap_extra_args"])
    kubelet_extra_args   = lookup(var.worker_nodes_mixed_groups[count.index], "kubelet_extra_args", local.worker_nodes_mixed_groups_defaults["kubelet_extra_args"])
  }
}

data "aws_iam_role" "custom_cluster_iam_role" {
  count = var.manage_cluster_iam_resources ? 0 : 1
  name  = var.cluster_iam_role_name
}

data "aws_iam_instance_profile" "custom_worker_group_iam_instance_profile" {
  count = var.manage_worker_iam_resources ? 0 : length(var.worker_nodes_on_demand_groups)
  name  = lookup(var.worker_nodes_on_demand_groups[count.index], "iam_instance_profile_name", local.worker_nodes_on_demand_groups_defaults["iam_instance_profile_name"])
}

data "aws_iam_instance_profile" "custom_worker_group_launch_template_iam_instance_profile" {
  count = var.manage_worker_iam_resources ? 0 : length(var.worker_nodes_mixed_groups)
  name  = lookup(var.worker_nodes_on_demand_groups[count.index], "iam_instance_profile_name", local.worker_nodes_on_demand_groups_defaults["iam_instance_profile_name"])
}

data "aws_iam_instance_profile" "custom_worker_group_launch_template_mixed_iam_instance_profile" {
  count = var.manage_worker_iam_resources ? 0 : length(var.worker_nodes_mixed_groups)
  name  = lookup(var.worker_nodes_mixed_groups[count.index], "iam_instance_profile_name", local.worker_nodes_mixed_groups_defaults["iam_instance_profile_name"])
}
