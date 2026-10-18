# =====================================================================
# EVENTBRIDGE SCHEDULER (Triggers ECS Task every 5 mins)
# =====================================================================
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 4. The Schedule (Triggers your ECS Fargate container every 5 minutes)
resource "aws_scheduler_schedule" "run_spring_cli" {
  name                = "trigger-spring-cli-every-5-mins"
  schedule_expression = "rate(5 minutes)"
  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_ecs_cluster.app_cluster.arn
    role_arn = aws_iam_role.scheduler_role.arn

    ecs_parameters {
      task_definition_arn = aws_ecs_task_definition.app_task.arn
      launch_type         = "FARGATE"
      task_count          = 1

      network_configuration {
        subnets          = data.aws_subnets.default_subnets.ids
        assign_public_ip = true # Required for default VPC public subnets to reach internet/ECR
      }
    }
  }
}

resource "aws_iam_role" "scheduler_role" {
  name = "eventbridge-scheduler-ecs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "://amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "scheduler_attach" {
  role       = aws_iam_role.scheduler_role.name
  policy_arn = aws_iam_policy.scheduler_ecs_run.arn
}

resource "aws_iam_policy" "scheduler_ecs_run" {
  name = "EventBridgeSchedulerECSPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecs:RunTask"]
        Resource = [aws_ecs_task_definition.app_task.arn]
      },
      {
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = [
          aws_iam_role.ecs_execution_role.arn,
          aws_iam_role.ecs_task_role.arn
        ]
      }
    ]
  })
}