variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "myapp"
}


variable "enable_flow_logs" {
  description = "enable vpc logs"
  type        = bool
  default     = "true"
}
