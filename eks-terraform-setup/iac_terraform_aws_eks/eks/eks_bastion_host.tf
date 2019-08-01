

resource "aws_instance" "eks_bastion" {
  count = var.bastion ? 1 : 0
  ami = var.bastion_ami_id
  instance_type = var.bastion_instance_type
  user_data = file("${path.module}/artifacts/eks_bastion_user_data")
  subnet_id = var.public_subnets[0]
  security_groups = [aws_security_group.eks_bastion_sg.id]
  iam_instance_profile = var.bastion_instance_role
  tags = {
    Name = join("-",[var.cluster_name,"eks-bastion"])
  }
}

resource "aws_security_group" "eks_bastion_sg" {
  count = var.bastion ? 1 : 0
  name = join("-",[var.cluster_name,"eks-bastion-sg"])
  description = join("-",[var.cluster_name,"eks-bastion-sg"])
  vpc_id = var.vpc_id

}

resource "aws_security_group_rule" "eks_bastion_sg_ingress" {
  count = var.bastion ? 1 : 0
  from_port = 22
  protocol = "TCP"
  security_group_id = aws_security_group.eks_bastion_sg[count.index].id
  to_port = 22
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "eks_bastion_sg_egress" {
  count = var.bastion ? 1 : 0
  from_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.eks_bastion_sg[count.index].id
  to_port = 0
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}