data "archive_file" "dispatcher_zip" {
  type        = "zip"
  source_file = "${path.module}/src/dispatcher.py"
  output_path = "${path.module}/dispatcher.zip"
}

resource "aws_lambda_function" "dispatcher" {
  function_name = "assessment-dispatcher-${var.region}-${random_id.suffix.hex}"
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "python3.11"
  handler       = "dispatcher.handler"

  filename         = data.archive_file.dispatcher_zip.output_path
  source_code_hash = data.archive_file.dispatcher_zip.output_base64sha256

  environment {
    variables = {
      ECS_CLUSTER_ARN  = aws_ecs_cluster.this.arn
      ECS_TASK_DEF_ARN = aws_ecs_task_definition.sns_publisher.arn
      ECS_SUBNETS      = join(",", [aws_subnet.public_a.id, aws_subnet.public_b.id])
      ECS_SG           = aws_security_group.ecs_tasks.id
    }
  }
}
