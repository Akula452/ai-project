output "bedrock_role_arn" {
  value = module.iam.bedrock_role_arn
}

output "bedrock_log_group" {
  value = module.bedrock.log_group_name
}

output "bedrock_agent_id" {
  description = "Bedrock Agent ID"
  value       = module.bedrock.agent_id
}

output "bedrock_agent_alias_id" {
  description = "Bedrock Agent Alias ID"
  value       = module.bedrock.agent_alias_id
}

output "stock_lambda_name" {
  description = "Stock action Lambda function name"
  value       = module.stock_lambda.function_name
}

output "api_lambda_name" {
  description = "API handler Lambda function name"
  value       = module.api_lambda.function_name
}

output "api_endpoint" {
  description = "REST API endpoint — GET /price?symbol=<TICKER> with x-api-key header"
  value       = module.apigateway.api_endpoint
}

output "api_key_id" {
  description = "API key ID — run: aws apigateway get-api-key --api-key <id> --include-value"
  value       = module.apigateway.api_key_id
}
