data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

locals {
  name                = "${var.project_name}-${var.environment}"
  ecr_repository_name = coalesce(var.ecr_repository_name, local.name)
  ecr_repository_url  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${local.ecr_repository_name}"
  eks_cluster_name    = coalesce(var.eks_cluster_name, local.name)
  ecs_cluster_name    = coalesce(var.ecs_cluster_name, local.name)
  azs                 = slice(data.aws_availability_zones.available.names, 0, 2)
  image_uri           = "${local.ecr_repository_url}:${var.image_tag}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "network" {
  source = "../../modules/network"

  name        = local.name
  vpc_cidr    = var.vpc_cidr
  azs         = local.azs
  common_tags = local.common_tags
}

module "eks" {
  source = "../../modules/eks"

  name                = local.name
  cluster_name        = local.eks_cluster_name
  private_subnet_ids  = module.network.private_subnet_ids
  public_access_cidrs = var.eks_public_access_cidrs
  node_instance_types = var.eks_node_instance_types
  desired_nodes       = var.eks_desired_nodes
  min_nodes           = var.eks_min_nodes
  max_nodes           = var.eks_max_nodes
  log_retention_days  = var.log_retention_days
  common_tags         = local.common_tags
}

module "rds" {
  source = "../../modules/rds"

  name                  = local.name
  vpc_id                = module.network.vpc_id
  vpc_cidr              = var.vpc_cidr
  private_subnet_ids    = module.network.private_subnet_ids
  db_name               = var.db_name
  db_user               = var.db_user
  db_port               = var.db_port
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  multi_az              = var.db_multi_az
  skip_final_snapshot   = var.db_skip_final_snapshot
  deletion_protection   = var.db_deletion_protection
  backup_retention_days = var.db_backup_retention_days
  common_tags           = local.common_tags
}

module "ecs" {
  source = "../../modules/ecs"

  name                   = local.name
  cluster_name           = local.ecs_cluster_name
  vpc_id                 = module.network.vpc_id
  public_subnet_ids      = module.network.public_subnet_ids
  private_subnet_ids     = module.network.private_subnet_ids
  public_ingress_cidrs   = var.public_ingress_cidrs
  container_port         = var.container_port
  image_uri              = local.image_uri
  aws_region             = var.aws_region
  desired_count          = var.ecs_desired_count
  db_host                = module.rds.address
  db_name                = module.rds.db_name
  db_user                = module.rds.db_user
  db_port                = module.rds.port
  db_password_secret_arn = module.rds.password_secret_value_from
  log_retention_days     = var.log_retention_days
  common_tags            = local.common_tags
}

resource "kubernetes_secret" "app_env" {
  metadata {
    name      = "fintech-app-env"
    namespace = "default"
  }

  data = {
    DB_HOST     = module.rds.address
    DB_NAME     = module.rds.db_name
    DB_USER     = module.rds.db_user
    DB_PORT     = tostring(module.rds.port)
    DB_PASSWORD = module.rds.password
  }

  type = "Opaque"

  depends_on = [
    module.eks,
    module.rds
  ]
}

module "argocd" {
  source = "../../modules/argocd"

  git_repo_url          = var.argocd_git_repo_url
  app_path              = var.argocd_app_path
  node_group_dependency = kubernetes_secret.app_env.id
}

module "monitoring" {
  source = "../../modules/monitoring"

  name                    = local.name
  aws_region              = var.aws_region
  ecs_cluster_name        = module.ecs.cluster_name
  ecs_service_name        = module.ecs.service_name
  ecs_alb_suffix          = module.ecs.alb_arn_suffix
  ecs_target_group_suffix = module.ecs.target_group_arn_suffix
  ecs_log_group_name      = module.ecs.log_group_name
  eks_node_asg_name       = module.eks.node_asg_name
  eks_min_nodes           = var.eks_min_nodes
  eks_log_group_name      = module.eks.cluster_log_group_name
  alarm_actions           = var.alarm_actions
  common_tags             = local.common_tags
}
