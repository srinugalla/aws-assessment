variable "email" {
  type = string
}

variable "cognito_test_user_password" {
  type      = string
  sensitive = true
}
