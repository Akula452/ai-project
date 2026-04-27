output "bedrock_role_arn" {
  value = aws_iam_role.bedrock_role.arn
}

output "bedrock_role_name" {
  value = aws_iam_role.bedrock_role.name
}
