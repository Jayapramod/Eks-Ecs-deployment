resource "aws_cloudwatch_metric_alarm" "ecs_high_cpu" {
  alarm_name          = "${var.name}-ecs-high-cpu"
  alarm_description   = "ECS service CPU utilization is above 80 percent."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.alarm_actions

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "ecs_high_memory" {
  alarm_name          = "${var.name}-ecs-high-memory"
  alarm_description   = "ECS service memory utilization is above 80 percent."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.alarm_actions

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "ecs_unhealthy_targets" {
  alarm_name          = "${var.name}-ecs-unhealthy-targets"
  alarm_description   = "ECS ALB has unhealthy targets."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.alarm_actions

  dimensions = {
    LoadBalancer = var.ecs_alb_suffix
    TargetGroup  = var.ecs_target_group_suffix
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "eks_node_group_capacity" {
  alarm_name          = "${var.name}-eks-nodegroup-low-capacity"
  alarm_description   = "EKS node group has fewer in-service instances than expected."
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  metric_name         = "GroupInServiceInstances"
  namespace           = "AWS/AutoScaling"
  period              = 300
  statistic           = "Average"
  threshold           = var.eks_min_nodes
  treat_missing_data  = "breaching"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.alarm_actions

  dimensions = {
    AutoScalingGroupName = var.eks_node_asg_name
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.name}-ops"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 2
        properties = {
          markdown = "# ${var.name} operations\nECS logs: ${var.ecs_log_group_name}\nEKS control-plane logs: ${var.eks_log_group_name}"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 2
        width  = 12
        height = 6
        properties = {
          region = var.aws_region
          title  = "ECS CPU and Memory"
          view   = "timeSeries"
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_name],
            [".", "MemoryUtilization", ".", ".", ".", "."]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 2
        width  = 12
        height = 6
        properties = {
          region = var.aws_region
          title  = "ECS ALB Target Health"
          view   = "timeSeries"
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "LoadBalancer", var.ecs_alb_suffix, "TargetGroup", var.ecs_target_group_suffix],
            [".", "UnHealthyHostCount", ".", ".", ".", "."]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 8
        width  = 12
        height = 6
        properties = {
          region = var.aws_region
          title  = "EKS Node Group Capacity"
          view   = "timeSeries"
          metrics = [
            ["AWS/AutoScaling", "GroupDesiredCapacity", "AutoScalingGroupName", var.eks_node_asg_name],
            [".", "GroupInServiceInstances", ".", "."]
          ]
        }
      }
    ]
  })
}
