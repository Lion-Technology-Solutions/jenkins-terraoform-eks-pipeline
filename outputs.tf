output "aws_region" {
  description = "AWS region containing the EKS cluster."
  value       = local.aws_region
}

output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "EKS Kubernetes API endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_version" {
  description = "EKS Kubernetes control-plane version."
  value       = aws_eks_cluster.this.version
}

output "node_group_name" {
  description = "EKS managed node-group name."
  value       = aws_eks_node_group.this.node_group_name
}

output "vpc_id" {
  description = "VPC ID created for EKS."
  value       = aws_vpc.eks.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs used by the EKS cluster and worker nodes."
  value       = aws_subnet.private[*].id
}

output "configure_kubectl" {
  description = "Command that configures kubectl for the cluster."
  value       = "aws eks update-kubeconfig --region us-east-1 --name ${aws_eks_cluster.this.name}"
}

