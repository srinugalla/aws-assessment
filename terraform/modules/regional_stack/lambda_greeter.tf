data "archive_file" "greeter_zip" {
  type        = "zip"
  source_file = "${path.module}/src/greeter.py"
  output_path = "${path.module}/greeter.zip"
}

resource "aws_lambda_function" "greeter" {
  function_name = "assessment-greeter-${var.region}-${random_id.suffix.hex}"
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "python3.11"
  handler       = "greeter.handler"

  filename         = data.archive_file.greeter_zip.output_path
  source_code_hash = data.archive_file.greeter_zip.output_base64sha256

  environment {
    variables = {
      DDB_TABLE     = aws_dynamodb_table.greeting_logs.name
      SNS_TOPIC_ARN = aws_sns_topic.verification.arn
      EMAIL         = var.email
      REPO          = var.repo_url
    }
  }
}
