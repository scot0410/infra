# Create the CloudWatch Log Group for your Lambda
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.sqs_consumer.function_name}"
  retention_in_days = 7 # Optional: keeps things clean
}