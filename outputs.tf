output "lambda_function_arn" {
  value = aws_lambda_function.example.invoke_arn
}

output "api_gateway_url" {
  value = aws_apigatewayv2_api.example.api_endpoint
}