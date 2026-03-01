output "api_base_url" {
  value = aws_apigatewayv2_stage.default.invoke_url
}

output "ecs_message" {
  value = local.ecs_message
}
