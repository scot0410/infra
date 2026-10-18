# =====================================================================
# ECS IAM PERMISSIONS
# =====================================================================
# Task Execution Role (Allows ECS agent to pull image and push logs)
# resource "aws_iam_role" "ecs_execution_role" {
#   name = "spring-ecs-execution-role"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action    = "sts:AssumeRole"
#       Effect    = "Allow"
#       Principal = { Service = "://amazonaws.com" }
#     }]
#   })
# }
#
# resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
#   role       = aws_iam_role.ecs_execution_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }
#
# # Task Role (If your Spring Boot app needs to put events to EventBridge or talk to AWS)
# resource "aws_iam_role" "ecs_task_role" {
#   name = "spring-ecs-task-role"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action    = "sts:AssumeRole"
#       Effect    = "Allow"
#       Principal = { Service = "://amazonaws.com" }
#     }]
#   })
# }
#
# # Optional: Allow Spring app to push events to your event bus
# resource "aws_iam_policy" "ecs_sqs_publish" {
#   name = "ECSSQSPublishPolicy"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect   = "Allow"
#       Action   = ["events:PutEvents"]
#       Resource = [aws_sqs_queue.recall_event_queue.arn]
#     }]
#   })
# }
#
# resource "aws_iam_role_policy_attachment" "ecs_task_publish_attach" {
#   role       = aws_iam_role.ecs_task_role.name
#   policy_arn = aws_iam_policy.ecs_sqs_publish.arn
# }
#
# resource "aws_iam_role" "scheduler_role" {
#   name = "eventbridge-scheduler-ecs-role"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action    = "sts:AssumeRole"
#       Effect    = "Allow"
#       Principal = { Service = "://amazonaws.com" }
#     }]
#   })
# }