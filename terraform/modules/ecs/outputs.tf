output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "service_name" {
  value = aws_ecs_service.app.name
}

output "alb_dns_name" {
  value = aws_lb.ecs.dns_name
}

output "alb_arn_suffix" {
  value = aws_lb.ecs.arn_suffix
}

output "target_group_arn_suffix" {
  value = aws_lb_target_group.ecs.arn_suffix
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.ecs.name
}
