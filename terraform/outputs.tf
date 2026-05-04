output "ecr_repository_url" {
  description = "ECR repository URL used by both EKS and ECS."
  value       = local.ecr_repository_url
}

output "eks_cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.main.name
}

output "eks_service_name" {
  description = "Kubernetes service name deployed to EKS by Argo CD."
  value       = "fintech-app"
}

output "eks_lb_dns_name" {
  description = "Run kubectl get svc fintech-app after Argo CD syncs to get the public EKS load balancer DNS."
  value       = "managed-by-argocd"
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

output "argocd_namespace" {
  description = "Namespace where Argo CD is installed."
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_application_name" {
  description = "Argo CD application that syncs the EKS workload."
  value       = "web-app"
}
