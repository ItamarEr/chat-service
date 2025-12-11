variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Name prefix for AWS resources"
  type        = string
  default     = "chat-service"
}
