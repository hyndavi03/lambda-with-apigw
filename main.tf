provider "aws" {
  region = var.aws_region
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/python/"
  output_path = "${path.module}/python/lambda_function.zip"
}

resource "aws_lambda_function" "example" {
  function_name = "MyLambdaFunction"
  filename      = data.archive_file.lambda_zip.output_path
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda-exec-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "api_gateway_role" {
  name = "api_gateway_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_apigatewayv2_api" "example" {
  name          = "example_api"
  protocol_type = "HTTP"
}

resource "aws_lambda_permission" "allow_apigateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = aws_apigatewayv2_api.example.execution_arn
}

resource "aws_apigatewayv2_integration" "example" {
  api_id             = aws_apigatewayv2_api.example.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.example.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "example_route" {
  api_id    = aws_apigatewayv2_api.example.id
  route_key = "GET /myresource"  # Adjust this to the desired route path
  target    = "integrations/${aws_apigatewayv2_integration.example.id}"
}

resource "aws_apigatewayv2_deployment" "example" {
  count       = length(aws_apigatewayv2_route.example_route) > 0 ? 1 : 0
  api_id      = aws_apigatewayv2_api.example.id
  description = "Example deployment"
  depends_on  = [aws_apigatewayv2_route.example_route]
}

resource "aws_apigatewayv2_stage" "example" {
  count         = length(aws_apigatewayv2_deployment.example) > 0 ? 1 : 0
  api_id        = aws_apigatewayv2_api.example.id
  name          = "test"
  auto_deploy   = true
  deployment_id = aws_apigatewayv2_deployment.example[0].id
}
