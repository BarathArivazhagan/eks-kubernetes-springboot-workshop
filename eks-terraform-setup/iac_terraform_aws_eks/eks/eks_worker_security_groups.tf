resource "aws_security_group" "workers_security_group" {
  count       = var.worker_create_security_group ? 1 : 0
  name_prefix = aws_eks_cluster.eks_cluster.name
  description = "Security group for all nodes in the cluster."
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, map("Name", "${aws_eks_cluster.eks_cluster.name}-eks_worker_sg", "kubernetes.io/cluster/${aws_eks_cluster.eks_cluster.name}", "owned"
  ))
}

resource "aws_security_group_rule" "workers_sg_egress_internet" {
  count             = var.worker_create_security_group ? 1 : 0
  description       = "Allow nodes all egress to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.workers_security_group[count.index].id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"

}

resource "aws_security_group_rule" "workers_sg_ingress_self" {
  count                    = var.worker_create_security_group ? 1 : 0
  description              = "Allow node to communicate with each other."
  protocol                 = "-1"
  security_group_id        = aws_security_group.workers_security_group[count.index].id
  source_security_group_id = aws_security_group.workers_security_group[count.index].id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"

}

resource "aws_security_group_rule" "workers_sg_ingress_cluster" {
  count                    = var.worker_create_security_group ? 1 : 0
  description              = "Allow workers Kubelets and pods to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers_security_group[count.index].id
  source_security_group_id = local.cluster_security_group_id
  from_port                = var.worker_sg_ingress_from_port
  to_port                  = 65535
  type                     = "ingress"

}

resource "aws_security_group_rule" "workers_sg_ingress_cluster_https" {
  count                    = var.worker_create_security_group ? 1 : 0
  description              = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers_security_group[count.index].id
  source_security_group_id = local.cluster_security_group_id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"

}
