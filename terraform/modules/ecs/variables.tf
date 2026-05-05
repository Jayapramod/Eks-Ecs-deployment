variable "name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_ingress_cidrs" {
  type = list(string)
}

variable "container_port" {
  type = number
}

variable "image_uri" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "desired_count" {
  type = number
}

variable "db_host" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_port" {
  type = number
}

variable "db_password_secret_arn" {
  type = string
}

variable "log_retention_days" {
  type = number
}

variable "common_tags" {
  type = map(string)
}
