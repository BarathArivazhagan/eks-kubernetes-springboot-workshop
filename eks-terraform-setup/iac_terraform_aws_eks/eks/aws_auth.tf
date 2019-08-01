resource "local_file" "config_map_aws_auth" {
  count    = var.write_aws_auth_config ? 1 : 0
  content  = data.template_file.config_map_aws_auth.rendered
  filename = "${var.config_output_path}config-map-aws-auth-${var.cluster_name}.yaml"
}

resource "null_resource" "update_config_map_aws_auth" {
  count      = var.manage_aws_auth ? 1 : 0
  depends_on = ["aws_eks_cluster.eks_cluster"]

  provisioner "local-exec" {
    working_dir = path.module

    command = <<EOS
for i in `seq 1 10`; do \
echo "${null_resource.update_config_map_aws_auth[count.index].triggers.kube_config_map_rendered}" > kube_config.yaml & \
echo "${null_resource.update_config_map_aws_auth[count.index].triggers.config_map_rendered}" > aws_auth_configmap.yaml & \
kubectl apply -f aws_auth_configmap.yaml --kubeconfig kube_config.yaml && break || \
sleep 10; \
done; \
rm aws_auth_configmap.yaml kube_config.yaml;
EOS

    interpreter = var.local_exec_interpreter
  }

  triggers = {
    kube_config_map_rendered = data.template_file.kubeconfig.rendered
    config_map_rendered      = data.template_file.config_map_aws_auth.rendered
    endpoint                 = aws_eks_cluster.eks_cluster.endpoint
  }
}

data "aws_caller_identity" "current" {}

data "template_file" "launch_template_mixed_worker_role_arns" {
  count    = length(var.worker_nodes_mixed_groups)
  template = file("${path.module}/templates/worker-role.tpl")

  vars  = {
    worker_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${element(coalescelist(aws_iam_instance_profile.worker_nodes_instance_profile.*.role, data.aws_iam_instance_profile.custom_worker_group_launch_template_mixed_iam_instance_profile.*.role_name), count.index)}"
  }
}

data "template_file" "launch_template_worker_role_arns" {
  count    = length(var.worker_nodes_on_demand_groups)
  template = "${file("${path.module}/templates/worker-role.tpl")}"

  vars = {
    worker_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${element(coalescelist(aws_iam_instance_profile.worker_nodes_instance_profile.*.role, data.aws_iam_instance_profile.custom_worker_group_launch_template_iam_instance_profile.*.role_name), count.index)}"
  }
}

data "template_file" "worker_role_arns" {

  count    =  length(var.worker_nodes_on_demand_groups)
  template =  "${file("${path.module}/templates/worker-role.tpl")}"

  vars = {
    worker_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${element(coalescelist(aws_iam_instance_profile.workers.*.role, data.aws_iam_instance_profile.custom_worker_group_iam_instance_profile.*.role_name), count.index)}"
  }
}

data "template_file" "config_map_aws_auth" {
  template = "${file("${path.module}/templates/config-map-aws-auth.yaml.tpl")}"

  vars = {
    worker_role_arn = join("", distinct(concat(data.template_file.launch_template_worker_role_arns.*.rendered, data.template_file.worker_role_arns.*.rendered, data.template_file.launch_template_mixed_worker_role_arns.*.rendered)))
    map_users       = join("", data.template_file.map_users.*.rendered)
    map_roles       = join("", data.template_file.map_roles.*.rendered)
    map_accounts    = join("", data.template_file.map_accounts.*.rendered)
  }
}

data "template_file" "map_users" {
  count    = var.map_users_count
  template = "${file("${path.module}/templates/config-map-aws-auth-map-users.yaml.tpl")}"

  vars = {
    user_arn = lookup(var.map_users[count.index], "user_arn")
    username = lookup(var.map_users[count.index], "username")
    group    = lookup(var.map_users[count.index], "group")
  }
}

data "template_file" "map_roles" {
  count    = var.map_roles_count
  template = "${file("${path.module}/templates/config-map-aws-auth-map-roles.yaml.tpl")}"

  vars = {
    role_arn = lookup(var.map_roles[count.index], "role_arn")
    username = lookup(var.map_roles[count.index], "username")
    group    = lookup(var.map_roles[count.index], "group")
  }
}

data "template_file" "map_accounts" {
  count    = var.map_accounts_count
  template = file("${path.module}/templates/config-map-aws-auth-map-accounts.yaml.tpl")

  vars = {
    account_number = element(var.map_accounts, count.index)
  }
}
