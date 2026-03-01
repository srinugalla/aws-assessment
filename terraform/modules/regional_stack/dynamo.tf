resource "aws_dynamodb_table" "greeting_logs" {
  name         = "GreetingLogs-${var.region}-${random_id.suffix.hex}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = { Name = "GreetingLogs-${var.region}" }
}
