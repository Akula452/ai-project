variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
}

variable "function_name_suffix" {
  description = "Suffix appended to project_name for the Lambda function name"
  type        = string
}

variable "handler" {
  description = "Lambda handler in the form file.method"
  type        = string
  default     = "handler.lambda_handler"
}

variable "runtime" {
  description = "Lambda runtime identifier"
  type        = string
  default     = "python3.12"
}

variable "source_dir" {
  description = "Absolute path to the Lambda source directory"
  type        = string
}

variable "execution_role_arn" {
  description = "IAM role ARN for Lambda execution"
  type        = string
}

variable "timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Lambda function memory allocation in MB"
  type        = number
  default     = 256
}

variable "environment_variables" {
  description = "Map of environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 30
}
