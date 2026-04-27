output "bedrock_role_arn" {
  value = module.iam.bedrock_role_arn
}

output "bedrock_log_group" {
  value = module.bedrock.log_group_name
}
