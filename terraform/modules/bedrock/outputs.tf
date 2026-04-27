output "log_group_name" {
  value = aws_cloudwatch_log_group.bedrock_logs.name
}

output "agent_id" {
  description = "Bedrock Agent ID"
  value       = aws_bedrockagent_agent.stock_agent.agent_id
}

output "agent_arn" {
  description = "Bedrock Agent ARN"
  value       = aws_bedrockagent_agent.stock_agent.agent_arn
}

output "agent_alias_id" {
  description = "Bedrock Agent Alias ID used by the API handler Lambda"
  value       = aws_bedrockagent_agent_alias.live.agent_alias_id
}
