variable "env" {
  description = "Environment"
  type        = string
  default     = "production"
}

variable "maintainer" {
  description = "Maintainer Email"
  type        = string
  default     = "maintainer@email.com"
}

variable "unique_key_name" {
  description = "Unique Key Name"
  type        = string
  default     = "unique-key-name"
}

variable "domain_name" {
  description = "Domain Name for the application"
  type        = string
  default     = "finn.auto"
}

variable "zone_id" {
  description = "Zone ID"
  type        = string
  default     = "zone-id"
}

variable "vpc_cidr_prefix" {
  description = "VPC CIDR prefix"
  type        = string
  default     = "10.0"
}

variable "subdomain" {
  description = "Subdomain"
  type        = string
  default     = "finnoco"
}

variable "db_instance_class" {
  type        = string
  description = "instance class for the database instance"
  default     = "db.t3.medium"
}

variable "db_instance_replica_class" {
  type        = string
  description = "instance class for the database instance"
  default     = "db.t3.medium"
}

variable "db_instance_count" {
  type        = number
  description = "number of instances of databases."
  default     = 1
}

variable "redis_cluster_size" {
  type        = number
  description = "number of redis instances in the cluster"
  default     = 1
}

variable "redis_instance_type" {
  type        = string
  description = "instance type for redis"
  default     = "cache.m6g.large"
}

variable "redis_automatic_failover_enabled" {
  type        = bool
  description = "enable automatic failover"
  default     = false
}

variable "noco_image_version" {
  type        = string
  description = "Noco image version to deploy"
  default     = "latest"
}

variable "nc_auth_jwt_secret" {
  type        = string
  description = "nocodb NC_AUTH_JWT_SECRET token"
  default     = ""
}

variable "nc_nodejs_max_memory" {
  type        = string
  description = "max memory acquired by node process"
  default     = "4096"
}

variable "desired_ecs_task_count" {
  type        = number
  description = "desired number of tasks"
  default     = 1
}