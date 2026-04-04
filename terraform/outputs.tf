output "eks_cluster_role_urn" {
  value = aws_iam_role.ascendoai-eks-role.arn
}

output "eks_node_role_arn" {
  value = aws_iam_role.ascendoai-node-role.arn

}

output "iam_user_name" {
  value = aws_iam_user.ascendoai.name

}

output "cluster_name" {
  value = aws_eks_cluster.eks.name

}


output "vpc_id" {
  value = aws_vpc.ascendoai_vpc.id

}

output "node_group_name" {
  value = aws_eks_node_group.eks_nodes.node_group_name

}