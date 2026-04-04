resource "aws_eks_cluster" "eks" {
  name     = var.eks_cluster
  role_arn = aws_iam_role.ascendoai-eks-role.arn

  vpc_config {
    subnet_ids         = aws_subnet.ascendoai_private_subnet[*].id
    security_group_ids = [aws_security_group.eks_sg.id]


    endpoint_private_access = true
    endpoint_public_access  = false
  }
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [aws_iam_role_policy_attachment.ascendoai_eks_cluster_policy]
}