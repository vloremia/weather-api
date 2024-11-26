# AWS Region
variable "region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "ap-northeast-1"
}

# S3 Bucket Name
variable "s3_bucket_name" {
  description = "Name of the S3 bucket to store weather data."
  type        = string
  default     = "weather-data-bucket"
}

# OpenWeatherMap API Key
variable "openweather_api_key" {
  description = "API key for the OpenWeatherMap service."
  type        = string
}

# Lambda Function Names
variable "lambda_weather_function_name" {
  description = "Name of the Lambda function for current weather data."
  type        = string
  default     = "weatherHandler"
}

variable "lambda_history_function_name" {
  description = "Name of the Lambda function for historical weather data."
  type        = string
  default     = "historyHandler"
}

# API Gateway Name
variable "api_gateway_name" {
  description = "Name of the API Gateway for weather API."
  type        = string
  default     = "WeatherAPI"
}

variable "account_id" {
  default = "325683368959"
}
