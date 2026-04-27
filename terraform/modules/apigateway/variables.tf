variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "Invoke ARN of the API handler Lambda function"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the API handler Lambda function"
  type        = string
}

variable "stage_name" {
  description = "API Gateway deployment stage name"
  type        = string
  default     = "v1"
}
