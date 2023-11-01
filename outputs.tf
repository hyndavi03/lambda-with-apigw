output "vpc_id" {
  value = aws_vpc.example.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.example.id
}


output "api_gateway_url" {
  value = aws_apigatewayv2_api.example.api_endpoint
}

output "lambda_function_arn" {
  value = aws_lambda_function.example.arn
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.example.api_endpoint
}

