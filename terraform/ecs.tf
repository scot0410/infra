# =====================================================================
# ECS COMPUTE LAYER
# =====================================================================
resource "aws_ecs_cluster" "app_cluster" {
  name = "health-hazard-events-cluster"
}

# ECS Task Definition for your CLI App
resource "aws_ecs_task_definition" "app_task" {
  family                   = "health-hazard-events-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256" # 0.25 vCPU
  memory                   = "512" # 512 MB (adjust higher if Spring Boot needs more heap)
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = "health-hazard-events"
    image     = "${aws_ecr_repository.health_hazard_events_repo.repository_url}:latest"
    essential = true
    environment = [
      { name = "recall-event-queue", value = aws_sqs_queue.recall_event_queue.name }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/health-hazard-events"
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
        "awslogs-create-group"  = "true"
      }
    }
  }])
}

# =====================================================================
# ECS IAM PERMISSIONS
# =====================================================================
# Task Execution Role (Allows ECS agent to pull image and push logs)
resource "aws_iam_role" "ecs_execution_role" {
  name = "spring-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "://amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Task Role (If your Spring Boot app needs to put events to EventBridge or talk to AWS)
resource "aws_iam_role" "ecs_task_role" {
  name = "spring-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "://amazonaws.com" }
    }]
  })
}

# Optional: Allow Spring app to push events to your sqs queue
resource "aws_iam_policy" "ecs_sqs_publish" {
  name = "ECSSQSPublishPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["events:PutEvents"]
      Resource = [aws_sqs_queue.recall_event_queue.arn]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_publish_attach" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_sqs_publish.arn
}