```hcl
###################################################################################
# RDS
###################################################################################

module "pocp_rds" {
  name                   = local.project_name
  source                 = "git::https://github.com/psabdp-it/platform-infra-app-modules.git//modules/rds?ref=v1.0.8"
  db_name                = "ittdb"
  env                    = var.env
  db_subnet_ids          = var.db_subnets
  vpc_id                 = var.vpc_id
  instance_class         = var.db_instance_class
  max_allocated_storage   = var.db_max_allocated_storage
  allocated_storage       = var.db_allocated_storage
  multi_az                = var.db_multi_az # true in production
  # performance_insights_enabled = true
  
  create_parameter_group = true
  parameter_group_parameters = [
    {
      name         = "log_bin_trust_function_creators"
      value        = "1"
      apply_method = "immediate"
    },
    {
      name         = "max_connections"
      value        = var.db_max_connections
      apply_method = "immediate"
    },
    {
      apply_method = "immediate"
      name         = "binlog_format"
      value        = "ROW"
    }
  ]
  apply_immediately = true
  deletion_protection          = var.db_delete_protection
}

###################################################################################
# ECS
###################################################################################
data "aws_caller_identity" "current" {}

module "pocp_ecs_itt_ui" {
  source = "git::https://github.com/psabdp-it/platform-infra-app-modules.git//modules/ecs-fargate?ref=v1.0.8"
  name   = local.ui_name
  env    = var.env

  ecs_cluster_id  = var.ecs_cluster_id
  service_name    = local.ui_name
  container_name  = local.ui_name
  container_image = var.image_ui 

  vpc_id                = var.vpc_id
  app_subnets           = var.app_subnets
  vpc_security_group_id = var.vpc_endpoint_security_group_id

  task_cpu         = var.ecs_ui_cpu
  container_cpu    = var.ecs_ui_cpu
  task_memory      = var.ecs_ui_mem
  container_memory = var.ecs_ui_mem
  #enable_execute_command = true

  desired_count    = var.ecs_ui_count
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
  deregistration_delay               = 10

  otel_enabled          = false
  otel_image = null

  alb_security_group_id = var.alb_security_group_id
  alb_listener_arn      = var.alb_listener_arn
  container_port        = 80
  alb_priority          = var.ui_alb_priority
  alb_condition = [
    {
      path = ["/*"]
      host = [var.domain_name]
    }
  ]

  ecs_secret_manager_arns = [
    aws_secretsmanager_secret.service.arn
  ]

  health_check_grace_period_seconds = 0
  # s3_prefix_list_id     = var.s3_prefix_list_id

  ecs_environment_vars = [
    {
      name  = "ACTIVE_PROFILE"
      value = var.env
    }
  ]

  
}

module "pocp_ecs_itt_service" {
  source = "git::https://github.com/psabdp-it/platform-infra-app-modules.git//modules/ecs-fargate?ref=v1.0.8"
  name   = local.service_name
  env    = var.env

  ecs_cluster_id  = var.ecs_cluster_id
  service_name    = local.service_name
  container_name  = local.service_name
  container_image = var.image_service

  vpc_id                = var.vpc_id
  app_subnets           = var.app_subnets
  vpc_security_group_id = var.vpc_endpoint_security_group_id
  # s3_prefix_list_id     = var.s3_prefix_list_id

  task_cpu         = var.ecs_service_cpu
  container_cpu    = var.ecs_service_cpu
  task_memory      = var.ecs_service_mem
  container_memory = var.ecs_service_mem
  #enable_execute_command = true
  
  desired_count    = var.ecs_service_count
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
  deregistration_delay               = 10

  otel_enabled          = false
  otel_image = null
  
  alb_security_group_id = var.alb_security_group_id
  alb_listener_arn      = var.alb_listener_arn
  container_port        = 8080
  alb_priority          = var.service_alb_priority
  alb_condition = [
    {
      path = ["/api/*"]
      host = [var.domain_name]
    }
  ]

  ecs_secret_manager_arns = [
    aws_secretsmanager_secret.service.arn
  ]

  health_check_grace_period_seconds = 120
  health_check_path = "/api/health"

  ecs_environment_vars = [
    {
      name  = "SPRING_PROFILES_ACTIVE"
      value = var.env
    }
  ]
}

module "pocp_ecs_itt_scheduler" {
  source = "git::https://github.com/psabdp-it/platform-infra-app-modules.git//modules/ecs-fargate?ref=v1.0.8"
  name   = local.scheduler_name
  env    = var.env

  ecs_cluster_id  = var.ecs_cluster_id
  service_name    = local.scheduler_name
  container_name  = local.scheduler_name
  container_image = var.image_scheduler

  vpc_id                = var.vpc_id
  app_subnets           = var.app_subnets
  vpc_security_group_id = var.vpc_endpoint_security_group_id

  task_cpu         = var.ecs_scheduler_cpu
  container_cpu    = var.ecs_scheduler_cpu
  task_memory      = var.ecs_scheduler_mem
  container_memory = var.ecs_scheduler_mem
  #enable_execute_command = true

  desired_count    = var.ecs_scheduler_count
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
  deregistration_delay               = 10

  otel_enabled          = false
  otel_image = null
  
  
  #s3_prefix_list_id     = var.s3_prefix_list_id
  alb_security_group_id = var.alb_security_group_id
  alb_listener_arn      = var.alb_listener_arn
  container_port        = 8080
  alb_priority          = var.scheduler_alb_priority
  alb_condition = [
    {
      path = ["/scheduler/*"]
      host = [var.domain_name]
    }
  ]

  ecs_secret_manager_arns = [
    aws_secretsmanager_secret.service.arn
  ]

  health_check_grace_period_seconds = 120
  health_check_path = "/scheduler/health"

  ecs_environment_vars = [
    {
      name  = "SPRING_PROFILES_ACTIVE"
      value = var.env
    }
  ]
}

################################################################################
# S3 Bucket
################################################################################

module "pocp_s3_itt" {
  source = "git::https://github.com/psabdp-it/platform-infra-app-modules.git//modules/s3_bucket?ref=v1.0.8"

  bucket_name           = "${local.project_name}-${var.bucket_intent}-bucket-${var.env}"
  name                  = local.project_name
  env                   = var.env
  force_destroy         = true
  object_lock_enabled   = false

  tags = { 
    Name = "apps-${local.project_name}-${var.bucket_intent}-bucket-${var.env}" 
    }
}

###################################################################################
# Supporting Resources
###################################################################################

resource "aws_vpc_security_group_ingress_rule" "service" {
  security_group_id            = module.pocp_rds.db_security_group_id
  description                  = "SQL/Aurora Access"
  ip_protocol                  = "tcp"
  to_port                      = 3306
  from_port                    = 3306
  referenced_security_group_id = module.pocp_ecs_itt_service.security_group_id
}
resource "aws_vpc_security_group_ingress_rule" "scheduler" {
  security_group_id            = module.pocp_rds.db_security_group_id
  description                  = "SQL/Aurora Access"
  ip_protocol                  = "tcp"
  to_port                      = 3306
  from_port                    = 3306
  referenced_security_group_id = module.pocp_ecs_itt_scheduler.security_group_id
}

################################################################################
# SQS Queue
################################################################################

module "pocp_sqs_itt" {
  source = "git::https://github.com/psabdp-it/platform-infra-app-modules.git//modules//sqs?ref=v1.0.8"

  name                       = "${local.project_name}-data_consumer"
  env                        = var.env
  queue_type                = "fifo"
  delay_seconds             = 0
  max_message_size          = 262144  # 256 KB
  message_retention_seconds = 345600   # 4 days
  receive_wait_time_seconds = 20
  visibility_timeout_seconds = 960
  dlq_max_receive_count     = 3       # Set to the desired max receive count for DLQ
  retention_in_days         = 14
  kms_master_key_id        = ""       # Use default AWS managed key

  tags = merge(var.tags, { Application = "itt", Environment = var.env })
}

################################################################################
# Secrets Manager for services
################################################################################

resource "aws_secretsmanager_secret" "service" {
  name        = "${local.service_name}-secrets-${var.env}"
  description = "${local.service_name} Service Secrets for ${var.env}"

  tags = {
    Name = "${local.service_name}-secrets-${var.env}"
  }
}

data "aws_iam_policy_document" "service_additional" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      module.pocp_rds.master_user_secret_arn,
      aws_secretsmanager_secret.service.arn,
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject",
    ]
    resources = [
      "${module.pocp_s3_itt.s3_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "service_additional" {
  name   = "${local.service_name}-additional-${var.env}"
  role   = module.pocp_ecs_itt_service.task_role_id
  policy = data.aws_iam_policy_document.service_additional.minified_json
}

data "aws_iam_policy_document" "scheduler_additional" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      module.pocp_rds.master_user_secret_arn,
      aws_secretsmanager_secret.service.arn,
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject",
    ]
    resources = [
      "${module.pocp_s3_itt.s3_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "scheduler_additional" {
  name   = "${local.scheduler_name}-additional-${var.env}"
  role   = module.pocp_ecs_itt_scheduler.task_role_id
  policy = data.aws_iam_policy_document.scheduler_additional.minified_json
}

################################################################################
# Elasticache
################################################################################

module "pocp_redis" {
  source = "../platform-infra-app-modules/modules/elasticache"

  name           = "${local.service_name}-redis-${var.env}"
  cluster_mode   = var.redis_cluster_mode
  engine_version = var.redis_engine_version
  node_type      = var.redis_node_type
  port           = var.redis_port

  # Networking
  subnet_ids            = var.app_subnets
  vpc_id                = var.vpc_id
  create_security_group = var.create_security_group
  allowed_security_group_ids    = [module.pocp_ecs_itt_service.security_group_id, module.pocp_ecs_itt_scheduler.security_group_id]

  # Cluster / Replication group setup
  num_cache_nodes            = var.redis_num_cache_nodes
  number_cache_clusters      = var.redis_number_cache_clusters
  automatic_failover_enabled = var.redis_automatic_failover_enabled

  # Parameter group
  create_parameter_group = var.create_parameter_group
  parameters             = var.redis_parameters

  # Logging
  create_log_group      = var.create_log_group
  log_retention_in_days = var.log_retention_in_days
}
```