# Data Source for Account ID
data "aws_caller_identity" "current" {}

# AWS Provider
provider "aws" {
  region = var.region
}

resource "random_id" "bucket_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "weather_data" {
  bucket = "weather-data-bucket-${random_id.bucket_id.hex}"
  acl    = "private"
}

resource "aws_iam_role" "lambda_role" {
  name = "weather_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "lambda_s3_access_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.weather_data.arn}",
          "${aws_s3_bucket.weather_data.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_lambda_function" "current_weather" {
  function_name    = "weatherHandler"
  handler          = "lambdas/dist/weatherHandler.handler"
  runtime          = "nodejs18.x"
  role             = aws_iam_role.lambda_role.arn
  filename         = "../lambdas/dist/weatherHandler.zip"
  memory_size      = 128
  timeout          = 10

  environment {
    variables = {
      S3_BUCKET_NAME      = aws_s3_bucket.weather_data.bucket
      OPENWEATHER_API_KEY = "5f723ff8a5e3a0616d47cccd21cf4d46"
    }
  }
}

resource "aws_s3_bucket_policy" "weather_data_policy" {
  bucket = aws_s3_bucket.weather_data.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowLambdaAccess"
        Effect    = "Allow"
        Principal = {
          AWS = aws_iam_role.lambda_role.arn
        }
        Action    = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource  = [
          "${aws_s3_bucket.weather_data.arn}",
          "${aws_s3_bucket.weather_data.arn}/*"
        ]
      }
    ]
  })
}


resource "aws_lambda_function" "historical_weather" {
  function_name = "historyHandler"
  handler       = "lambdas/dist/historyHandler.handler"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_role.arn
  filename      = "../lambdas/dist/historyHandler.zip"

  environment {
    variables = {
      S3_BUCKET_NAME      = aws_s3_bucket.weather_data.bucket
      OPENWEATHER_API_KEY = "5f723ff8a5e3a0616d47cccd21cf4d46"
    }
  }
}

resource "aws_api_gateway_resource" "weather" {
  rest_api_id = aws_api_gateway_rest_api.weather_api.id
  parent_id   = aws_api_gateway_rest_api.weather_api.root_resource_id
  path_part   = "weather"
}

resource "aws_api_gateway_resource" "city" {
  rest_api_id = aws_api_gateway_rest_api.weather_api.id
  parent_id   = aws_api_gateway_resource.weather.id
  path_part   = "{city}"
}

resource "aws_api_gateway_resource" "history" {
  rest_api_id = aws_api_gateway_rest_api.weather_api.id
  parent_id   = aws_api_gateway_resource.weather.id
  path_part   = "history"
}

resource "aws_api_gateway_resource" "history_city" {
  rest_api_id = aws_api_gateway_rest_api.weather_api.id
  parent_id   = aws_api_gateway_resource.history.id
  path_part   = "{city}"
}

resource "aws_api_gateway_method" "current_weather" {
  rest_api_id   = aws_api_gateway_rest_api.weather_api.id
  resource_id   = aws_api_gateway_resource.city.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "historical_weather" {
  rest_api_id   = aws_api_gateway_rest_api.weather_api.id
  resource_id   = aws_api_gateway_resource.history_city.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.current_weather.function_name
  principal     = "apigateway.amazonaws.com"

  # Restrict permission to the specific API Gateway
  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.weather_api.id}/*/*/*"
}

resource "aws_lambda_permission" "api_gateway_invoke_history" {
  statement_id  = "AllowAPIGatewayInvokeHistory"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.historical_weather.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.weather_api.id}/*/*/*"
}

resource "aws_api_gateway_rest_api" "weather_api" {
  name = "WeatherAPI"
}

resource "aws_api_gateway_integration" "current_weather" {
  rest_api_id             = aws_api_gateway_rest_api.weather_api.id
  resource_id             = aws_api_gateway_resource.city.id
  http_method             = aws_api_gateway_method.current_weather.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.current_weather.invoke_arn

  depends_on = [
    aws_lambda_function.current_weather
  ]
}

resource "aws_api_gateway_integration" "historical_weather" {
  rest_api_id             = aws_api_gateway_rest_api.weather_api.id
  resource_id             = aws_api_gateway_resource.history_city.id
  http_method             = aws_api_gateway_method.historical_weather.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.historical_weather.invoke_arn

  depends_on = [
    aws_lambda_function.historical_weather
  ]
}

resource "aws_api_gateway_deployment" "weather_api" {
  rest_api_id = aws_api_gateway_rest_api.weather_api.id
  stage_name  = "prod"

  depends_on = [
    aws_api_gateway_integration.current_weather,
    aws_api_gateway_integration.historical_weather
  ]
}
