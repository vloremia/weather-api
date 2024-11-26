# S3 Bucket Name
output "s3_bucket_name" {
  description = "The name of the S3 bucket used to store weather data."
  value       = aws_s3_bucket.weather_data.bucket
}

# Current Weather Lambda Function ARN
output "current_weather_lambda_arn" {
  description = "The ARN of the Lambda function for fetching current weather data."
  value       = aws_lambda_function.current_weather.arn
}

# Historical Weather Lambda Function ARN
output "historical_weather_lambda_arn" {
  description = "The ARN of the Lambda function for fetching historical weather data."
  value       = aws_lambda_function.historical_weather.arn
}

# API Gateway URL for Current Weather Endpoint
output "current_weather_api_url" {
  description = "The URL of the API Gateway endpoint for fetching current weather data."
  value       = "${aws_api_gateway_deployment.weather_api.invoke_url}/weather/{city}"
}

# API Gateway URL for Historical Weather Endpoint
output "historical_weather_api_url" {
  description = "The URL of the API Gateway endpoint for fetching historical weather data."
  value       = "${aws_api_gateway_deployment.weather_api.invoke_url}/weather/history/{city}"
}
