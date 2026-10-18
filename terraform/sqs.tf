resource "aws_sqs_queue" "recall_event_queue" {
  name                      = "recall-event-queue.fifo"
  delay_seconds             = 90
  max_message_size          = 262144 #change this later!
  message_retention_seconds  = 345600 # 4 days
  receive_wait_time_seconds = 10
  fifo_queue                  = true
  # content_based_deduplication = true
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.recall_event_queue_deadletter.arn
    maxReceiveCount     = 4
  })
  visibility_timeout_seconds = 30

  tags = {
    Environment = "local"
  }
}

resource "aws_sqs_queue" "recall_event_queue_deadletter" {
  name = "recall-event-queue-deadletter"
}

resource "aws_sqs_queue_redrive_allow_policy" "terraform_queue_redrive_allow_policy" {
  queue_url = aws_sqs_queue.recall_event_queue_deadletter.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.recall_event_queue.arn]
  })
}

# Task Role (If your Spring Boot app needs to put events to EventBridge or talk to AWS)
resource "aws_iam_role" "sqs_task_role" {
  name = "sqs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "://amazonaws.com" }
    }]
  })
}