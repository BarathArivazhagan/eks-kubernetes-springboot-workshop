output "cluster_id" {
  description = "The name/id of the EKS cluster."
  value       = aws_eks_cluster.eks_cluster.id
}


output "cluster_certificate_authority_data" {
  description = "Nested attribute containing certificate-authority-data for your cluster. eks_cluster is the base64 encoded certificate data required to communicate with your cluster."
  value       = aws_eks_cluster.eks_cluster.certificate_authority.0.data
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = aws_eks_cluster.eks_cluster.version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster."
  value       = local.cluster_security_group_id
}

output "config_map_aws_auth" {
  description = "A kubernetes configuration to authenticate to eks_cluster EKS cluster."
  value       = data.template_file.config_map_aws_auth.rendered
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster."
  value       = aws_iam_role.eks_cluster_role.*.name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = aws_iam_role.eks_cluster_role.*.arn
}

output "kubeconfig" {
  description = "kubectl config file contents for eks_cluster EKS cluster."
  value       = data.template_file.kubeconfig.rendered
}

output "kubeconfig_filename" {
  description = "The filename of the generated kubectl config."
  value       = element(concat(local_file.kubeconfig.*.filename, list("")), 0)
}

output "workers_asg_arns" {
  description = "IDs of the autoscaling groups containing workers."
  value       = concat(aws_autoscaling_group.worker_nodes_asg.*.arn, aws_autoscaling_group.worker_nodes_asg_mixed.*.arn)
}

output "workers_asg_names" {
  description = "Names of the autoscaling groups containing workers."
  value       = concat(aws_autoscaling_group.worker_nodes_asg.*.id, aws_autoscaling_group.worker_nodes_asg_mixed.*.id)
}

output "worker_security_group_id" {
  description = "Security group ID attached to the EKS workers."
  value       = local.worker_security_group_id
}

output "worker_iam_role_name" {
  description = "default IAM role name for EKS worker groups"
  value       = aws_iam_role.workers.name
}

output "worker_iam_role_arn" {
  description = "default IAM role ARN for EKS worker groups"
  value       = aws_iam_role.workers.arn
}

output "eks_bastion_host" {
  value = var.bastion ? aws_instance.eks_bastion[0].private_ip : ""
}

