resource "aws_iam_role" "ghost-node" {
  name = "terraform-eks-ghost-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "ghost-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.ghost-node.name}"
}

resource "aws_iam_role_policy_attachment" "ghost-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.ghost-node.name}"
}

resource "aws_iam_role_policy_attachment" "ghost-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.ghost-node.name}"
}

resource "aws_iam_instance_profile" "ghost-node" {
  name = "terraform-eks-ghost"
  role = "${aws_iam_role.ghost-node.name}"
}

resource "aws_security_group" "ghost-node" {
  name        = "terraform-eks-ghost-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${aws_vpc.ghost.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "terraform-eks-ghost-node",
     "kubernetes.io/cluster/${var.cluster-name}", "owned",
    )
  }"
}

resource "aws_security_group_rule" "ghost-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.ghost-node.id}"
  source_security_group_id = "${aws_security_group.ghost-node.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "ghost-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.ghost-node.id}"
  source_security_group_id = "${aws_security_group.ghost-cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.ghost.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

# This data source is included for ease of sample architecture deployment
# and can be swapped out as necessary.
data "aws_region" "current" {}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We implement a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  ghost-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.ghost.endpoint}' --b64-cluster-ca '${aws_eks_cluster.ghost.certificate_authority.0.data}' '${var.cluster-name}'
USERDATA
}

resource "aws_launch_configuration" "ghost" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.ghost-node.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "m4.large"
  name_prefix                 = "terraform-eks-ghost"
  security_groups             = ["${aws_security_group.ghost-node.id}"]
  user_data_base64            = "${base64encode(local.ghost-node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ghost" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.ghost.id}"
  max_size             = 2
  min_size             = 1
  name                 = "terraform-eks-ghost"
  vpc_zone_identifier  = ["${aws_subnet.ghost.*.id}"]

  tag {
    key                 = "Name"
    value               = "terraform-eks-ghost"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }
}


