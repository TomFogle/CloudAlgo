resource "aws_vpc" "ghost" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
     "Name", "terraform-eks-ghost-node",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "ghost" {
  count = 2
  vpc_id            = "${aws_vpc.ghost.id}"
  cidr_block        = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  tags = "${
    map(
     "Name", "terraform-eks-ghost-node",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "ghost" {
  vpc_id = "${aws_vpc.ghost.id}"

  tags = {
    Name = "terraform-eks-ghost"
  }
}

resource "aws_route_table" "ghost" {
  vpc_id = "${aws_vpc.ghost.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ghost.id}"
  }
}

resource "aws_route_table_association" "ghost" {
  count = 2

  subnet_id      = "${aws_subnet.ghost.*.id[count.index]}"
  route_table_id = "${aws_route_table.ghost.id}"
}