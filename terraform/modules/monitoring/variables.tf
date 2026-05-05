variable "name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_service_name" {
  type = string
}

variable "ecs_alb_suffix" {
  type = string
}

variable "ecs_target_group_suffix" {
  type = string
}

variable "ecs_log_group_name" {
  type = string
}

variable "eks_node_asg_name" {
  type = string
}

variable "eks_min_nodes" {
  type = number
}

variable "eks_log_group_name" {
  type = string
}

variable "alarm_actions" {
  type = list(string)
}

variable "common_tags" {
  type = map(string)
}
