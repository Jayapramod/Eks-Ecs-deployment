output "ecr_repository_url" {
  description = "ECR repository URL used by both EKS and ECS."
  value       = local.ecr_repository_url
}

output "eks_cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.main.name
}

output "eks_service_name" {
  description = "Kubernetes service name deployed to EKS."
  value       = kubernetes_service.app.metadata[0].name
}

output "eks_lb_dns_name" {
  description = "Public DNS name for the EKS internet-facing service load balancer. It may show pending during the first apply while AWS creates the load balancer."
  value       = try(kubernetes_service.app.status[0].load_balancer[0].ingress[0].hostname, "pending")
}

output "ecs_cluster_name" {
  description = "ECS cluster name."
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS service name."
  value       = aws_ecs_service.app.name
}

output "ecs_alb_dns_name" {
  description = "Public DNS name for ECS ALB."
  value       = aws_lb.ecs.dns_name
}

output "cloudwatch_dashboard_name" {
  description = "CloudWatch dashboard for ECS and EKS monitoring."
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}
