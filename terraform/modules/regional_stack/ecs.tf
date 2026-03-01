resource "aws_ecs_cluster" "this" {
  name = "assessment-cluster-${var.region}-${random_id.suffix.hex}"
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/assessment-${var.region}-${random_id.suffix.hex}"
  retention_in_days = 7
}

locals {
  ecs_message = jsonencode({
    email  = var.email
    source = "ECS"
    region = var.region
    repo   = var.repo_url
  })
}

resource "aws_ecs_task_definition" "sns_publisher" {
  family                   = "assessment-sns-publisher-${var.region}-${random_id.suffix.hex}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name       = "publisher"
    image      = "public.ecr.aws/aws-cli/aws-cli:latest"
    essential  = true
    entryPoint = ["sh", "-c"]
    command = [
      "aws sns publish --region ${var.region} --topic-arn ${aws_sns_topic.verification.arn} --message '${local.ecs_message}'"
    ]
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name,
        awslogs-region        = var.region,
        awslogs-stream-prefix = "publisher"
      }
    }
  }])
}
