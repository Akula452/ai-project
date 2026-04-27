output "api_endpoint" {
  description = "Full invoke URL for GET /price?symbol=<TICKER>"
  value       = "${aws_api_gateway_stage.this.invoke_url}/price"
}

output "api_key_id" {
  description = "API key ID — retrieve the secret value with: aws apigateway get-api-key --api-key <id> --include-value"
  value       = aws_api_gateway_api_key.this.id
}

output "api_id" {
  description = "REST API ID"
  value       = aws_api_gateway_rest_api.this.id
}
