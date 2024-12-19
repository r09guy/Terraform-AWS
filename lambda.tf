#Lambda Function
# Lambda Function Definition
resource "aws_lambda_function" "upload_file_lambda" {
  function_name    = "uploadFileToS3"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.Terraform-Bucket.bucket
    }
  }

  tags = {
    Name = "UploadFileToS3"
  }
}

# Add these blocks **below the Lambda function**

# HTTP API Gateway
resource "aws_apigatewayv2_api" "http_api" {
  name          = "LambdaHTTPAPI"
  protocol_type = "HTTP"

  tags = {
    Name = "HTTPAPITrigger"
  }
}

# Integration with Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.upload_file_lambda.arn
}

# Route for API Gateway
resource "aws_apigatewayv2_route" "http_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /upload"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Custom Stage Deployment
resource "aws_apigatewayv2_stage" "production_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "production" # Custom stage
  auto_deploy = true

  tags = {
    Name = "ProductionStage"
  }
}

# Lambda Permission for Custom Stage
resource "aws_lambda_permission" "allow_http_api" {
  statement_id  = "AllowHttpApiInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload_file_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/production/*" # Reference custom stage
}

output "api_gateway_url" {
  value = "value: url -X POST -H 'filename: example.txt' -d 'Mustafa Test' ${aws_apigatewayv2_api.http_api.api_endpoint}/${aws_apigatewayv2_stage.production_stage.name}/upload"
  description = "The API Gateway URL for uploading files."
}

output "Lambda-Command" {
  value = "url -X POST -H 'filename: example.txt' -d 'Mustafa Test'"
}

#curl -X POST -H "filename: example.txt" -d "Mustafa Test" https://8pi4zekerh.execute-api.eu-west-1.amazonaws.com/test
#Mustafa Karabayir