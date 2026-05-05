output "ecr_repository_url" {
  value = local.ecr_repository_url
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_service_name" {
  value = "fintech-app"
}

output "eks_lb_dns_name" {
  value = "managed-by-argocd"
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "ecs_service_name" {
  value = module.ecs.service_name
}

output "ecs_alb_dns_name" {
  value = module.ecs.alb_dns_name
}

output "cloudwatch_dashboard_name" {
  value = module.monitoring.dashboard_name
}

output "rds_endpoint" {
  value = module.rds.address
}

output "rds_secret_arn" {
  value = module.rds.secret_arn
}

output "argocd_namespace" {
  value = module.argocd.namespace
}

output "argocd_application_name" {
  value = module.argocd.application_name
}
