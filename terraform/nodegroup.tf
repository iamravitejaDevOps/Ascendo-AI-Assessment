resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = var.eks_cluster
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.ascendoai-node-role.arn
  subnet_ids      = aws_subnet.ascendoai_private_subnet[*].id

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 1
  }


  capacity_type = "ON_DEMAND"
  disk_size     = 20
  version       = "1.33"


  instance_types = ["t3.small"]

  depends_on = [
    aws_iam_role_policy_attachment.ascendoai-worker_node_policy,
    aws_iam_role_policy_attachment.ascendoai-cni_policy,
    aws_iam_role_policy_attachment.ecr_read,
    aws_eks_cluster.eks

  ]
}