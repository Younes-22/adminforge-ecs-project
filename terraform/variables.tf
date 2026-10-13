variable "domain_name" {
  type = string
}

variable "container_image" {
  description = "Docker image URI and tag to deploy"
  type        = string
  default     = "872450837551.dkr.ecr.eu-west-2.amazonaws.com/my-adminforge-app"
}