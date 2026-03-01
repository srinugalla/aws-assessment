output "cognito_user_pool_client_id" {
  value = module.auth.user_pool_client_id
}

output "cognito_user_pool_id" {
  value = module.auth.user_pool_id
}

output "api_base_url_primary" {
  value = module.stack_primary.api_base_url
}

output "api_base_url_secondary" {
  value = module.stack_secondary.api_base_url
}

output "ecs_message_primary" {
  value = module.stack_primary.ecs_message
}

output "ecs_message_secondary" {
  value = module.stack_secondary.ecs_message
}
