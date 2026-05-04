variable "aws_region" {
  description = "AWS region for this environment."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name prefix used for AWS resources."
  type        = string
  default     = "fintech-app"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}

variable "ecr_repository_name" {
  description = "Exact ECR repository name."
  type        = string
  default     = null
}

variable "eks_cluster_name" {
  description = "Exact EKS cluster name."
  type        = string
  default     = null
}

variable "ecs_cluster_name" {
  description = "Exact ECS cluster name."
  type        = string
  default     = null
}

variable "image_tag" {
  description = "ECR image tag to deploy to EKS and ECS."
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "Application container port."
  type        = number
  default     = 3000
}

variable "public_ingress_cidrs" {
  description = "CIDR ranges allowed to access public application load balancers."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "eks_public_access_cidrs" {
  description = "CIDR ranges allowed to access the public EKS API endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "eks_node_instance_types" {
  description = "Instance types for the EKS managed node group."
  type        = list(string)
  default     = ["t3.small"]
}

variable "eks_desired_nodes" {
  description = "Desired number of EKS worker nodes."
  type        = number
  default     = 1
}

variable "eks_min_nodes" {
  description = "Minimum number of EKS worker nodes."
  type        = number
  default     = 1
}

variable "eks_max_nodes" {
  description = "Maximum number of EKS worker nodes."
  type        = number
  default     = 2
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 14
}

variable "alarm_actions" {
  description = "SNS topic ARNs or other CloudWatch alarm actions. Leave empty to create alarms without notifications."
  type        = list(string)
  default     = []
}

variable "ecs_desired_count" {
  description = "Desired number of ECS Fargate tasks."
  type        = number
  default     = 1
}

variable "db_host" {
  description = "Database hostname passed to containers. Leave empty until RDS is added."
  type        = string
  default     = ""
}

variable "db_name" {
  description = "Database name passed to containers."
  type        = string
  default     = "fintech"
}

variable "db_user" {
  description = "Database username passed to containers."
  type        = string
  default     = "postgres"
}

variable "db_password_secret_arn" {
  description = "Secrets Manager ARN containing the DB password. Leave empty until created."
  type        = string
  default     = ""
}
