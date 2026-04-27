output "bedrock_role_arn" {
  value = aws_iam_role.bedrock_role.arn
}

output "bedrock_role_name" {
  value = aws_iam_role.bedrock_role.name
}

output "lambda_stock_role_arn" {
  description = "Execution role ARN for the stock action Lambda"
  value       = aws_iam_role.lambda_stock_role.arn
}

output "lambda_api_role_arn" {
  description = "Execution role ARN for the API handler Lambda"
  value       = aws_iam_role.lambda_api_role.arn
}
