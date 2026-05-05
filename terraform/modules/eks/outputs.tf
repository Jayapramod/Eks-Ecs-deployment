output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_ca_data" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}

output "node_group_id" {
  value = aws_eks_node_group.main.id
}

output "node_asg_name" {
  value = aws_eks_node_group.main.resources[0].autoscaling_groups[0].name
}

output "cluster_log_group_name" {
  value = aws_cloudwatch_log_group.cluster.name
}
