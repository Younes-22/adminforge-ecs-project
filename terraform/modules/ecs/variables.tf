
variable "vpc_id" {
  description = "VPC ID for ECS tasks"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets where ECS tasks will run"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ALB target group ARN for the ECS service"
  type        = string
}

variable "execution_role_arn" {
  description = "IAM role used by ECS to execute the task"
  type        = string
}

variable "container_image" {
  description = "Docker image to run"
  type        = string
}

variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
  default     = "ecs-cluster"
}

variable "service_name" {
  description = "ECS service name"
  type        = string
  default     = "memos-service"
}

variable "task_security_group_name" {
  description = "Security group name for ECS tasks"
  type        = string
  default     = "ecs-task-sg"
}

variable "container_name" {
  description = "Name of the application container"
  type        = string
  default     = "memos"
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "my-adminforge-app"
}

variable "container_port" {
  description = "Port the application listens on"
  type        = number
  default     = 8080
}

variable "task_cpu" {
  description = "ECS task CPU units"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "ECS task memory in MiB"
  type        = number
  default     = 512
}


variable "task_family" {
  description = "ECS task definition family"
  type        = string
  default     = "service"
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 1
}