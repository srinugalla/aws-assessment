data "aws_region" "current" {}

resource "random_id" "suffix" {
  byte_length = 3
}
