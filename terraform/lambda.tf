# =====================================================================
# Packing local Lambda into zip package
# =====================================================================
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../localstack/index.py"
  output_path = "${path.module}/function.zip"
}

# =====================================================================
# INGESTION LAYER (LAMBDA)
# =====================================================================
resource "aws_lambda_function" "sqs_consumer" {
  filename          = data.archive_file.lambda_zip.output_path
  function_name     = "message-ingest-lambda"
  role              = aws_iam_role.lambda_role.arn
  handler           = "index.handler"
  runtime           = "python3.10"
  source_code_hash  = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.recalls_table.name
    }
  }
}

# =====================================================================
# SQS TO LAMBDA EVENT TRIGGER
# =====================================================================
resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.recall_event_queue.arn
  function_name    = aws_lambda_function.sqs_consumer.arn
  batch_size       = 10 # Number of messages Lambda pulls at once (max 10)
  maximum_batching_window_in_seconds = 5
  enabled          = true
}

# =====================================================================
# LAMBDA IAM PERMISSIONS
# =====================================================================
resource "aws_iam_role" "lambda_role" {
  name = "lambda-event-consumer-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}