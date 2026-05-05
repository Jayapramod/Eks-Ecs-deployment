variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "project_name" {
  type    = string
  default = "web-app"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "ecr_repository_name" {
  type    = string
  default = "web-app"
}

variable "eks_cluster_name" {
  type    = string
  default = "web-app-eks"
}

variable "ecs_cluster_name" {
  type    = string
  default = "web-app-ecs"
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "container_port" {
  type    = number
  default = 3000
}

variable "public_ingress_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "eks_public_access_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "eks_node_instance_types" {
  type    = list(string)
  default = ["t3.small"]
}

variable "eks_desired_nodes" {
  type    = number
  default = 2
}

variable "eks_min_nodes" {
  type    = number
  default = 1
}

variable "eks_max_nodes" {
  type    = number
  default = 2
}

variable "ecs_desired_count" {
  type    = number
  default = 1
}

variable "log_retention_days" {
  type    = number
  default = 14
}

variable "alarm_actions" {
  type    = list(string)
  default = []
}

variable "argocd_git_repo_url" {
  type    = string
  default = "https://github.com/Jayapramod/Eks-Ecs-deployment.git"
}

variable "argocd_app_path" {
  type    = string
  default = "k8s/web-app"
}

variable "db_name" {
  type    = string
  default = "webapp"
}

variable "db_user" {
  type    = string
  default = "app_user"
}

variable "db_port" {
  type    = number
  default = 5432
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_multi_az" {
  type    = bool
  default = false
}

variable "db_skip_final_snapshot" {
  type    = bool
  default = true
}

variable "db_deletion_protection" {
  type    = bool
  default = false
}

variable "db_backup_retention_days" {
  type    = number
  default = 1
}
