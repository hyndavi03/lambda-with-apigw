output "api_gateway_url" {
  value = aws_apigatewayv2_api.example.api_endpoint
}

output "lambda_function_arn" {
  value = aws_lambda_function.example.arn
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.example.api_endpoint
}
