variable "region_primary" {
  type    = string
  default = "us-east-1"
}

variable "region_secondary" {
  type    = string
  default = "eu-west-1"
}

variable "email" {
  type    = string
  default = "srinu.galla@gmail.com"
}

variable "github_user" {
  type    = string
  default = "srinugalla"
}

variable "repo_url" {
  type    = string
  default = "https://github.com/srinugalla/aws-assessment"
}

# Start with YOUR OWN topic ARN, later swap to Unleash ARN and re-apply
variable "verification_sns_topic_arn" {
  type = string
}

# For Cognito test user password (do not commit the value)
variable "cognito_test_user_password" {
  type      = string
  sensitive = true
}
