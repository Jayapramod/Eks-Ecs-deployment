variable "name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_access_cidrs" {
  type = list(string)
}

variable "node_instance_types" {
  type = list(string)
}

variable "desired_nodes" {
  type = number
}

variable "min_nodes" {
  type = number
}

variable "max_nodes" {
  type = number
}

variable "log_retention_days" {
  type = number
}

variable "common_tags" {
  type = map(string)
}
