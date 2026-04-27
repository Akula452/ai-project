variable "project_name" {
  description = "Project name used as prefix for resources"
  type        = string
}

variable "bedrock_role_arn" {
  description = "IAM Role ARN for Bedrock logging"
  type        = string
}
