resource "aws_cognito_user_pool" "this" {
  name = "assessment-user-pool"

  auto_verified_attributes = ["email"]

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = true
  }
}

resource "aws_cognito_user_pool_client" "this" {
  name         = "assessment-client"
  user_pool_id = aws_cognito_user_pool.this.id

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  generate_secret = false
}

# Create a test user (email as username)
resource "aws_cognito_user" "test_user" {
  user_pool_id = aws_cognito_user_pool.this.id
  username     = var.email

  attributes = {
    email          = var.email
    email_verified = "true"
  }

  # Temporary password; we set permanent below
  temporary_password   = "TempPass123!Aa"
  force_alias_creation = false
}

# Set permanent password via AWS CLI (works on macOS if aws cli is installed & authenticated)
resource "null_resource" "set_permanent_password" {
  depends_on = [aws_cognito_user.test_user]

  triggers = {
    user_pool_id = aws_cognito_user_pool.this.id
    username     = var.email
    pw_hash      = sha256(var.cognito_test_user_password)
  }

  provisioner "local-exec" {
    command = <<EOT
aws cognito-idp admin-set-user-password \
  --user-pool-id "${aws_cognito_user_pool.this.id}" \
  --username "${var.email}" \
  --password "${var.cognito_test_user_password}" \
  --permanent
EOT
  }
}
