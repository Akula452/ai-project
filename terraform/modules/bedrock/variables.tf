variable "project_name" {
  description = "Project name used as prefix for resources"
  type        = string
}

variable "bedrock_role_arn" {
  description = "IAM Role ARN for Bedrock logging and agent execution"
  type        = string
}

variable "bedrock_model_id" {
  description = "Bedrock foundation model ID for the agent"
  type        = string
  default     = "anthropic.claude-3-5-sonnet-20241022-v2:0"
}

variable "stock_action_lambda_arn" {
  description = "ARN of the stock action Lambda (Bedrock Agent action group executor)"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}
