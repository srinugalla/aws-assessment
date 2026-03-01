module "auth" {
  source    = "./modules/auth_cognito"
  providers = { aws = aws }

  email                      = var.email
  cognito_test_user_password = var.cognito_test_user_password
}

module "stack_primary" {
  source    = "./modules/regional_stack"
  providers = { aws = aws }

  region   = var.region_primary
  email    = var.email
  repo_url = var.repo_url

  cognito_user_pool_arn       = module.auth.user_pool_arn
  cognito_user_pool_client_id = module.auth.user_pool_client_id
  cognito_user_pool_id        = module.auth.user_pool_id
}

module "stack_secondary" {
  source    = "./modules/regional_stack"
  providers = { aws = aws.secondary }

  region   = var.region_secondary
  email    = var.email
  repo_url = var.repo_url

  cognito_user_pool_arn       = module.auth.user_pool_arn
  cognito_user_pool_client_id = module.auth.user_pool_client_id
  cognito_user_pool_id        = module.auth.user_pool_id
}
