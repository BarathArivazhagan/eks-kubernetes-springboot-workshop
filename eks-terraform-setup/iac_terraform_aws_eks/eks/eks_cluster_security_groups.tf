resource "aws_security_group" "cluster_security_group" {
  count       =  var.cluster_create_security_group ? 1 : 0
  name_prefix =  var.cluster_name
  description = "EKS cluster security group."
  vpc_id      =  var.vpc_id
  tags        =  merge(var.tags, map("Name", "${var.cluster_name}-eks-cluster-sg"))
}

resource "aws_security_group_rule" "cluster_egress_internet" {
  count             = var.cluster_create_security_group ? 1 : 0
  description       = "Allow cluster egress access to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.cluster_security_group[count.index].id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "cluster_https_worker_ingress" {
  count                    =  var.cluster_create_security_group ? 1 : 0
  description              = "Allow pods to communicate with the EKS cluster API."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster_security_group[count.index].id
  source_security_group_id = local.worker_security_group_id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

