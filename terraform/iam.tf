resource "aws_iam_user" "ascendoai" {
  name = "ascendo-ai-user"
  tags = {
    Environment = "assesment"
    owner       = "raviteja"
  }
}



resource "aws_iam_policy" "ascendoai_policy" {
  name = "ascendoai-assessment-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:*",
          "ec2:*",
          "iam:*",
          "ssm:*",
          "logs:*",
          "s3:*",
          "dynamodb:*"
        ]
        Resource = "*"
      }
    ]
  })


}



resource "aws_iam_user_policy_attachment" "ascendoai-attach-policy" {
  user       = aws_iam_user.ascendoai.name
  policy_arn = aws_iam_policy.ascendoai_policy.arn

}



resource "aws_iam_role" "ascendoai-eks-role" {
  name = "ascendoai-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

}


resource "aws_iam_role_policy_attachment" "ascendoai_eks_cluster_policy" {
  role       = aws_iam_role.ascendoai-eks-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"


}



resource "aws_iam_role" "ascendoai-node-role" {
  name = "ascendoai-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })


}


resource "aws_iam_role_policy_attachment" "ascendoai-worker_node_policy" {
  role       = aws_iam_role.ascendoai-node-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "ascendoai-cni_policy" {
  role       = aws_iam_role.ascendoai-node-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.ascendoai-node-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}



resource "aws_iam_role_policy_attachment" "ascendoai-ssm_access" {
  role       = aws_iam_role.ascendoai-node-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}



