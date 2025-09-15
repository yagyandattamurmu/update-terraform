variable "aws_account" {
  type        = string
  description = "The AWS account number"
}

variable "aws_profile" {
  type        = string
  description = "Profile used to apply the terraform"
}

variable "region" {
  type        = string
  description = "The AWS region"
  default     = "us-east-1"
}

variable "env" {
  type        = string
  description = "The environment"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID"
}

variable "ecs_cluster_id" {
  type        = string
  description = "The ECS cluster ID"
}

variable "ecs_ui_cpu" {
  type        = number
  description = "The CPU of the ui service"
  default     = 256
}

variable "ecs_ui_mem" {
  type        = number
  description = "The memory of the ui service"
  default     = 512
}

variable "ecs_service_cpu" {
  type        = number
  description = "The CPU of the backend service"
  default     = 2048
}

variable "ecs_service_mem" {
  type        = number
  description = "The memory of the backend service"
  default     = 4096
}

variable "ecs_scheduler_cpu" {
  type        = number
  description = "The CPU of the scheduler service"
  default     = 2048
}
variable "ecs_scheduler_mem" {
  type        = number
  description = "The memory of the scheduler service"
  default     = 4096
}

# variable "cnx_subnets" {
#   type        = list(string)
#   description = "The application subnets"
# }

variable "app_subnets" {
  type        = list(string)
  description = "The application subnets"
}

variable "db_subnets" {
  type        = list(string)
  description = "The application subnets"
}

variable "db_max_allocated_storage" {
  type        = number
  description = "The maximum allocated storage for the RDS instance"  
}

variable "db_allocated_storage" {
  type        = number
  description = "The allocated storage for the RDS instance"  
}

variable "db_delete_protection" {
  type        = bool
  description = "is this db delete protection"
  default     = true
}

variable "db_multi_az" {
  type        = bool
  description = "Enable Multi-AZ for the RDS instance"
  default     = false
}

variable "db_max_connections" {
  type        = number
  description = "The maximum connections of the RDS"
  default     = 150
}

variable "alb_listener_arn" {
  type        = string
  description = "The ARN of the ALB listener"
}

variable "alb_security_group_id" {
  type        = string
  description = "The security group ID of the ALB"
}

variable "vpc_endpoint_security_group_id" {
  type        = string
  description = "The security group ID of the VPC endpoints"
}

variable "s3_prefix_list_id" {
  type        = string
  description = "The prefix list ID of the S3 for the VPC"
}

variable "domain_name" {
  type        = string
  description = "The domain name of the application"
}

# variable "admin_domain_name" {
#   type        = string
#   description = "The admin domain name of the application"
# }

# variable "certificate_arns" {
#   type        = list(string)
#   description = "The ARN of the certificates ad add to the ALB listener"
# }

variable "image_service" {
  type        = string
  description = "The image of the core service"
}

variable "image_scheduler" {
  type        = string
  description = "The image of the scheduler"
}

variable "image_ui" {
  type        = string
  description = "The image of the UI service"
}

variable "db_instance_class" {
  type        = string
  description = "The instance class of the RDS"
  #default = "db.t4g.micro"
}

variable "tags" {
  type        = map(string)
  description = "The tags to apply to the resources"
  default     = {}

}

# ALB PRIORITY
variable "ui_alb_priority" {
  type        = number
  description = "The priority of the UI ALB"

}

variable "service_alb_priority" {
  type        = number
  description = "The priority of the service ALB"
}

variable "scheduler_alb_priority" {
  type        = number
  description = "The priority of the scheduler ALB"
}

variable "bucket_intent" {
  description = "Intent name of the S3 bucket"
  type        = string
}

variable "queue_type" {
  description = "The type of queue (standard or fifo)"
  type        = string
  default     = "fifo"
}

variable "delay_seconds" {
  description = "The time in seconds that the delivery of all messages in the queue will be delayed"
  type        = number
  default     = 0
}

variable "max_message_size" {
  description = "The limit of how many bytes a message can contain before Amazon SQS rejects it"
  type        = number
  default     = 262144
}

variable "message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message"
  type        = number
  default     = 345600
}

variable "receive_wait_time_seconds" {
  description = "The time for which a ReceiveMessage call will wait for a message to arrive"
  type        = number
  default     = 20
}

variable "visibility_timeout_seconds" {
  description = "The visibility timeout for the queue"
  type        = number
  default     = 30
}

variable "dlq_max_receive_count" {
  description = "The number of times a message can be unsuccessfully dequeued before being moved to the dead-letter queue"
  type        = number
  default     = 3
}

variable "ecs_service_count" {
  type        = number
  description = "The number of tasks to run"
  default     = 1
}

variable "ecs_ui_count" {
  type        = number
  description = "The number of tasks to run"
  default     = 1
}

variable "ecs_scheduler_count" {
  type        = number
  description = "The number of tasks to run"
  default     = 1
}

variable "redis_node_type" {
  type        = string
  description = "The node type for the Redis cluster"  
}

variable "redis_cluster_mode" {
  type    = string
  default = "replication_group"
}

variable "redis_engine_version" {
  type    = string
  default = "7.0"
}

# variable "redis_node_type" {
#   type    = string
#   default = "cache.t3.micro"
# }

variable "redis_port" {
  type    = number
  default = 6379
}

variable "create_security_group" {
  type    = bool
  default = true
}

variable "redis_num_cache_nodes" {
  type    = number
  default = 1
}

variable "redis_number_cache_clusters" {
  type    = number
  default = 1
}

variable "redis_automatic_failover_enabled" {
  type    = bool
  default = false
}

variable "create_parameter_group" {
  type    = bool
  default = true
}

variable "redis_parameters" {
  type = map(string)
  default = {
    "maxmemory-policy" = "volatile-lru"
  }
}

variable "create_log_group" {
  type    = bool
  default = true
}

variable "log_retention_in_days" {
  type    = number
  default = 14
}
