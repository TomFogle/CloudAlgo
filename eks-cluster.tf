resource "aws_iam_role" "ghost-cluster" {
  name = "terraform-eks-ghost-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "ghost-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.ghost-cluster.name}"
}

resource "aws_iam_role_policy_attachment" "ghost-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.ghost-cluster.name}"
}

resource "aws_security_group" "ghost-cluster" {
  name        = "terraform-eks-ghost-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.ghost.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-ghost"
  }
}

resource "aws_eks_cluster" "ghost" {
  name            = "${var.cluster-name}"
  role_arn        = "${aws_iam_role.ghost-cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.ghost-cluster.id}"]
    subnet_ids         = ["${aws_subnet.ghost.*.id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.ghost-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.ghost-cluster-AmazonEKSServicePolicy",
  ]
}

resource "aws_security_group_rule" "ghost-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.ghost-cluster.id}"
  source_security_group_id = "${aws_security_group.ghost-node.id}"
  to_port                  = 443
  type                     = "ingress"
}

# OPTIONAL: Allow inbound traffic from your local workstation external IP
#           to the Kubernetes. You will need to replace A.B.C.D below with
#           your real IP. Services like icanhazip.com can help you find this.
# resource "aws_security_group_rule" "ghost-cluster-ingress-workstation-https" {
#   cidr_blocks       = ["A.B.C.D/32"]
#   description       = "Allow workstation to communicate with the cluster API Server"
#   from_port         = 443
#   protocol          = "tcp"
#   security_group_id = "${aws_security_group.ghost-cluster.id}"
#   to_port           = 443
#   type              = "ingress"
# }

