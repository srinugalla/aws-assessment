resource "aws_sns_topic" "verification" {
  name = "assessment-verification-${var.region}"
}