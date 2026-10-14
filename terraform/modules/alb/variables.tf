
variable "vpc_id" {
  description = "VPC ID for the ALB"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate"
  type        = string
}

variable "alb_name" {
  description = "Name of the application load balancer"
  type        = string
  default     = "ecs-alb"
}

variable "http_port" {
  description = "HTTP listener port"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "HTTPS listener port"
  type        = number
  default     = 443
}

variable "app_port" {
  description = "Port the application listens on"
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "Application health check endpoint"
  type        = string
  default     = "/healthz"
}

# variable "task_security_group_id" {
#   description = "Security group ID of the ECS tasks"
#   type        = string
# }

variable "vpc_cidr" {
  description = "CIDR block of the VPC containing the ECS tasks"
  type        = string
  default = "10.0.0.0/16"
}