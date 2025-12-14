resource "aws_ecs_cluster" "chat_api" {
  name = "${var.project_name}-cluster"
}

resource "aws_ecs_task_definition" "chat_api" {
  family                   = "${var.project_name}-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "chat-api"
      image     = "${aws_ecr_repository.chat_api.repository_url}:v1"
      essential = true

      portMappings = [
        {
          containerPort = 8000
          protocol      = "tcp"
        }
      ],

      environment = [
        {
          name  = "SQS_URL"
          value = aws_sqs_queue.messages_queue.id
        },
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "DYNAMODB_TABLE"
          value = aws_dynamodb_table.messages_table.name
        }
      ],

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/chat-api"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}


resource "aws_ecs_service" "chat_api" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.chat_api.id
  task_definition = aws_ecs_task_definition.chat_api.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = data.aws_subnets.default.ids
    security_groups = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.chat_api_tg.arn
    container_name   = "chat-api"
    container_port   = 8000
  }

  depends_on = [
    aws_lb_listener.chat_api_http
  ]
}
