region          = "us-east-1"
vpc_cidr        = "10.0.0.0/16"
vpc_name        = "ascendo-ai-vpc"
az              = ["us-east-1a", "us-east-1b"]
private_cidr    = ["10.0.1.0/24", "10.0.2.0/24"]
public_cidr     = ["10.0.3.0/24", "10.0.4.0/24"]
eks_cluster     = "ascendo_ai_eks_cluster"
node_group_name = "ascendo_ai_nodes"
