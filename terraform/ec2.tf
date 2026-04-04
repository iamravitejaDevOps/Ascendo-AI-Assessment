resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"
  vpc_id = aws_vpc.ascendoai_vpc.id


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ssm_role" {
  name = "ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm-profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_iam_role_policy_attachment" "attachments" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  ])
  role       = aws_iam_role.ssm_role.name
  policy_arn = each.value
}





resource "aws_instance" "bastion" {
  ami                         = "ami-0ec10929233384c7f"
  availability_zone           = var.az[0]
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.ascendoai_private_subnet[0].id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name = "bastion-host"
  }

  lifecycle {
    create_before_destroy = true
  }
}




resource "aws_eks_access_entry" "bastion_access" {
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = aws_iam_role.ssm_role.arn
  type          = "STANDARD"
}


resource "aws_eks_access_policy_association" "bastion_admin" {
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = aws_iam_role.ssm_role.arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}