resource "aws_vpc" "ascendoai_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "${var.vpc_name}"
  }

}

resource "aws_subnet" "ascendoai_public_subnet" {
  count                   = length(var.public_cidr)
  vpc_id                  = aws_vpc.ascendoai_vpc.id
  cidr_block              = element(var.public_cidr, count.index)
  availability_zone       = element(var.az, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }

}

resource "aws_internet_gateway" "ascendoai_igw" {
  vpc_id = aws_vpc.ascendoai_vpc.id

}

resource "aws_subnet" "ascendoai_private_subnet" {
  count             = length(var.private_cidr)
  vpc_id            = aws_vpc.ascendoai_vpc.id
  cidr_block        = element(var.private_cidr, count.index)
  availability_zone = element(var.az, count.index)

  tags = {
    Name  = "private-subnet-${count.index + 1}"
    owner = "raviteja"

    "kubernetes.io/cluster/${var.eks_cluster}" = "owned"
    "kubernetes.io/role/internal-elb"          = "1"

  }

}
resource "aws_vpc_endpoint" "ssm" {
  vpc_id             = aws_vpc.ascendoai_vpc.id
  service_name       = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.ascendoai_private_subnet[*].id
  security_group_ids = [aws_security_group.eks_sg.id]
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id             = aws_vpc.ascendoai_vpc.id
  service_name       = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.ascendoai_private_subnet[*].id
  security_group_ids = [aws_security_group.eks_sg.id]
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id             = aws_vpc.ascendoai_vpc.id
  service_name       = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.ascendoai_private_subnet[*].id
  security_group_ids = [aws_security_group.eks_sg.id]
}



resource "aws_route_table" "ascendoai_rt_public" {
  vpc_id = aws_vpc.ascendoai_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ascendoai_igw.id
  }

}





resource "aws_route_table_association" "ascendoai_rta_public" {
  count          = length(var.public_cidr)
  subnet_id      = element(aws_subnet.ascendoai_public_subnet.*.id, count.index)
  route_table_id = aws_route_table.ascendoai_rt_public.id

}

resource "aws_eip" "nat" {
  domain = "vpc"


}

resource "aws_nat_gateway" "ascendoai_nat" {
  allocation_id = aws_eip.nat.id

  subnet_id = aws_subnet.ascendoai_public_subnet[0].id

  tags = {
    Name = "nat-gw"
  }
  depends_on = [aws_internet_gateway.ascendoai_igw]

}





resource "aws_route_table" "ascendoai_rt_private" {
  count  = length(var.private_cidr)
  vpc_id = aws_vpc.ascendoai_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.ascendoai_nat.*.id, count.index)
  }

  tags = {
    name = "${var.vpc_name}-privateRt"
  }

}



resource "aws_route_table_association" "ascendoai_rta_private" {
  count          = length(var.private_cidr)
  subnet_id      = element(aws_subnet.ascendoai_private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.ascendoai_rt_private.*.id, count.index)
}




resource "aws_security_group" "eks_sg" {
  name   = "eks-private-sg"
  vpc_id = aws_vpc.ascendoai_vpc.id

  ingress {
    description     = "Allow Bastion to EKS API"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "HTTPS to VPC endpoints and AWS APIs"
  }
  egress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Kubelet API (node-to-node)"
  }

}


resource "aws_security_group_rule" "allow_nodeport" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = aws_security_group.eks_sg.id
}